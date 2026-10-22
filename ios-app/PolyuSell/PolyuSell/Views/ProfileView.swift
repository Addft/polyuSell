//
//  ProfileView.swift
//  PolyuSell
//
//  Created by HUAHUA on 22/10/2026.
//

import SwiftUI

struct ProfileView: View {
    @Environment(ProfileStore.self) var profileStore
    var body: some View {
        if let current = profileStore.currentProfile{
            VStack(spacing: 20){
                VStack{
                    avatar(url: current.avatarUrl, w: 80)
                    Text(current.name)
                        .font(.title2.bold())
                    Text("@\(current.username)")
                    Text(current.email)
                }
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                
                if !current.bio.isEmpty{
                    VStack(alignment: .leading){
                        Text("Bio")
                        Text(current.bio)
                            .font(.caption)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                }
                
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
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
}
