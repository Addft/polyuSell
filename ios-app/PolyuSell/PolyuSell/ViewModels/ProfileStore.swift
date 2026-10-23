//
//  ProfileStore.swift
//  PolyuSell
//
//  Created by HUAHUA on 22/10/2026.
//

import Foundation
import Supabase

@MainActor
@Observable
class ProfileStore{
    var currentProfile: Profile?
    
    func fetchProfile(userId: UUID) async -> Profile?{
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
    
    func updateProfile(userId: UUID?,name: String, username: String, bio: String, avatar: Data?) async throws -> String?{
        guard let id = userId else {return "User Id not found"}
        
        if username != currentProfile?.username {
            do {
                let taken: [Profile] = try await supabase
                    .from("profiles")
                    .select()
                    .eq("username", value: username)
                    .limit(1)
                    .execute()
                    .value
                if !taken.isEmpty {
                    return "That username is already taken"
                    
                }
            } catch {
                return  "Could not check username: \(error.localizedDescription)"
                
            }
        }
        do {
            
            var updates: [String: AnyJSON] = [
                "name": .string(name.trimmingCharacters(in: .whitespaces)),
                "username": .string(username),
                "bio": .string(bio)
            ]
            if let data = avatar, let avatarPath = try await updateAvatar(userId: id, avatar: data){
                updates["avatar_url"] = .string(avatarPath)
            }
            try await supabase
                .from("profiles")
                .update(updates)
                .eq("id", value: id)
                .execute()
            
            currentProfile = await fetchProfile(userId: id)
        } catch {
            return "Save failed: \(error.localizedDescription)"
        }
        return nil
    }
    
    func updateAvatar(userId: UUID, avatar: Data) async throws-> String? {
        let filepath = "\(userId.uuidString).jpeg"
        
        try await supabase.storage.from("avatars")
            .upload(filepath, data: avatar, options: FileOptions(contentType: "image/jpeg", upsert: true))
        return filepath
    }
    
    func removeAvatar(userId: UUID?) async  {
        guard let userId = userId else {return}
        do {
            let updateData: [String: String?] = ["avatar_url": nil]
            try await supabase
                .from("profiles")
                .update(updateData)
                .eq("id", value: userId)
                .execute()
        } catch {
            
        }
        
        let path = "\(userId.uuidString).jpeg"
        do {
            try await supabase.storage
                .from("avatars")
                .remove(paths: [path])
        } catch {
            print(" Storage remove failed: \(error)")
        }
        currentProfile = await fetchProfile(userId: userId)
    }
}
