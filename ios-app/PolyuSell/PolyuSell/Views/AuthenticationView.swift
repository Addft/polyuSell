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
    @Environment(\.dismiss) var dismiss
    @State var err = ""
    @State var msg = ""
    @State var name = ""
    @State var email = ""
    @State var username = ""
    @State var password = ""
    @State var passwordConfirm = ""
    @State var isAlert = false
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
            
            VStack(spacing: 10){
                HStack{
                    Text("Create Account")
                        .font(.title.bold())
                    Spacer()
                }
                Form{
                    Section("Name"){
                        TextField("name", text: $name)
                            .textContentType(.name)
                    }
                    Section("Username"){
                        TextField("username", text: $username)
                            .textContentType(.username)
                    }
                    Section("Email"){
                        TextField("email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                    }
                    Section("Password"){
                        TextField("password", text: $password)
                    }
                    Section("Password confirmation"){
                        TextField("confirm password", text: $passwordConfirm)
                    }
                }
                .formStyle(.grouped)
                .listSectionSpacing(10)
                .scrollDisabled(true)
                .frame(height: 510)
                .padding(.horizontal,-20)
                Text(err)
                    .font(.footnote)
                    .foregroundStyle(.red)
                
                VStack{
                    Button(action: {
                        Task{
                            err = ""
                            let (error, bool) = await authVM.signUp(name: name, username: username, email: email, password: password, passwordConfirm: passwordConfirm)
                            
                            isAlert = bool
                            if isAlert{
                                msg = error ?? ""
                            }else{
                                err = error ?? ""
                            }
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
                    .alert("Confirm email", isPresented: $isAlert) {
                        Button(role: .confirm){
                            isAlert.toggle()
                            dismiss()
                        }
                    }message: {
                        Text(msg)
                    }
                    
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
           
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .frame(maxHeight: 830)
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
                Form{
                    Section("Email/Username"){
                        TextField("email/username", text: $email)
                            .textContentType(.emailAddress)
                            .textContentType(.username)
                    }
                    Section("Password"){
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
                }
                .formStyle(.grouped)
                .scrollDisabled(true)
                .frame(height: 210)
                .padding(-20)
                
                Text(err)
                    .foregroundStyle(.red).font(.footnote)
                //btns
                VStack{
                    //login btn
                    Button(action: {
                        Task{
                            err = await authVM.signIn(input: email, password: password) ?? ""
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
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .frame(maxHeight: 600)
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

