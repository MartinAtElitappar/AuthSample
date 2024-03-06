//
//  AuthViewModel.swift
//  
//
//  Created by Martin Poulsen on 2022-04-25.
//

import SwiftUI
import Combine
import Firebase

class AuthViewModel: ObservableObject {
    @AppStorage("muteHaptics") var muteHaptics = false
    @AppStorage("muteKeyboardSound") var muteKeyboardSound = false
    @Published var showCoverView = true
    @Published var showProfile = false
    @Published var showLeaveMessageView = false
    @Published var opacityDarkMode = 0.3
    @Published var opacityLightMode = 0.1
    @Published var user: User? = nil
    @Published var authState: authState = .undefined
    @Published var emailAddress = ""
    @AppStorage("emailLogIn") var emailLogIn = ""
    @Published var displayName = ""
    @Published var isEmailVerified: Bool? = nil
    @Published var currentUserUid: String? = nil
    
    @Published var errorMessage: String?
    
    var cancellables: Set<AnyCancellable> = []
    
    init(shouldLogoutUponLaunch: Bool = false) {
        startAuthListener()
        logoutIfNeeded(shouldLogoutUponLaunch)
    }
    
    // Remove all listeners
    func removeAllListeners() {
        print("Remove all listeners")
    }
    
    // Start homeView listeners
    func startHomeViewListeners() {
        print("Start homeView listeners")
    }
    
    private func startAuthListener() {
        let promise = AuthListener.listen()
        promise.sink { _ in } receiveValue: { result in
            self.user = result.user
            self.currentUserUid = result.user?.uid
            // Use currentUserUid when the user has logged in anonymously
            if let currentUser = self.currentUserUid {
                self.emailAddress = result.user?.email ?? currentUser
            }
            let firstName = result.user?.displayName
            if firstName != nil {
                self.displayName = firstName!
            }
            self.isEmailVerified = result.user?.isEmailVerified
            self.authState = result.user != nil ? .signedIn : .signedOut
        }.store(in: &cancellables)
    }
    
    private func logoutIfNeeded(_ shouldLogoutUponLaunch: Bool) {
        if shouldLogoutUponLaunch {
            print("AuthState: logging out upon launch...")
            let promise = authLogout()
            promise.sink { result in
                switch result {
                case .finished:
                    break
                case .failure(let err):
                    print(err.localizedDescription)
                }
            } receiveValue: { success in
                print("Logged out: \(success)")
            }.store(in: &cancellables)
        }
    }
    
    func logout() {
        do {
        try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func authLogout() -> Future<Bool, Error> {
        return Future<Bool, Error> { completion in
            do {
                try Auth.auth().signOut()
                completion(.success(true))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    //Check if account exist, and providers
    func checkSignInMethods(emailAddress: String) async -> [String] {
        var signInMethods = [String]()
        do {
        signInMethods = try await Auth.auth().fetchSignInMethods(forEmail: emailAddress)
        } catch {
            print(error.localizedDescription)
        }
        return signInMethods
    }
    
    func updateDisplayName() async {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        do {
        try await changeRequest?.commitChanges()
        } catch {
            print("")
            print(error.localizedDescription)
            print("")
            /* FIRAuthErrorCodeUserTokenExpired
            Invalid user token detected, user is automatically signed out.
            Indicates the current user’s token has expired, for example,
            the user may have changed account password on another device.
            You must prompt the user to sign in again on this device.
            The authState will be set to .Logout */
        }
    }
  
}

