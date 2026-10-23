//
//  EditProfileView.swift
//  PolyuSell
//
//  Created by HUAHUA on 23/10/2026.
//

import SwiftUI
import PhotosUI
import Supabase

struct EditProfileView: View {
    @Environment(ProfileStore.self) var profileStore
    @Environment(AuthManager.self) var authVM
    @Environment(\.dismiss) var dismiss
    @State var isInitialLoad = true
    @State var name = ""
    @State var username = ""
    @State var bio = ""
    @State var imgItem: PhotosPickerItem?
    @State var imgData: Data?
    @State var usernameErr = ""
    @State var nameErr = ""
    @State var err = ""
    @State var isAlert = false
    @State var openGallery = false
    var body: some View {
        if let current = profileStore.currentProfile{
            Text(err)
            Form{
                Section("Avatar"){
                    HStack{
                        Spacer()
                        avatarPreview(w: 150, avatarUrl: current.avatarUrl, updatedAt: current.updatedAt)
                            .overlay {
                                Button(action:{isAlert.toggle()}){
                                    Image(systemName: "pencil")
                                }
                                .buttonStyle(.borderedProminent)
                                .buttonBorderShape(.circle)
                                .font(.largeTitle)
                                .offset(x: 60, y:40)
                            }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .listRowBackground(Color(.clear))
                .alert("Update avatar", isPresented: $isAlert) {
                    Button("Upload from gellery", role: .confirm){
                        openGallery.toggle()
                    }
                    Button("Remove image",role: .destructive){
                        Task{
                            await profileStore.removeAvatar(userId: authVM.currentUser?.id)
                        }
                    }
                }
                Section(header: Text("Name"), footer: Group{
                    if !nameErr.isEmpty{
                        Text(nameErr)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }){
                    TextField("name", text: $name)
                }
                
                Section(header: Text("Username"), footer: Group{
                    if !usernameErr.isEmpty{
                        Text(usernameErr)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }){
                    TextField("username", text: $username)
                }
                
                Section("Bio"){
                    TextField("Bio", text: $bio, axis: .vertical)
                }
            }
            .textInputAutocapitalization(.sentences)
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save"){
                        Task{
                            let error = try await profileStore.updateProfile(userId: authVM.currentUser?.id , name: name, username: username, bio: bio, avatar: imgData)
                            
                            if let error = error{
                                err = error
                            }else{
                                err = ""
                                imgData = nil
                                imgItem = nil
                                dismiss()
                            }
                        }
                    }.disabled(name.isEmpty || username.isEmpty)
                }
            }
           
            .onAppear{
                name = current.name
                username = current.username
                bio = current.bio
                DispatchQueue.main.async(execute: {isInitialLoad = false})
            }
            .onDisappear{
                name = ""
                username = ""
                bio = ""
            }
            .task(id: username) {
                await validUsername(current: current)
            }
            .photosPicker(isPresented: $openGallery, selection: $imgItem)
            .onChange(of: name) { oldValue, newValue in
                if newValue.isEmpty{
                    nameErr = "Please fill in the name"
                }else{
                    nameErr = ""
                }
            }
            .onChange(of: imgItem) { oldValue, newValue in
                Task{
                    guard let newValue = newValue else {return}
                    if let data = try await newValue.loadTransferable(type: Data.self){
                        let uiImage = UIImage(data: data)
                        imgData = uiImage?.jpegData(compressionQuality: 0.8)
                    }
                }
            }
         
        }
        
    }
    
    func validUsername(current: Profile) async {
        usernameErr=""
        guard !isInitialLoad else {return}
        
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmed != current.username.lowercased() else {return}
        guard trimmed.range(of: #"^[a-z0-9_]{3,20}$"#,
                            options: .regularExpression) != nil else {
            usernameErr = "3–20 chars, letters / numbers / _"
            return
        }
        do{
            try await Task.sleep(for: .milliseconds(400))
        }catch{
            return
        }
        
        let available = await isUsernameAvailable(username: trimmed)
        
        guard trimmed == username.trimmingCharacters(in: .whitespaces).lowercased() else { return }
        usernameErr = available ? "" : "That username is already taken"
    }
    
    @ViewBuilder
    func avatarPreview(w: CGFloat, avatarUrl: String?, updatedAt: Date?) -> some View{
        if let data = imgData, let uiImg = UIImage(data: data){
            Image(uiImage: uiImg)
                .resizable()
                .scaledToFill()
                .frame(width: w, height: w)
                .clipShape(.circle)
        }else {
            AvatarView(url: avatarUrl, w: w, version: updatedAt)
        }
    }
}
