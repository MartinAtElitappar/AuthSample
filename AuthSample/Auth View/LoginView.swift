//
//  LoginView.swift
//  
//
//  Created by Martin Poulsen on 2022-04-25.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showPrivacyPolicy = false
    @State private var showCoverView = false
    @State private var showLeaveMessageView = false
    @State private var continueAnotherWay = false
    
    @StateObject private var appleService = FirebaseSignInWithAppleService()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.accentColor
                    .opacity(colorScheme == .light ? authVM.opacityLightMode : authVM.opacityDarkMode)
                    .ignoresSafeArea()
                VStack {
                    VStack {
                        Spacer()
                        Text("Auth Sample")
                            .font(.title)
                            .fontWeight(.bold)
                            .kerning(2)
                            .padding(.bottom, 60)
                        Text("Continue to sign up for free. If you already have an account, we'll log you in.")
                            .fontWeight(.light)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    VStack {
                        
                        // Continue with Apple - button
                        Button {
                            authenticate()
                        } label: {
                            HStack {
                                Image(systemName: "applelogo")
                                Text("Continue with Apple")
                            } .frame(maxWidth: 500)
                        }
                        .tint(colorScheme == .dark ? .white : .black)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding(.horizontal)
                        
                        // Continue with email - button
                        Button {
                            authVM.authState = .email
                        } label: {
                            HStack {
                                Image(systemName: "envelope")
                                Text("Continue with email")
                            } .frame(maxWidth: 500)
                        }
                        .tint(colorScheme == .dark ? .white : .black)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .buttonStyle(.bordered)
//                        .controlSize(.large)
                        .padding(.horizontal)
                        
                        // Continue without login - button
                        Button {
                            Task {
                                await signInAnonymously()
                            }
                        } label: {
                            HStack {
                                Text("Continue without login")
                            } .frame(maxWidth: 500)
                        }
                        .tint(colorScheme == .dark ? .white : .black)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .buttonStyle(.bordered)
//                        .controlSize(.large)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        
                        VStack {
                            let space = " "
                            Text("By continuing, you accept our terms of use and")
                                .fontWeight(.light)
                                .font(.footnote)
                            + Text(space) +
                            Text("Privacy Policy")
                                .fontWeight(.medium)
                                .font(.footnote)
                                .foregroundColor(Color.accentColor)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .onTapGesture(perform: {
                            showPrivacyPolicy.toggle()
                        })
                    }
                    .frame(maxWidth: 500)
                }
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicy()
            }
            .fullScreenCover(isPresented: $showCoverView) {
                CoverView()
            }
            .fullScreenCover(isPresented: $showLeaveMessageView) {
                LeaveMessageView()
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            //Workaround: The view don´t update(is not showing CoverView) without this solution
            //Another solution may be to implement @MainActor in the ViewModel
//            showCoverView = authVM.showCoverView
//            showLeaveMessageView = authVM.showLeaveMessageView
        }
    }
    
    // Sign in with Apple - button action
    func authenticate() {
        appleService.signIn { result in
            handleAppleServiceSuccess(result)
        } onFailed: { err in
            handleAppleServiceError(err)
        }
    }
    
    // Sign in with Apple - success action
    func handleAppleServiceSuccess(_ result: FirebaseSignInWithAppleResult) {
        // Saving the result into the database
        // You can only get the appleIDCredential first time you sign up
        let uid = result.uid
        let firstName = result.token.appleIDCredential.fullName?.givenName ?? ""
        let lastName = result.token.appleIDCredential.fullName?.familyName ?? ""
        
        print(uid)
        print("firstName \(firstName)")
        print(lastName)
        
        if let user = Auth.auth().currentUser {
            // Check if firstName is empty
            if !firstName.isEmpty {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = firstName
                changeRequest.commitChanges()
                authVM.displayName = firstName
            }
        }
    }
    
    // Sign in with Apple - Error action
    func handleAppleServiceError(_ error: Error) {
        print(error.localizedDescription)
        // Apple handle message if user has not activated Apple-ID on device
    }
    
    // Sign in Anonumously
    func signInAnonymously() async {
        do {
            try await Auth.auth().signInAnonymously()
            authVM.authState = .signedIn
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
