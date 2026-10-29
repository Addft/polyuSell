//
//  ViewModel.swift
//  PolyuSell
//
//  Created by HUAHUA on 16/10/2026.
//

import Foundation
import Supabase

enum SupabaseConfig {
    static let client: SupabaseClient = {
        guard let filePath = Bundle.main.path(forResource: "Supabase", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let supabaseURL = plist["SUPABASE_URL"] as? String,
              let supabaseKey = plist["SUPABASE_ANON_KEY"] as? String else {
            fatalError("Could not load Supabase configuration from plist.")
        }
        
        guard
            let url = Bundle.main.url(forResource: "Supabase", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let dict = try? PropertyListSerialization.propertyList(
                from: data, format: nil
            ) as? [String: Any],
            let urlString = dict["SUPABASE_URL"] as? String,
            let supabaseURL = URL(string: urlString),
            let anonKey = dict["SUPABASE_ANON_KEY"] as? String
        else {
            fatalError("Missing or invalid Supabase.plist. Check the file is added to the app target.")
        }
        
        return SupabaseClient(supabaseURL: supabaseURL, supabaseKey: anonKey)
    }()
}

// Global shortcut so you can keep using `supabase.auth...`
let supabase = SupabaseConfig.client

@Observable
class ViewModel{
    
    
    
}
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

