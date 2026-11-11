//
//  ItemInsert.swift
//  PolyuSell
//
//  Created by HUAHUA on 12/11/2026.
//


import Foundation
import Supabase
import SwiftUI


struct ItemInsert: Encodable {
    let sellerId: UUID
    let cId: Int
    let subcategoryId: Int?
    let title: String
    let description: String?
    let price: Double
    let status: String
    let condition: String

    enum CodingKeys: String, CodingKey {
        case sellerId      = "seller_id"
        case cId           = "c_id"
        case subcategoryId = "subcategory_id"
        case title, description, price, status, condition
    }
}

struct ItemPhotoInsert: Encodable {
    let itemId: UUID
    let storagePath: String
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case itemId      = "item_id"
        case storagePath = "storage_path"
        case sortOrder   = "sort_order"
    }
}

struct ItemFulfillmentInsert: Encodable {
    let itemId: UUID
    let method: [String]
    let placeName: String?
    let latitude: Double?
    let longitude: Double?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case method, latitude, longitude, notes
        case placeName = "place_name"
    }
}


struct IDRow: Decodable {
    let id: UUID
}


@MainActor
@Observable
class ItemStore {
    var items: [Item] = []
    var isLoading = false
    
    
    func publish(
        sellerId: UUID,
        title: String,
        description: String,
        price: Double,
        condition: ItemCondition,
        categoryId: Int,
        subcategoryId: Int?,
        photoDatas: [Data],
        offersF2F: Bool,
        offersShipping: Bool,
        placeName: String?,
        latitude: Double?,
        longitude: Double?,
        notes: String
    ) async throws {
        
        let newItem = ItemInsert(
            sellerId: sellerId,
            cId: categoryId,
            subcategoryId: subcategoryId,
            title: title,
            description: description.isEmpty ? nil : description,
            price: price,
            status: ItemStatus.active.rawValue,
            condition: condition.rawValue
        )
        
        let inserted: IDRow = try await supabase
            .from("items")
            .insert(newItem)
            .select("id")
            .single()
            .execute()
            .value
        
        let itemId = inserted.id
        
        do {
            for (index, data) in photoDatas.enumerated() {
                let path = "\(itemId.uuidString)/\(index).jpeg"
                
                //upload to storage
                try await supabase.storage
                    .from("item-photos")
                    .upload(path, data: data, options: FileOptions(contentType: "image/jpeg", upsert: true))
                
                // write data
                let photoRecord = ItemPhotoInsert(
                    itemId: itemId,
                    storagePath: path,
                    sortOrder: index
                )
                try await supabase
                    .from("item_photos")
                    .insert(photoRecord)
                    .execute()
            }
            
            // insert item_fulfillment
            var methods: Set<FulfillmentMethod> = []
            if offersF2F      { methods.insert(.f2f) }
            if offersShipping { methods.insert(.shipping) }
            
            let methodStrings = methods.map { $0.rawValue }
            
            let fulfillmentRecord = ItemFulfillmentInsert(
                itemId: itemId,
                method: methodStrings,
                placeName: offersF2F ? placeName : nil,
                latitude: offersF2F ? latitude : nil,
                longitude: offersF2F ? longitude : nil,
                notes: notes.isEmpty ? nil : notes
            )
            
            try await supabase
                .from("item_fulfillment")
                .insert(fulfillmentRecord)
                .execute()
            
        } catch {
            _ = try? await supabase
                .from("items")
                .delete()
                .eq("id", value: itemId)
                .execute()
            throw error
        }
    }
    
    func fetchItems(
        search: String? = nil,
        categoryId: Int? = nil,
        subcategoryId: Int? = nil
    ) async throws {
        isLoading = true
        defer { isLoading = false }
        
        var query = supabase
            .from("items")
            .select("""
                *,
                photos:item_photos(*),
                seller:profiles(*),
                item_fulfillment(*)
            """)
            .eq("status", value: ItemStatus.active.rawValue)
        
        if let categoryId {
            query = query.eq("c_id", value: categoryId)
        }
        if let subcategoryId {
            query = query.eq("subcategory_id", value: subcategoryId)
        }
        if let search, !search.trimmingCharacters(in: .whitespaces).isEmpty {
            let s = search.trimmingCharacters(in: .whitespaces)
            query = query.or("title.ilike.%\(s)%,description.ilike.%\(s)%")
        }
        
        self.items = try await query
            .order("created_at", ascending: false)
            .execute()
            .value
    }
}
