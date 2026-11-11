//
//  LocationSearchView.swift
//  PolyuSell
//
//  Created by HUAHUA on 2/11/2026.
//

import SwiftUI
import MapKit
struct LocationSearchView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var placeName: String?
    @Binding var latitude: Double?
    @Binding var longitude: Double?

    @State private var model = LocationSearchModel()

    var body: some View {
        NavigationStack {
            List(model.results, id: \.self) { completion in
                Button {
                    Task { await select(completion) }
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(completion.title)
                        if !completion.subtitle.isEmpty {
                            Text(completion.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .searchable(
                text: $model.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "MTR station, street, park…"
            )
            .navigationTitle("Pick-up Location")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if model.query.isEmpty {
                    ContentUnavailableView(
                        "Search a meet-up point",
                        systemImage: "mappin.and.ellipse",
                        description: Text("Try “Central MTR”, “Victoria Park”, “Nathan Road”")
                    )
                }
            }
        }
    }

    private func select(_ completion: MKLocalSearchCompletion) async {
        guard let item = await model.resolve(completion) else { return }
        placeName = completion.title                     // "Central MTR Station"
        latitude  = item.placemark.coordinate.latitude   // 22.2819...
        longitude = item.placemark.coordinate.longitude  // 114.1588...
        dismiss()
    }
}
