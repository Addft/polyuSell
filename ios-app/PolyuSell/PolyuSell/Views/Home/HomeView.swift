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
        VStack {
            HStack{
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

struct HomeView: View {
    @Environment(ItemStore.self) var itemStore
    @State var search = ""
    @State var sheetPublish = false
    @State var isSearching = false
    
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
                    Button {} label: {
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
            .task {
                do{
                    try await itemStore.fetchItems()
                }catch{
                    print("fetch items failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct ItemCard: View {
    let item: Item
    
    var coverURL: URL? {
        guard let path = item.photos.min(by: { $0.order < $1.order })?.storagePath else { return nil }
        return try? supabase.storage.from("item-photos").getPublicURL(path: path)
    }
    
    var body: some View {
        VStack(alignment: .leading){
                AsyncImage(url: coverURL) { phase in
                    if let img = phase.image {
                        img.resizable().scaledToFill()
                    } else {
                        Color(.secondarySystemBackground)
                    }
                }
                .frame(width: 160, height:160)
                .clipShape(.rect(cornerRadius: 10))
                .overlay(alignment: .topTrailing) {
                    Button {
                        
                    } label: {
                        ZStack{
                            Circle()
                                .fill(.thinMaterial)
                                .frame(width: 40)
                            Image(systemName: "heart")
                                .font(.title2)
                        }
                    }
                    .padding(10)
                    
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.title).font(.headline).lineLimit(1)
                    
                    Text("HK$\(item.price, specifier: "%.0f")")
                        .font(.subheadline)
                        .bold()
                        
                    Text("condition \(item.condition.rawValue)")
                  
            }
            
        }
        .padding(12)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 30))
    
    }
}
