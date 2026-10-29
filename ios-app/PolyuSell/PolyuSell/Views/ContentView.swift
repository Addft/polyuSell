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
            Tab("Category", systemImage: "square.grid.2x2"){
                CategoryView()
            }
            Tab("Home", systemImage: "house"){
              
            }
            Tab("Profile", systemImage: "person"){
                ProfileView()
            }
            Tab("Chat", systemImage: "bubble"){}
            
        }
    }
}
struct ContentView: View {
   
    @State var isSplash = false
    
    @Environment(AuthManager.self) var authVM
    @Environment(ProfileStore.self) var profileStore
    @Environment(CategoryStore.self) var categoryStore
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
}

