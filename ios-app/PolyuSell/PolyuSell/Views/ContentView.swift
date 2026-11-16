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
            Tab("Chat", systemImage: "bubble"){
                ChatListView()
            }
            
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
    @Environment(ChatStore.self) var chatStore
    var body: some View {
        Group{
            if isSplash{
                if authVM.isRestoring{
                    CustomProgressView()
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
        .environment(chatStore)
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

struct CustomProgressView: View {
    @State var spin = false
    var body: some View {
        VStack{
                VStack(spacing: 20){
                    Circle()
                        .trim(from: 0, to: spin ? 0.75 : 1)
                        .stroke(lineWidth: 7)
                        .fill(.accent)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(spin ? 0 : 360))
                        .animation(.default.repeatForever(autoreverses: false), value: spin)
                    
//                    Text("Restoring session...")
//                        .font(.callout)
                        
                }
                .padding(.horizontal)
                .frame(width: 150, height: 150)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.thinMaterial)
                        
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Rectangle()
                .fill(.red)
                .ignoresSafeArea(.all)
        )
        .onAppear{
            spin = true
        }
    }
}
#Preview {
    ContentView()
        .environment(AuthManager())
        .environment(ProfileStore())
        .environment(CategoryStore())
        .environment(ItemStore())
        .environment(ChatStore())
        .preferredColorScheme(.light)
}

