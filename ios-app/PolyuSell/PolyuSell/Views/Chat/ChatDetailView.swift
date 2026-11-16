//
//  ChatDetailView.swift
//  PolyuSell
//
//  Created by HUAHUA on 16/11/2026.
//

import SwiftUI
import Supabase

struct ChatDetailView: View {
    let conversation: Conversation
    @Environment(AuthManager.self) var authVM
    @Environment(ChatStore.self) var chatStore
    @Environment(\.dismiss) var dismiss
    
    @State var messages: [Message] = []
    @State var inputText = ""
    @State var isLoading = false
    
    @State var channel: RealtimeChannelV2?
    
    var body: some View {
        NavigationStack{
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { msg in
                                MessageBubble(msg: msg, isMe: msg.senderId == authVM.currentUser?.id)
                                    .id(msg.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _, _ in
                        //new message auto scroll to bottom
                        if let last = messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // txt field
                HStack {
                    TextField("Type a message...", text: $inputText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)
                    
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
                .background(.ultraThinMaterial)
            }
            .navigationTitle(conversation.seller?.name ?? "Chat")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadMessages()
                await setupRealtime()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button{
                        dismiss()
                    }label: {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.glass)
                }
            }
            
            .onDisappear {
                Task {
                    await channel?.unsubscribe()
                }
            }
        }
    }
    
    func loadMessages() async {
        isLoading = true
        do {
            messages = try await chatStore.fetchMessages(conversationId: conversation.id)
        } catch {
            print("Failed to load messages: \(error)")
        }
        isLoading = false
    }
    
    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let userId = authVM.currentUser?.id else { return }
        
        inputText = ""
        
        // gen uuid on client side
        let newId = UUID()
        
        let tempMsg = Message(
            id: newId,
            conversationId: conversation.id,
            senderId: userId,
            createdAt: Date(),
            body: text,
            imageUrl: nil,
            messageType: "text",
            readAt: nil
        )
        
        messages.append(tempMsg)
        
        Task {
            do {
                //retrived the prepared id
                try await chatStore.sendMessage(
                    id: newId,
                    conversationId: conversation.id,
                    senderId: userId,
                    body: text
                )
            } catch {
                print("Send failed: \(error)")
                messages.removeAll(where: { $0.id == newId })
            }
        }
    }
    
    func setupRealtime() async {
        let channel = supabase.channel("room:\(conversation.id.uuidString)")
        
        let inserts = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "messages",
            filter: .eq("conversation_id", value: conversation.id.uuidString)
        )
        
        self.channel = channel
        
        do {
            try await channel.subscribeWithError()
            
            // listen to other user new message
            for await insert in inserts {
                let newMsg = insert.record
                do {
                    let decodedMsg = try newMsg.decode(as: Message.self)
                    
                    if !self.messages.contains(where: { $0.id == decodedMsg.id }) {
                        await MainActor.run {
                            self.messages.append(decodedMsg)
                        }
                    }
                } catch {
                    print("Realtime decode failed: \(error)")
                }
            }
        } catch {
            print("Realtime subscribe failed: \(error)")
        }
    }
}

struct MessageBubble: View {
    let msg: Message
    let isMe: Bool
    
    var body: some View {
        HStack {
            if isMe { Spacer() }
            
            Text(msg.body ?? "")
                .padding(12)
                .background(isMe ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundStyle(isMe ? .white : .primary)
                .clipShape(.rect(cornerRadius: 16))
            
            if !isMe { Spacer() }
        }
    }
}
