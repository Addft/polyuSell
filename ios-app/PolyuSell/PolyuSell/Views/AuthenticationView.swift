//
//  SignupView.swift
//  PolyuSell
//
//  Created by HUAHUA on 22/10/2026.
//

import SwiftUI
import GoogleSignInSwift
import Supabase

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
                    .textContentType(.newPassword)
                TextField("confirm password", text: $passwordConfirm)
                    .textContentType(.newPassword)
                
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
            .background(Color(.systemBackground))
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
    @Environment(ProfileStore.self) var profileStore
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
                        .background(Color(.systemBackground))
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
            .background(Color(.systemBackground))
            .clipShape(.rect(cornerRadius: 30))
            
            .onDisappear{
                email = ""
                password = ""
            }
            
        }
        
        //}
    }
}

