//
//  ProfileView.swift
//  PolyuSell
//
//  Created by HUAHUA on 22/10/2026.
//

import SwiftUI
import Supabase

struct ProfileView: View {
    @Environment(ProfileStore.self) var profileStore
    var body: some View {
        NavigationStack{
            if let current = profileStore.currentProfile{
                List{
                    
                    VStack(alignment: .center, spacing: 10){
                        AvatarView(url: current.avatarUrl, w: 100, version: current.updatedAt)
                        
                        VStack(spacing: 4) {
                            Text(current.name)
                                .font(.title2.bold())
                            Text("@\(current.username)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(current.email)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .padding(.bottom, -10)
                    
                    if !current.bio.isEmpty{
                        Section("About me"){
                            Text(current.bio)
                                .font(.callout)
                        }
                    }
                    Section(header: Text("Ratings & Activity")) {
                        HStack{
                            HStack{
                                Spacer()
                                VStack{
                                    HStack{
                                        Text(String(current.averageRating ?? 0))
                                        ForEach(1...5, id: \.self){ index in
                                            let rounded = current.averageRating?.rounded(.toNearestOrAwayFromZero)
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(Int(rounded ?? 0) >= index ? .yellow : .secondary)
                                                .font(.callout)
                                                .padding(.horizontal, -5)
                                        }
                                    }
                                    Text("Average Rating")
                                        .font(.subheadline)
                                }
                                Spacer()
                            }
                            .padding(.trailing, 5)
                            Capsule()
                                .fill(.secondary)
                                .frame(width: 1, height: 50)
                            HStack{
                                Spacer()
                                VStack{
                                    Text(String(current.ratingCount ?? 0))
                                    Text("Rating Count")
                                        .font(.subheadline)
                                }
                                Spacer()
                            }
                        }
                        .font(.headline.bold())
                        // .padding()
                    }
                    
                    Section(header: Text("Account")){
                        NavigationLink(destination: EditProfileView()) {
                            HStack{
                                Image(systemName: "pencil")
                                Text("Edit Profile")
                            }
                        }
                        NavigationLink( destination: SettingView()){
                            HStack{
                                Image(systemName: "gearshape")
                                Text("Settings")
                            }
                        }
                    }
                    
                    Section {
                        Button(role: .destructive) {
                            Task {
                                try await supabase.auth.signOut()
                            }
                        } label: {
                            Text("Sign Out")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                .listSectionSeparator(.hidden)
                .listSectionSpacing(20)
                .scrollIndicators(.hidden)
                .navigationTitle("My Profile")
            }
        }
    }
}

struct SettingView: View {
    @Environment(AuthManager.self) var authVM
    
    @State var email = ""
    @State var password = ""
    @State var passwordConfirm = ""
    var body: some View {
        
    }
}
