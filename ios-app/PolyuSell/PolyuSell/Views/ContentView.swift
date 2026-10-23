//
//  ContentView.swift
//  PolyuSell
//
//  Created by HUAHUA on 15/10/2026.
//

import SwiftUI
import GoogleSignInSwift
import Supabase
extension View{
    func circleLinearWhite(w: CGFloat, maxOpacity: Double, minOpacity: Double, x: CGFloat, y: CGFloat) -> some View{
        Circle()
            .fill(
                LinearGradient(colors: [.white.opacity(maxOpacity), .white.opacity(minOpacity)], startPoint: .top, endPoint: .bottom)
            )
            .frame(width: w)
            .offset(x:x, y:y)
    }
}

struct RootView: View {
    @Environment(AuthManager.self) var authVM
    var body: some View {
        TabView{
            Tab("Profile", systemImage: "person"){
                ProfileView()
            }
            Tab("Home", systemImage: "house"){
                Button("Sign out"){
                    Task{
                        try await supabase.auth.signOut()
                        
                    }
                }
            }
            Tab("Category", systemImage: "square.grid.2x2"){}
            Tab("Chat", systemImage: "bubble"){}
            
        }
    }
}
struct ContentView: View {
    @State var vm = ViewModel()
    @State var isSplash = false
    
    @Environment(AuthManager.self) var authVM
    @Environment(ProfileStore.self) var profileStore
    var body: some View {
        Group{
            if isSplash{
                if authVM.isRestoring{
                    ProgressView("Restoring session...")
                }else{
                    switch authVM.isLogin{
                    case true:
                        RootView()
                        
                    case false:
                        OnboardView()
                    }
                }
            }else{
                ProgressView()
            }
        }
        .environment(authVM)
        .environment(profileStore)
        .environment(vm)
        .ignoresSafeArea(.all)
        .onAppear{
            withAnimation(.easeIn.delay(1)){
                isSplash.toggle()
            }
            if let id = authVM.currentUser?.id{
                Task{
                    profileStore.currentProfile = await profileStore.fetchProfile(userId: id)
                }
            }
        }
        .onChange(of: authVM.currentUser?.id) { oldValue, newValue in
            if let newValue = newValue{
                Task{
                    profileStore.currentProfile = await profileStore.fetchProfile(userId: newValue)
                }
            }else{
                
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthManager())
        .environment(ProfileStore())
}

