//
//  ChatListView.swift
//  PolyuSell
//
//  Created by HUAHUA on 16/11/2026.
//

import SwiftUI
import Supabase

struct ChatListView: View {
    @Environment(AuthManager.self) var authVM
    @Environment(ChatStore.self) var chatStore
    @Environment(ItemStore.self) var itemStore
    
    @State var conversations: [Conversation] = []
    @State var isLoading = true
    @State var activeConversation: Conversation?
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if conversations.isEmpty {
                    ContentUnavailableView("No Chats", systemImage: "bubble.left.and.bubble.right", description: Text("Start a conversation by finding an item."))
                } else {
                    List {
                        ForEach(conversations) { convo in
                            Button {
                                activeConversation = convo
                            } label: {
                                ChatRowView(conversation: convo, currentUserId: authVM.currentUser?.id)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await loadData()
                    }
                }
            }
            .navigationTitle("Chats")
            .fullScreenCover(item: $activeConversation, onDismiss: {
                // 当聊天室被关闭时，重新拉取列表数据
                Task {
                    await loadData()
                }
            }) { convo in
                ChatDetailView(conversation: convo)
            }
        }
        .task {
            await loadData()
        }
        .onAppear {
            Task{
                await loadData()
            }
        }
    }
    
    func loadData() async {
           guard let userId = authVM.currentUser?.id else { return }
           if conversations.isEmpty { isLoading = true }
           
           do {
               let allConvos = try await chatStore.fetchConversations(userId: userId)
               conversations = allConvos.filter { $0.lastMessage != nil }
           } catch {
               print("Failed to load conversations: \(error)")
           }
           isLoading = false
    }
}

struct ChatRowView: View {
    let conversation: Conversation
    let currentUserId: UUID?
    
    // 判断对方是谁
    var otherUser: Profile? {
        if currentUserId == conversation.buyerId {
            return conversation.seller
        } else {
            return conversation.buyer
        }
    }
    
    // 👇 获取关联商品的封面图 URL
    var itemCoverURL: URL? {
        guard let path = conversation.item?.photos.min(by: { $0.order < $1.order })?.storagePath else { return nil }
        return try? supabase.storage.from("item-photos").getPublicURL(path: path)
    }
    
    // 格式化时间
    var formattedDate: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(conversation.lastMessageAt) {
            formatter.dateFormat = "HH:mm"
        } else if Calendar.current.isDateInYesterday(conversation.lastMessageAt) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
        }
        return formatter.string(from: conversation.lastMessageAt)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 1. 对方头像
            AvatarView(url: otherUser?.avatarUrl, w: 50, version: otherUser?.updatedAt)
            
            // 2. 中间文字信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    // 对方名字
                    Text(otherUser?.name ?? "Unknown User")
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // 时间
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // 最后一条消息
                Text(conversation.lastMessage ?? "No messages yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                // 关联的商品标题
                if let itemTitle = conversation.item?.title {
                    Text("Regarding: \(itemTitle)")
                        .font(.caption2)
                        .foregroundStyle(.accent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.1), in: .rect(cornerRadius: 4))
                        .lineLimit(1)
                }
            }
            
            // 3. 关联的商品封面图（右侧）
            if let coverURL = itemCoverURL {
                AsyncImage(url: coverURL) { phase in
                    if let img = phase.image {
                        img.resizable().scaledToFill()
                    } else {
                        Color(.secondarySystemBackground)
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(.rect(cornerRadius: 8))
            } else {
                // 如果商品没图，显示一个占位符
                Color(.secondarySystemBackground)
                    .frame(width: 50, height: 50)
                    .clipShape(.rect(cornerRadius: 8))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.gray)
                    }
            }
        }
        .padding(.vertical, 4)
    }
}
