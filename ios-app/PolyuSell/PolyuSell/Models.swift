//
//  Models.swift
//  PolyuSell
//
//  Created by HUAHUA on 15/10/2026.
//

import Foundation
enum ItemStatus: String, CaseIterable, Codable{
    case sold, draft, deleted, active
}
enum ItemCondition: String, CaseIterable, Codable{
    case good, used, fair
    case new = "Brand New"
    case likeNew = "Like New"
}
struct Profile: Codable, Identifiable{
    let id: UUID
    var email: String
    var username: String
    var name: String
    var avatarUrl: String?
    var bio: String
}

struct Category: Codable,Identifiable{
    let id: Int
    var name: String
    var slug: String
}

struct Item: Codable, Identifiable{
    let id: UUID
    let sellerId: UUID
    var createdAt: Date
    var updatedAt: Date
    var soldAt: Date?
    var cId: Int
    var title: String
    var description: String?
    var photos: [ItemPhoto]
    var price: Double
    var status: ItemStatus
    var condition: ItemCondition
    var fulfillment: ItemFulfillment?
    var seller: Profile?
}
struct ItemPhoto: Codable, Identifiable{
    let id: UUID
    let itemId: UUID
    var storagePath: String
    var order: Int
    
    enum CodingKeys: String, CodingKey {
            case id
            case itemId = "item_id"
            case storagePath = "storage_path"
            case order = "sort_order"
        }
}
enum FulfillmentMethod: String, Codable, CaseIterable {
    case f2f = "F2F"
    case delivery = "Delivery"
}

struct ItemFulfillment: Codable {
    var method: FulfillmentMethod
    var placeName: String?
    var latitude: Double?
    var longitude: Double?
    var deliveryAddress: String?
    var notes: String?
}

struct Conversation: Codable, Identifiable {
    let id: UUID
    let itemId: UUID
    let buyerId: UUID
    let sellerId: UUID
    var lastMessageAt: Date
    var item: Item?
    var buyer: Profile?
    var seller: Profile?
}

struct Message: Codable, Identifiable {
    let id: UUID
    let conversationId: UUID
    let senderId: UUID
    var createdAt: Date
    var body: String?
    var imageUrl: String?
    var messageType: String
    var readAt: Date?
}

struct Review: Codable, Identifiable {
    let id: UUID
    let itemId: UUID?
    let reviewerId: UUID
    let sellerId: UUID
    var createdAt: Date
    var rating: Int
    var comment: String?
}

