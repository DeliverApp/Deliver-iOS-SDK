//
//  SignInViewModel.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 22/11/2024.
//

import Combine
import Foundation


internal class SignInViewModel: ObservableObject {
    
    
    @Published internal var email: String = ""
    @Published internal var otp: String = ""
    
    @Published internal var isLoading: Bool = false
    
    @Published internal var error: Bool = false
    
    private var onOpenScannerHandler: (() -> Void)?
    private var onLogginEndHandler: (() -> Void)?
    
    
    init() {
        let credentials = getCredentials()
        if let email = credentials.username,
           let otp = credentials.password {
            self.email = email
            self.otp = otp
        }
    }
    
    @discardableResult
    func onOpenScanner(_ handler: (() -> Void)?) -> Self {
        onOpenScannerHandler = handler
        return self
    }
    
    @discardableResult
    func onLogginEnd(_ handler: (() -> Void)?) -> Self {
        onLogginEndHandler = handler
        return self
    }
    
    
    func receiveScan(_ scan: String) {
        self.email = scan
    }
    
    func openScanner() {
        onOpenScannerHandler?()
    }
    
    @MainActor func signIn() {
        self.isLoading = true
        Task {
            do {
                let token = try await AuthAPI().signIn(email: self.email, otp: self.otp)
                Context.shared.acccessToken = token
                self.saveCredentials(username: self.email, password: self.otp)
                let user = try await UserAPI().me()
                Context.shared.user = user
                
                self.isLoading = false
                onLogginEndHandler?()
            }
            catch {
                self.error = true
                self.isLoading = false
            }
        }
    }
    
    private func saveCredentials(username: String, password: String) {
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")
    }
    
    func getCredentials() -> (username: String?, password: String?) {
        let username = UserDefaults.standard.string(forKey: "username")
        let password = UserDefaults.standard.string(forKey: "password")
        return (username, password)
    }
}
