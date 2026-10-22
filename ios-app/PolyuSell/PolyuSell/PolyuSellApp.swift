//
//  PolyuSellApp.swift
//  PolyuSell
//
//  Created by HUAHUA on 15/10/2026.
//

import SwiftUI
import GoogleSignIn
import Supabase
  

@main
struct PolyuSellApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    Task {
                        do {
                            let session = try await supabase.auth.session(from: url)
                            print("OAuth callback success, user: \(session.user.email ?? "nil")")
                        } catch {
                            print("OAuth callback FAILED: \(error)")
                        }
                    }
                }
        }
    }
}
