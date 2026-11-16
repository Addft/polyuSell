//
//  HomeView.swift
//  PolyuSell
//
//  Created by HUAHUA on 30/10/2026.
//

import SwiftUI
import Supabase

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var search: String
    @FocusState var isfocus: Bool
    
    var body: some View {
        NavigationStack{
            VStack {
                HStack{
                    Button{
                        dismiss()
                    }label: {
                        Image(systemName: "xmark")
                            .padding(10)
                    }
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("search", text: $search)
                            .focused($isfocus)
                        
                    }
                    .padding()
                    .background(.thinMaterial, in: .capsule)
                    Button{
                        
                    }label: {
                        Image(systemName: "camera")
                            .padding()
                            .background(.thinMaterial, in: .circle)
                    }
                }
                Spacer()
            }
            .padding()
           
            .onAppear {
                isfocus = true
            }
        }
    }
}

struct HomeView: View {
    @Environment(AuthManager.self) var authVM
    @Environment(ItemStore.self) var itemStore
    @State var search = ""
    @State var sheetPublish = false
    @State var isSearching = false
    
    @State var selectedItem: Item?
    
    @State var subpage: SubPage = .recent
    enum SubPage: String, CaseIterable{
        case recent = "Most recently"
        case nearby
    }
    
    var items : [Item] {
        itemStore.items
    }
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                Button {
                    isSearching = true
                } label: {
                    HStack{
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text(search.isEmpty ? "search" : search)
                                .foregroundColor(search.isEmpty ? .secondary : .primary)
                            Spacer()
                        }
                        .padding()
                        .background(.thinMaterial, in: .capsule)
                        Button{
                            
                        }label: {
                            Image(systemName: "camera")
                                .padding()
                                .background(.thinMaterial, in: .circle)
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding()
                
                HStack{
                    ForEach(SubPage.allCases, id: \.self){ page in
                        Spacer()
                        
                        Button{
                            withAnimation{
                                subpage = page
                            }
                        }label: {
                            VStack{
                                Text(page.rawValue.capitalized)
                                    .foregroundStyle(subpage == page ? .accent : .secondary)
                                Capsule()
                                    .fill(subpage == page ? .accent : .clear)
                                    .frame(height: 2)
                                
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                }
                .padding(.bottom,-10)
                
                if itemStore.isLoading{
                    ProgressView()
                }else{
                    
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                        ForEach(items){ item in
                                ItemCard(item: item)
                                .onTapGesture {
                                    selectedItem = item
                                }
                        }
                    }
                    
                    .padding(.horizontal, 10)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(colors: [.secondary.opacity(0.2), .secondary.opacity(0)], startPoint: .bottom, endPoint: .top)
                    )
                    .clipped()
                    
                    
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Polyu Sell")
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        sheetPublish = true
                    } label: {
                        Image(systemName: "plus").padding(10)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SavedItemView()
                    } label: {
                        Image(systemName: "heart").padding(10)
                    }
                }
            }
            .sheet(isPresented: $sheetPublish){
                PublishSheet()
                    .onDisappear {
                        Task { try? await itemStore.fetchItems() }
                    }
            }
            .fullScreenCover(isPresented: $isSearching) {
                SearchView(search: $search)
            }
            .fullScreenCover(item: $selectedItem){ item in
                ItemDetailView(item: item)
            }
            .task {
                do {
                    try await itemStore.fetchItems()
                    if let userId = authVM.currentUser?.id {
                        try await itemStore.fetchSavedItems(userId: userId)
                    }
                } catch {
                    print("fetch items failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
struct SavedItemView: View {
    @Environment(ItemStore.self) var itemStore
    @State var selectedItem: Item?
    var savedItems: [Item] {
        itemStore.items.filter { itemStore.savedItemIds.contains($0.id) }
    }
    var body: some View {
        ScrollView(.vertical,showsIndicators: false){
            LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                ForEach(savedItems) { item in
                    ItemCard(item: item)
                        .onTapGesture {
                            selectedItem = item
                        }
                }
            }
        }
        .navigationTitle("My likes")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $selectedItem) { item in
            ItemDetailView(item: item)
        }
    }
}


