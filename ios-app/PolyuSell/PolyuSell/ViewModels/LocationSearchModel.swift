//
//  LocationSearchModel.swift
//  PolyuSell
//
//  Created by HUAHUA on 31/10/2026.
//

import Foundation
import MapKit
import SwiftUI

@Observable
class LocationSearchModel: NSObject, MKLocalSearchCompleterDelegate {
    var query: String = "" {
        didSet { completer.queryFragment = query }
    }
    var results: [MKLocalSearchCompletion] = []

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.pointOfInterest, .address]
        // 偏置到香港，让“Central”优先出“Central MTR Station”而不是别的地方
        completer.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 22.3030, longitude: 114.1790), // PolyU
            span: MKCoordinateSpan(latitudeDelta: 0.6, longitudeDelta: 0.6)
        )
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("completer error: \(error)")
    }

    // 把建议解析成带坐标的 MKMapItem
    func resolve(_ completion: MKLocalSearchCompletion) async -> MKMapItem? {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        return try? await search.start().mapItems.first
    }
}
