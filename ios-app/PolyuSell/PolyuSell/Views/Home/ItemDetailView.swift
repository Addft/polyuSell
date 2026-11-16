//
//  ItemDetailView.swift
//  PolyuSell
//
//  Created by HUAHUA on 16/11/2026.
//


import SwiftUI
import Supabase

struct ItemDetailView: View {
    @Environment(AuthManager.self) var authVM
    @Environment(ItemStore.self) var itemStore
    @Environment(ChatStore.self) var chatStore
    @Environment(\.dismiss) var dismiss
    
    let item: Item
    
    @State var activeConversation: Conversation?
    @State var isStartingChat = false
    
    var isSeller: Bool {
        authVM.currentUser?.id == item.sellerId
    }
    var isSaved: Bool{
        itemStore.savedItemIds.contains(item.id)
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if !item.photos.isEmpty {
                            TabView {
                                ForEach(item.photos.sorted(by: { $0.order < $1.order })) { photo in
                                    let url = try? supabase.storage.from("item-photos").getPublicURL(path: photo.storagePath)
                                    AsyncImage(url: url) { phase in
                                        if let img = phase.image {
                                            img.resizable().scaledToFill()
                                        } else {
                                            Color(.secondarySystemBackground)
                                        }
                                    }
                                }
                            }
                            .tabViewStyle(.page)
                            .frame(height: 300)
                            .clipped()
                        } else {
                            Color(.secondarySystemBackground)
                                .frame(height: 300)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("HK$ \(item.price, specifier: "%.0f")")
                                .font(.title.bold())
                                .foregroundStyle(.red)
                            
                            Text(item.title)
                                .font(.title2.bold())
                            
                            HStack {
                                Text("Condition: \(item.condition.rawValue)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(item.createdAt.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Divider()

                            Text("Description")
                                .font(.headline)
                            Text(item.description ?? "No description provided.")
                                .font(.body)
                                .foregroundStyle(.secondary)
                            
                            Divider()
                            
                            Text("Transaction Methods")
                                .font(.headline)
                            
                            if let f = item.fulfillment {
                                if f.acceptsFaceToFace {
                                    Label {
                                        Text(f.placeName ?? "Face to Face")
                                    } icon: {
                                        Image(systemName: "figure.2.arms.open")
                                    }
                                    .foregroundStyle(.secondary)
                                }
                                if f.acceptsShipping {
                                    Label("Shipping available", systemImage: "shippingbox")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // seller card
                        if let seller = item.seller {
                            NavigationLink(destination: SellerProfileView(seller: seller)) {
                                HStack(spacing: 12) {
                                    AvatarView(url: seller.avatarUrl, w: 50, version: seller.updatedAt)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(seller.name)
                                            .font(.headline)
                                        Text("@\(seller.username)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    
                                    HStack(spacing: 2) {
                                        Image(systemName: "star.fill").foregroundStyle(.yellow)
                                        Text(String(format: "%.1f", seller.averageRating ?? 0))
                                        Text("(\(seller.ratingCount ?? 0))")
                                            .foregroundStyle(.secondary)
                                    }
                                    .font(.subheadline)
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.tertiary)
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                        }
                    }
                }
                HStack{
                    Button{
                        guard let userId = authVM.currentUser?.id else { return }
                        Task {
                            try? await itemStore.toggleSave(itemId: item.id, userId: userId)
                        }
                    }label: {
                        Image(systemName: isSaved ? "heart.fill" : "heart")
                            .font(.title)
                            .foregroundStyle(isSaved ? .red : .primary)
                            .padding(10)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    
                    if isSeller {
                        Button{} label: {
                            Spacer()
                            Text("This is your item")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .padding()
                            Spacer()
                        }
                        //  .buttonStyle(.glassProminent)
                        .disabled(true)
                    } else {
                        Button {
                            guard let userId = authVM.currentUser?.id else { return }
                            isStartingChat = true
                            Task {
                                do {
                                    let convo = try await chatStore.getOrCreateConversation(item: item, buyerId: userId)
                                    activeConversation = convo
                                } catch {
                                    print("Failed to start chat: \(error)")
                                }
                                isStartingChat = false
                            }
                        } label: {
                            Spacer()
                            if isStartingChat {
                                ProgressView()
                                    .padding()
                            } else {
                                Text("Chat")
                                    .padding()
                                    .font(.title3)
                            }
                            Spacer()
                        }
                        .buttonStyle(.glassProminent)
                        .disabled(isStartingChat)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: .secondary.opacity(0.5), radius: 20)
                .fullScreenCover(item: $activeConversation) { convo in
                    ChatDetailView(conversation: convo)
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem (placement: .topBarLeading){
                    Button{
                        dismiss()
                    }label: {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.glass)
                }
            }
        }
    }
}

