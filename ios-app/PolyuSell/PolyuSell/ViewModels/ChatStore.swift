//
//  ChatStore.swift
//  PolyuSell
//
//  Created by HUAHUA on 16/11/2026.
//

import Foundation
import Supabase
import SwiftUI

@MainActor
@Observable
class ChatStore {
    
    func getOrCreateConversation(item: Item, buyerId: UUID) async throws -> Conversation {
        let existing: [Conversation] = try await supabase
            .from("conversations")
            .select("*, buyer:profiles!conversations_buyer_id_fkey(*), seller:profiles!conversations_seller_id_fkey(*)")
            .eq("item_id", value: item.id)
            .eq("buyer_id", value: buyerId)
            .limit(1)
            .execute()
            .value
        
        if let convo = existing.first {
            return convo
        }
        
        struct ConversationInsert: Encodable {
            let item_id: UUID
            let buyer_id: UUID
            let seller_id: UUID
        }
        
        let newInsert = ConversationInsert(item_id: item.id, buyer_id: buyerId, seller_id: item.sellerId)
        
        let created: Conversation = try await supabase
            .from("conversations")
            .insert(newInsert)
            .select("*, buyer:profiles!conversations_buyer_id_fkey(*), seller:profiles!conversations_seller_id_fkey(*)")
            .single()
            .execute()
            .value
            
        return created
    }
    
    func sendMessage(id: UUID, conversationId: UUID, senderId: UUID, body: String) async throws {
        struct MessageInsert: Encodable {
            let id: UUID
            let conversation_id: UUID
            let sender_id: UUID
            let body: String
            let message_type: String
        }
        
        let msg = MessageInsert(
            id: id,
            conversation_id: conversationId,
            sender_id: senderId,
            body: body,
            message_type: "text"
        )
        
        try await supabase.from("messages").insert(msg).execute()
        
        struct ConvoUpdate: Encodable {
            let last_message: String
            let last_message_at: Date
        }
        let update = ConvoUpdate(last_message: body, last_message_at: Date())
        
        try await supabase
            .from("conversations")
            .update(update)
            .eq("id", value: conversationId)
            .execute()
    }
    
    func fetchMessages(conversationId: UUID) async throws -> [Message] {
        let msgs: [Message] = try await supabase
            .from("messages")
            .select()
            .eq("conversation_id", value: conversationId)
            .order("created_at", ascending: true)
            .execute()
            .value
        return msgs
    }
    
    func fetchConversations(userId: UUID) async throws -> [Conversation] {
        let query = supabase
            .from("conversations")
            .select("""
                       *,
                       item:items(*, item_photos(*), item_fulfillment(*)),
                       buyer:profiles!buyer_id(*),
                       seller:profiles!seller_id(*)
                   """)
            .or("buyer_id.eq.\(userId.uuidString),seller_id.eq.\(userId.uuidString)")
            .order("last_message_at", ascending: false)
            
        let convos: [Conversation] = try await query.execute().value
        return convos
    }
}
