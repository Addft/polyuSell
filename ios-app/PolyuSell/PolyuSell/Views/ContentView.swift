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
    // @Environment(AuthManager.self) var authVM
    var body: some View {
        TabView{
            
            Tab("Home", systemImage: "house"){
                HomeView()
            }
            Tab("Category", systemImage: "square.grid.2x2"){
                CategoryView()
            }
            Tab("Chat", systemImage: "bubble"){}
            
            Tab("Profile", systemImage: "person"){
                ProfileView()
            }
            
        }
    }
}
struct ContentView: View {
    
    @State var isSplash = false
    
    @Environment(AuthManager.self) var authVM
    @Environment(ProfileStore.self) var profileStore
    @Environment(CategoryStore.self) var categoryStore
    @Environment(ItemStore.self) var itemStore
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
        .environment(categoryStore)
        .environment(itemStore)
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
        .environment(CategoryStore())
        .environment(ItemStore())
        .preferredColorScheme(.light)
}

