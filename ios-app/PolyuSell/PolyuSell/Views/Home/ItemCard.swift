//
//  ItemCard.swift
//  PolyuSell
//
//  Created by HUAHUA on 16/11/2026.
//

import SwiftUI
import Supabase

struct ItemCard: View {
    @Environment(ItemStore.self) var itemStore
    @Environment(AuthManager.self) var authVM
    
    let item: Item
    
    var isSaved: Bool{
           itemStore.savedItemIds.contains(item.id)
    }
    
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
                    guard let userId = authVM.currentUser?.id else { return }
                    Task {
                        try? await itemStore.toggleSave(itemId: item.id, userId: userId)
                    }
                } label: {
                    ZStack{
                        Circle()
                            .fill(.thinMaterial)
                            .frame(width: 40)
                        Image(systemName: isSaved ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundStyle(isSaved ? .red : .primary)
                    }
                }
                .padding(10)
                .buttonStyle(.plain)
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
