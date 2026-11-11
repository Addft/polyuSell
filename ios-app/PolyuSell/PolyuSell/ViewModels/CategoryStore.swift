//
//  CategoryStore.swift
//  PolyuSell
//
//  Created by HUAHUA on 12/11/2026.
//

import Foundation
import Supabase

@MainActor
@Observable
class CategoryStore {
    var categories: [Category] = []
    var subcategoriesByCategory: [Int: [Subcategory]] = [:]
    init(){
        Task{
         try await   load()
        }
    }
    func load() async throws {
        async let cats: [Category] = supabase
            .from("categories")
            .select()
            .order("id")
            .execute()
            .value

        async let subs: [Subcategory] = supabase
            .from("subcategories")
            .select()
            .order("id")
            .execute()
            .value

        let (c, s) = try await (cats, subs)
        categories = c
        subcategoriesByCategory = Dictionary(grouping: s, by: \.categoryId)
    }
}

