//
//  SellerProfileView.swift
//  PolyuSell
//
//  Created by HUAHUA on 16/11/2026.
//


import SwiftUI
// todo: items list, reviews comments
struct SellerProfileView: View {
    let seller: Profile
    @Environment(ItemStore.self) var itemStore
    
    @State var reviews: [Review] = []
    @State var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. 顶部卖家信息
                VStack(spacing: 8) {
                    AvatarView(url: seller.avatarUrl, w: 80, version: seller.updatedAt)
                    
                    Text(seller.name)
                        .font(.title.bold())
                    Text("@\(seller.username)")
                        .foregroundStyle(.secondary)
                    
                    // 评分星星
                    HStack(spacing: 4) {
                        let rounded = seller.averageRating?.rounded(.toNearestOrAwayFromZero) ?? 0
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: "star.fill")
                                .foregroundStyle(Int(rounded) >= index ? .yellow : .secondary)
                        }
                        Text(String(format: "%.1f", seller.averageRating ?? 0))
                            .font(.subheadline.bold())
                        Text("(\(seller.ratingCount ?? 0) reviews)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top)
                
                // 2. 评论列表
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reviews")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if isLoading {
                        ProgressView().padding()
                    } else if reviews.isEmpty {
                        Text("No reviews yet.")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        ForEach(reviews) { review in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    // 评论者头像
                                    AvatarView(url: review.reviewer?.avatarUrl, w: 30, version: nil)
                                    Text(review.reviewer?.name ?? "Anonymous")
                                        .font(.subheadline.bold())
                                    
                                    Spacer()
                                    
                                    // 评论星级
                                    HStack(spacing: 2) {
                                        ForEach(1...5, id: \.self) { i in
                                            Image(systemName: "star.fill")
                                                .font(.caption2)
                                                .foregroundStyle(i <= review.rating ? .yellow : .secondary)
                                        }
                                    }
                                }
                                
                                if let comment = review.comment, !comment.isEmpty {
                                    Text(comment)
                                        .font(.callout)
                                }
                                
                                Text(review.createdAt.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .navigationTitle("Seller Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            isLoading = true
            do {
                reviews = try await itemStore.fetchReviews(sellerId: seller.id)
            } catch {
                print("Failed to load reviews: \(error)")
            }
            isLoading = false
        }
    }
}
