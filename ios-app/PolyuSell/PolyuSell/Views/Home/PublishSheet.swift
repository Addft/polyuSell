//
//  PublishSheet.swift
//  PolyuSell
//
//  Created by HUAHUA on 2/11/2026.
//

import SwiftUI
import PhotosUI
import Supabase
import UIKit

struct PublishSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(CategoryStore.self) var categoryStore
    @Environment(ItemStore.self) var itemStore
    @Environment(AuthManager.self) var authVM
    
    @State var photoItems: [PhotosPickerItem] = []
    @State var photoDatas: [Data] = []
    
    
    @State var title = ""
    @State var description = ""
    @State var condition: ItemCondition = .good
    @State var price = ""
    @State var categoryId = 1
    @State var subCategoryId: Int? = nil
    @State var placeName: String?
    @State var latitude: Double?
    @State var longitude: Double?
    @State var notes = ""
    
    @State var offerF2F = false
    @State var offerShipping = false
    
    @FocusState var isPriceFocuse: Bool
    @State var isAlert = false
    @State var openGallery = false
    @State var isPublishing = false
    @State var err = ""
    
    var body: some View {
        NavigationStack {
            Form {
                if !err.isEmpty {
                    Section { Text(err).foregroundStyle(.red).font(.footnote) }
                }
                Section("Item Information") {
                    // photos preview
                    if photoDatas.isEmpty {
                        Button {
                            isAlert.toggle()
                        } label: {
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle().fill(.regularMaterial).frame(width: 50)
                                    Image(systemName: "plus")
                                }
                                Spacer()
                            }
                        }
                        .frame(height: 200)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                          horizontalPhotosPreview
                            .padding(.vertical, 8)
                        }
                    }
                    
                    TextField("title", text: $title)
                    TextField("description", text: $description, axis: .vertical)
                    TextField("price", text: $price).keyboardType(.numberPad)
                        .focused($isPriceFocuse)
                }
                Section(header: Text("Condition")) {
                    Picker("", selection: $condition) {
                        ForEach(ItemCondition.allCases, id: \.self){ condition in
                            Text(condition.rawValue)
                                .tag(condition)
                        }
                    }
                }
                
                Section(header: Text("Category")) {
                    Picker("", selection: $categoryId){
                        ForEach(categoryStore.categories){ category in
                            Text(category.name)
                                .tag(category.id)
                        }
                    }
                    if let subCategories = categoryStore.subcategoriesByCategory.first(where: {$0.key==categoryId}) {
                        Picker("Sub category",selection: $subCategoryId){
                            ForEach(Array(subCategories.value)){ s in
                                Text(s.name)
                                    .tag(s.id)
                            }
                        }
                    }
                }
                
                Section("Transaction Methods") {
                    Toggle("Face to face", isOn: $offerF2F)
                    if offerF2F {
                        NavigationLink(placeName ?? "Choose location",
                                       destination: LocationSearchView(
                                        placeName: $placeName,
                                        latitude: $latitude,
                                        longitude: $longitude))
                    }
                    Toggle("Shipping", isOn: $offerShipping)
                }
                
                Section("Notes (optional)") {
                    TextField("", text: $notes, axis: .vertical)
                }
                
                if !err.isEmpty {
                    Section { Text(err).foregroundStyle(.red).font(.footnote) }
                }
            }
            .alert("Upload item photos", isPresented: $isAlert) {
                Button("upload from gallery") {
                    openGallery = true
                    isAlert = false
                }
                Button("upload from camera") { isAlert = false }
                Button(role: .cancel) { isAlert = false }
            }
            .photosPicker(
                isPresented: $openGallery,
                selection: $photoItems,
                maxSelectionCount: 9,
                matching: .images
            )
            .onChange(of: photoItems) { _, newItems in
                Task {
                    var result: [Data] = []
                    for item in newItems {
                        if let data = await item.loadJPEGData() {
                            result.append(data)
                        }
                    }
                    photoDatas = result
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) { dismiss() }
                        .disabled(isPublishing)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isPriceFocuse{
                        Button("Done"){
                            isPriceFocuse = false
                        }
                    }else{
                        if isPublishing {
                            ProgressView()
                        } else {
                            Button("Publish", role: .confirm) {
                                Task { await publish() }
                            }
                            .tint(.primary)
                        }
                    }
                }
            }
        }
    }
    
    func publish() async {
        err = ""
        guard let sellerId = authVM.currentUser?.id else { err = "Not signed in"; return }
        guard !photoDatas.isEmpty else { err = "Please add at least one photo"; return }
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { err = "Title required"; return }
        guard let priceValue = Double(price), priceValue >= 0 else { err = "Invalid price"; return }
        guard offerF2F || offerShipping else { err = "Enable at least one transaction method"; return }
        if offerF2F {
            guard placeName != nil, latitude != nil, longitude != nil else {
                err = "Please choose a meet-up location"; return
            }
        }
        
        isPublishing = true
        defer { isPublishing = false }
        
        do {
            try await itemStore.publish(
                sellerId: sellerId,
                title: title.trimmingCharacters(in: .whitespaces),
                description: description,
                price: priceValue,
                condition: condition,
                categoryId: categoryId,
                subcategoryId: subCategoryId,
                photoDatas: photoDatas,
                offersF2F: offerF2F,
                offersShipping: offerShipping,
                placeName: offerF2F ? placeName : nil,
                latitude:  offerF2F ? latitude  : nil,
                longitude: offerF2F ? longitude : nil,
                notes: notes
            )
            dismiss()
        } catch {
            err = "Publish failed: \(error.localizedDescription)"
        }
    }
    
    var horizontalPhotosPreview: some View{
        HStack(spacing: 8) {
            ForEach(Array(photoDatas.enumerated()), id: \.offset) { idx, data in
                if let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(.rect(cornerRadius: 10))
                        .overlay(alignment: .topTrailing) {
                            Button {
                                photoDatas.remove(at: idx)
                                if idx < photoItems.count {
                                    photoItems.remove(at: idx)
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.white, .black.opacity(0.6))
                            }
                            .padding(4)
                        }
                }
            }
            Button {
                isAlert.toggle()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.regularMaterial)
                        .frame(width: 100, height: 100)
                    Image(systemName: "plus")
                }
            }
        }
    }
}


extension UIImage {
    func resizedJPEG(maxSide: CGFloat = 1600, quality: CGFloat = 0.8) -> Data? {
        let longest = max(size.width, size.height)
        guard longest > 0 else { return nil }
        
        let scale = min(1, maxSide / longest)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}

extension PhotosPickerItem {
    func loadJPEGData(maxSide: CGFloat = 1600, quality: CGFloat = 0.8) async -> Data? {
        guard
            let raw = try? await loadTransferable(type: Data.self),
            let ui  = UIImage(data: raw)
        else { return nil }
        return ui.resizedJPEG(maxSide: maxSide, quality: quality)
    }
}
