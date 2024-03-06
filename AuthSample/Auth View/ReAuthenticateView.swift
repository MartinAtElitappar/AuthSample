//
//  ReAuthenticateView.swift
//  
//
//  Created by Martin Poulsen on 2022-05-03.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ReAuthenticateView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    @State private var showMessageEmailLinkSent = false
    @State private var providerApple = true
    @State private var alertItem: AlertItem? = nil
    
    @StateObject private var appleService = FirebaseSignInWithAppleService()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.accentColor
                    .opacity(colorScheme == .light ? authVM.opacityLightMode : authVM.opacityDarkMode)
                    .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 5) {
                    Text("**Delete account** \"\(authVM.emailAddress)\"")
                        .fontWeight(.light)
                        .font(.subheadline)
                        .padding(.bottom, 10)
                    
                    // Verify & Delete account - button
                    Button(action: {
                        reAuthenticate()
                    }, label: {
                        Text(providerApple ? "Verify & Delete account" : "Send verify link")
                            .font(.body)
                            .fontWeight(.light)
                            .frame(maxWidth: 500)
                    })
                    .tint(.red)
                    .buttonStyle(.borderedProminent)
                    .disabled(showMessageEmailLinkSent ? true : false)
                    .padding(.top, 20)
                    
                    // Success Message - Email link sent
                    if showMessageEmailLinkSent {
                        VStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .frame(height: 100)
                                    .foregroundColor(.secondary)
                                    .opacity(0.4)
                                Text("Sign In link has been sent to your inbox. Check your inbox and spam on this device!")
                                    .font(.body)
                                    .fontWeight(.light)
                                    .padding(.horizontal)
                            }
                            Button {
                                openURL(URL(string: "message://")!)
                            } label: {
                                Text("Open Mail app & Delete account")
                                    .font(.body)
                                    .fontWeight(.light)
                                    .frame(maxWidth: 500)
                            }
                            .controlSize(.large)
                            .tint(.red)
                            .buttonStyle(.borderedProminent)
                            .keyboardShortcut(.defaultAction)
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: 500)
                .padding()
            }
            .navigationTitle("Verify")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        authVM.authState = .signedIn
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                }
            }
            // Check provider
            .task {
                await setStateShowPasswordField()
            }
        }
        .alert(item: $alertItem) { alert -> Alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message)
            )
        }
        .onOpenURL { url in
            let link = url.absoluteString
            let credential = EmailAuthProvider.credential(withEmail: authVM.emailAddress, link: link)
            Auth.auth().currentUser?.reauthenticate(with: credential) { authData, error in
                if error != nil {
                    // Error occurred during re-authentication.
                    let title = String(localized: "An authentication error occurred")
                    let message = String(localized: "The link has expired or has already been used.")
                    alertItem = AlertItem(
                        title: title,
                        message: message
                    )
                    return
                }
                // The user was successfully re-authenticated.
                Task {
                    await deleteUser()
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // Send Sign In link
    private func sendSignInLink() {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(
            string: "https://elitdrawtheword.elitappar.com/log"
        )
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        Auth.auth().useAppLanguage()
        Auth.auth().sendSignInLink(toEmail: authVM.emailLogIn,
                                   actionCodeSettings: actionCodeSettings) { error in
            if error != nil {
                let title = String(localized: "Send error")
                let message = String(localized: "The Sign In link could not be sent.")
                alertItem = AlertItem(
                    title: title,
                    message: message
                )
            } else {
                showMessageEmailLinkSent = true
            }
        }
    }
    
    // ReAuthenticate - button action
    func reAuthenticate() {
        if !providerApple {
            sendSignInLink()
        } else {
            authenticateAndDelete()
        }
    }
    
    // Authenticate and delete
    func authenticateAndDelete() {
        appleService.signIn { result in
            Task {
                await deleteUser()
            }
        } onFailed: { err in
            print(err.localizedDescription)
        }
    }
    
    // Delete user
    @Sendable func deleteUser() async {
        if let user = Auth.auth().currentUser {
            do {
                authVM.showLeaveMessageView = true
                try await user.delete()
            } catch {
                // An error happened.
                print(error.localizedDescription)
            }
        }
    }
    
    // Check provider
    func setStateShowPasswordField() async {
        if let user = Auth.auth().currentUser {
            let providers = await authVM.checkSignInMethods(emailAddress: user.email ?? "")
            if providers.contains("apple.com") {
                providerApple = true
            } else {
                providerApple = false
            }
        }
    }
    
}

struct ReAuthenticateView_Previews: PreviewProvider {
    static var previews: some View {
        ReAuthenticateView()
            .environmentObject(AuthViewModel())
    }
}
