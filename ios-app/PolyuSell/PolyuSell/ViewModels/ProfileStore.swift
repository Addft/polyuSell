//
//  ProfileStore.swift
//  PolyuSell
//
//  Created by HUAHUA on 22/10/2026.
//

import Foundation
import Supabase

@Observable
class ProfileStore{
    var currentProfile: Profile?
    
    func fetchProfile(userId: UUID) async throws -> Profile?{
        do {
            let profile: Profile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
             return profile
        } catch {
            print("Failed to load profile: \(error)")
        }
        return nil
    }
}
