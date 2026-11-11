//
//  CategoryView.swift
//  PolyuSell
//
//  Created by HUAHUA on 30/10/2026.
//

import SwiftUI

struct CategoryView: View {
    @Environment(CategoryStore.self) var categoryStore
    @State var selectedCategoryId: Int?
    var body: some View {
        HStack(alignment: .top){
            List(categoryStore.categories){ category in
                Text(category.name)
                    .font(.callout)
                    .foregroundStyle(selectedCategoryId == category.id ? .white : .primary)
                    .listRowBackground( selectedCategoryId == category.id ? Color(.accent) :  Color(.systemBackground) )
                    .onTapGesture {
                        selectedCategoryId = category.id
                    }
            }
            .frame(maxWidth: 160)
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
            
            if let categoryId = selectedCategoryId,
               let subCategory = categoryStore.subcategoriesByCategory.first(where: {$0.key == categoryId})
            {
                ScrollView(.vertical, showsIndicators: false){
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 90, maximum: 200), spacing: 10), count: 2)) {
                    ForEach(Array(subCategory.value)){ sub in
                        VStack{
                            Image(systemName: sub.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                            Text(sub.name)
                                .font(.caption)
                        }
                        .padding(10)
                        .foregroundStyle(.primary)
                        .frame(width: 90, height: 90)
                        .glassEffect(.clear, in: .rect(cornerRadius: 20))
                        .padding(.bottom, 10)
                    }
                }
            }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.thinMaterial)
            }else{
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
