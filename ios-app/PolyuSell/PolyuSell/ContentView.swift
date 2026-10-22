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
struct SignupView: View {
    @Environment(AuthManager.self) var authVM
    
    @State var err = ""
    @State var name = ""
    @State var email = ""
    @State var username = ""
    @State var password = ""
    @State var passwordConfirm = ""
    
    var body: some View {
        //NavigationStack{
        ZStack{
            Group{
                Rectangle()
                    .foregroundStyle(.red)
                    .frame(height: 350)
                    .offset(y: -310)
                
                Circle()
                    .foregroundStyle(.red)
                    .brightness(0.1)
                    .frame(width: 140)
                    .offset(x: -140, y: -380)
                
                Circle()
                    .foregroundStyle(.red)
                    .brightness(0.1)
                    .frame(width: 80)
                    .offset(x: -50, y: -280)
                
                Circle()
                    .foregroundStyle(.red)
                    .brightness(0.1)
                    .frame(width: 180)
                    .offset(x: 120, y: -310)
            }
            
            VStack(spacing: 20){
                HStack{
                    Text("Create Account")
                        .font(.title.bold())
                    Spacer()
                }
                TextField("name", text: $name)
                    .textContentType(.name)
                TextField("username", text: $username)
                    .textContentType(.username)
                TextField("email", text: $email)
                    .textContentType(.emailAddress)
                TextField("password", text: $password)
                
                TextField("confirm password", text: $passwordConfirm)
                
                Text(err)
                    .font(.footnote)
                    .foregroundStyle(.red)
                
                VStack{
                    Button(action: {
                        Task{
                         err = try await authVM.signUp(name: name, username: username, email: email, password: password, passwordConfirm: passwordConfirm) ?? ""
                        }
                    }) {
                        HStack{
                            Spacer()
                            Text("Sign Up")
                                .bold()
                                .padding()
                            Spacer()
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    HStack{
                        Text("Already have an account?")
                            .foregroundStyle(.secondary)
                        NavigationLink(destination: LoginView()) {
                            Text("sign in")
                                .underline()
                        }
                    }
                    .font(.subheadline)
                }
                
            }
            .padding(30)
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .frame(maxHeight: 550)
            .background(.white)
            .clipShape(.rect(cornerRadius: 30))
            .onDisappear{
                name = ""
                username = ""
                email = ""
                password = ""
                passwordConfirm = ""
            }
        }
        //}
    }
    
    
}
struct LoginView: View {
    @Environment(AuthManager.self) var authVM
    
    @State var email = ""
    @State var password = ""
    @State var isSecure = true
    @State var err = ""
    @State var isLoading = false
    var body: some View {
        //NavigationStack{
        ZStack{
            Group{
                Rectangle()
                    .foregroundStyle(.red)
                    .frame(height: 350)
                    .offset(y: -310)
                
                Circle()
                    .foregroundStyle(.red)
                    .brightness(0.1)
                    .frame(width: 140)
                    .offset(x: -140, y: -380)
                
                Circle()
                    .foregroundStyle(.red)
                    .brightness(0.1)
                    .frame(width: 80)
                    .offset(x: -50, y: -280)
                
                Circle()
                    .foregroundStyle(.red)
                    .brightness(0.1)
                    .frame(width: 180)
                    .offset(x: 120, y: -310)
            }
            
            VStack(spacing: 20){
                //title
                HStack{
                    Text("Welcome back!")
                        .font(.title.bold())
                    Spacer()
                }
                //form section
                Group{
                    TextField("email", text: $email)
                        .textContentType(.emailAddress)
                        
                    HStack{
                        if isSecure{
                            SecureField("password", text: $password)
                                .textContentType(.password)
                        }else{
                            TextField("password", text: $password)
                                .textContentType(.password)
                        }
                        Button(action: {
                            withAnimation {
                                isSecure.toggle()
                            }
                        }) {
                            Image(systemName: isSecure ? "eye.slash" : "eye")
                        }
                    }
                }
                Text(err)
                    .foregroundStyle(.red).font(.footnote)
                //btns
                VStack{
                    //login btn
                    Button(action: {
                        Task{
                            do{
                                try await supabase.auth.signIn(email: email, password: password)
                            }catch{
                                err = error.localizedDescription
                            }
                        }
                    }){
                        HStack{
                            Spacer()
                            Text("Login")
                                .bold()
                                .padding()
                            Spacer()
                        }
                    }
                    .buttonStyle(.glassProminent)
                    //sign up btn
                    HStack{
                        Text("Don't have an account?")
                            .foregroundStyle(.secondary)
                        NavigationLink(destination: SignupView()){
                            Text("sign up")
                                .underline()
                        }
                    }.font(.subheadline)
                    
                }
                //OR with devider
                ZStack{
                    Capsule()
                        .frame(height: 1)
                        .foregroundStyle(.secondary)
                    Text("OR")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding()
                        .background(.white)
                }
                //3th party auth
                
                Button(action:{
                    Task {
                        isLoading = true
                        err = ""
                        err = try await authVM.signInWithGoogle() ?? ""
                        isLoading = false
                    }
                }){
                    
                    HStack{
                        if isLoading{
                            ProgressView()
                        }else{
                            Image("google")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                            Text("Continue with Google")
                        }
                    }
                    .padding()
                    .padding(.horizontal, 50)
                    .overlay {
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(lineWidth: 1)
                    }
                }
                
                // Spacer()
            }
            .padding(30)
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .frame(maxHeight: 550)
            .background(.white)
            .clipShape(.rect(cornerRadius: 30))
            .onDisappear{
                email = ""
                password = ""
            }
        }
        
        //}
    }
}
struct RootView: View {
    @Environment(ViewModel.self) var vm
    @Environment(AuthManager.self) var authVM
    var body: some View {
        TabView{
            Tab("Home", systemImage: "house"){
                Button("Sign out"){
                    Task{
                        try await supabase.auth.signOut()
                        
                    }
                }
            }
            Tab("Category", systemImage: "square.grid.2x2"){}
            Tab("Chat", systemImage: "bubble"){}
            Tab("Profile", systemImage: "person"){}
        }
    }
}
struct OnboardView: View {
    @Environment(AuthManager.self) var authVM
    var body: some View {
        NavigationStack{
            VStack{
                Text("Polyu Sell")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                
                NavigationLink( destination: LoginView()) {
                    Text("Get Start")
                        .font(.title3.bold())
                        .padding()
                        .padding(.horizontal, 30)
                        .background(.white, in: .rect(cornerRadius: 30))
                }
            }
            .ignoresSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ZStack{
                    Rectangle()
                        .fill(.red)
                    Group{
                        
                        
                    }
                    .blur(radius: 6)
                }
                
            )
        }
    }
}

struct ContentView: View {
    @State var vm = ViewModel()
    @State var authVM = AuthManager()
    @State var isSplash = false
    
    var body: some View {
        Group{
            if isSplash{
                if authVM.isRestoring{
                    ProgressView("Restoring session...")
                }else{
                    switch authVM.isLogin{
                    case true:
                        RootView()
                            .overlay(alignment: .top) {
                                // Debug badge — remove before submission
                                VStack(spacing: 4) {
                                    Text("DEBUG")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(.red, in: Capsule())
                                    
                                    Text(authVM.currentUser?.email ?? "no email")
                                        .font(.caption)
                                    Text(authVM.currentUser?.id.uuidString ?? "no id")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Text("provider: \(authVM.currentUser?.appMetadata["provider"]?.stringValue ?? "—")")
                                        .font(.caption2)
                                    Text("\(authVM.currentProfile)")
                                }
                                .padding(8)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                                .padding(.top, 60)
                            }
                        
                    case false:
                        OnboardView()
                    }
                }
            }else{
                ProgressView()
            }
        }
        .environment(authVM)
        .environment(vm)
        .ignoresSafeArea(.all)
        .onAppear{
            withAnimation(.easeIn.delay(1)){
                isSplash.toggle()
            }
        }
    }
}

#Preview {
    ContentView()
}

