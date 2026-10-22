//
//  AuthManager.swift
//  PolyuSell
//
//  Created by HUAHUA on 22/10/2026.
//

import Foundation
import Supabase

@Observable
class AuthManager{
    var isLogin = false
    var currentUser: User?
    var currentProfile: Profile?
    var isRestoring = true
    private var authTask: Task<Void, Never>?
    init(){
        authTask = Task{await listenToAuthChanges()}
    }
    deinit{
        authTask?.cancel()
    }
    func signUp(name: String, username: String, email: String, password: String, passwordConfirm: String) async throws -> String?{
        let name     = name.trimmingCharacters(in: .whitespaces)
        let username = username.trimmingCharacters(in: .whitespaces).lowercased()
        let email    = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !name.isEmpty && !email.isEmpty && !password.isEmpty && !passwordConfirm.isEmpty else {
            return "please fill in all the fields"
        }
        
        guard username.range(of: #"^[a-z0-9_]{3,20}$"#,
                             options: .regularExpression) != nil else {
            return "Username must be 3–20 chars (letters, numbers, _)"
        }
        
        guard await isUsernameAvailable(username: username) else {
            return "That username is already taken — try another"
        }
        let emailRegex = #/^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/#
        guard (try? emailRegex.wholeMatch(in: email)) != nil else {
            return "Email format not valid"
        }
        guard await isEmailAvailable(email: email) else {
            return "That email is already registered — try signing in instead"
        }
        guard password == passwordConfirm else {
            return "Passwords do not match"
        }
        guard password.count >= 6 else {
            return "Password must be at least 6 characters"
        }
        
        let response = try await supabase.auth.signUp(
            email: email, password: password,
            data: ["name" : .string(name), "username": .string(username)]
        )
        if response.session == nil{
            return "We sent a confirmation link to \(email). Please verify before signing in."
        }
        return nil
        
        func isUsernameAvailable(username: String) async -> Bool{
            do{
                let rows: [Profile] = try await supabase
                    .from("profiles")
                    .select()
                    .eq("username", value: username)
                    .limit(1)
                    .execute()
                    .value
                return rows.isEmpty
            }catch{
                return true
            }
        }
        
        func isEmailAvailable(email: String) async -> Bool{
            do{
                let rows: [Profile] = try await supabase
                    .from("profiles")
                    .select()
                    .eq("email", value: email)
                    .limit(1)
                    .execute()
                    .value
                return rows.isEmpty
            }catch{
                return true
            }
        }
    }
    
    
    
    func signInWithGoogle() async throws -> String?{
        do {
            try await supabase.auth.signInWithOAuth(
                provider: .google,
                redirectTo: URL(string: "polyusell://login-callback")!,
                queryParams: [
                    (name: "prompt", value: "select_account")
                ]
            )
        } catch {
            return error.localizedDescription
        }
        return nil
    }
    
    func listenToAuthChanges() async{
        for await (event, session) in supabase.auth.authStateChanges {
            switch event{
            case .initialSession, .signedIn, .tokenRefreshed:
                self.isLogin = session != nil
                self.currentUser = session?.user
                
            case .signedOut, .userDeleted:
                currentUser = nil
                isLogin = false
                
            default:
                break
            }
            if event == .initialSession{
                isRestoring = false
            }
        }
    }
    
  
    
}
