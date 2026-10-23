//
//  AvatarView.swift
//  PolyuSell
//
//  Created by HUAHUA on 23/10/2026.
//

import SwiftUI
import Supabase

struct AvatarView: View {
    var url: String?
    var w: CGFloat
    var version: Date?
    @State var fullUrl: URL? = nil
    var body: some View {
        Group{
            if let fullURL = fullUrl {
                AsyncImage(url: fullURL){ phase in
                    switch phase{
                    case .success(let img):
                        img.resizable()
                            .scaledToFill()
                            .frame(width: w, height: w)
                            .clipShape(.circle)
                    case .empty:
                        ProgressView()
                    case .failure(_):
                        ProgressView()
                    @unknown default:
                        ProgressView()
                    }
                }
            }else{
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: w, height: w)
                    .foregroundStyle(.white)
            }
        }
        .task(id: "\(url ?? "")|\(version?.timeIntervalSince1970 ?? 0)") {
            guard let url, !url.isEmpty else { fullUrl = nil; return }
            if let base = try? supabase.storage.from("avatars").getPublicURL(path: url){
                var comps = URLComponents(url: base, resolvingAgainstBaseURL: false)
                if let version {
                    comps?.queryItems = [URLQueryItem(
                            name: "v",
                            value: String(Int(version.timeIntervalSince1970))
                        )
                    ]
                }
                fullUrl = comps?.url
            }
        }
    }
}
