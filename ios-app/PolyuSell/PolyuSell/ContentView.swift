//
//  ContentView.swift
//  PolyuSell
//
//  Created by HUAHUA on 15/10/2026.
//

import SwiftUI
struct LoginView: View {
    @Environment(ViewModel.self) var vm
    
    @State var username = ""
    @State var password = ""
    @State var isSecure = true
    @State var err = ""
    var body: some View {
        VStack(spacing: 20){
            //title
            HStack{
                Text("Welcome back!")
                    .font(.title.bold())
                Spacer()
            }
            //form section
            Group{
                TextField("username", text: $username)
                HStack{
                    if isSecure{
                        SecureField("password", text: $password)
                    }else{
                        TextField("password", text: $password)
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
                Button(action: {}){
                    HStack{
                        Spacer()
                        Text("Login")
                            .bold()
                            .padding(10)
                        Spacer()
                    }
                }
                .buttonStyle(.glassProminent)
                //sign up btn
                HStack{
                    Text("Didn't have an account?")
                        .foregroundStyle(.secondary)
                    Button(action: {}) {
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
            HStack{
                Button("Google"){}
                Button("Apple"){}
                Button("Facebook"){}
            }
            
            Spacer()
        }
        .padding()
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
    }
}
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}


#Preview {
    LoginView()
        .environment(ViewModel())
}
