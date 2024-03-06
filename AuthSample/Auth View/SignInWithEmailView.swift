//
//  SignInWithEmailView.swift
//  
//
//  Created by Martin Poulsen on 2022-04-25.
//

import SwiftUI
import Firebase

struct SignInWithEmailView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    @State private var validEmail = false
    @State private var showMessageAppleAccount = false
    @State private var showMessageEmailLinkSent = false
    @State private var alertItem: AlertItem? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.accentColor
                    .opacity(colorScheme == .light ? authVM.opacityLightMode : authVM.opacityDarkMode)
                    .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email (personal or work)")
                        .fontWeight(.light)
                        .font(.subheadline)
                        .padding(.top, 20)
                    TextField("julie@example.com", text: $authVM.emailLogIn)
                        .onSubmit {
                            Task {
                                await signUpOrIn()
                            }
                        }
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary, lineWidth: 0.5)
                        )
                        .textContentType(.emailAddress)
                        .onChange(of: authVM.emailLogIn) { 
                            //Check valid email:
                            if authVM.emailLogIn.isValidEmail {
                                validEmail = true
                            } else {
                                validEmail = false
                                showMessageAppleAccount = false
                                showMessageEmailLinkSent = false
                            }
                        }
                        .gesture(
                            DragGesture()
                                .onEnded { _ in
                                    if !authVM.emailLogIn.isEmpty {
                                        authVM.emailLogIn.removeLast()
                                    }
                                }
                        )
                    
                    // Continue - button
                    Button(action: {
                        Task {
                            await signUpOrIn()
                        }
                    }, label: {
                        Text("Continue")
                            .font(.body)
                            .fontWeight(.light)
                            .frame(maxWidth: 500)
                    })
                    .tint(.accentColor)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 20)
                    .disabled(validEmail ? false : true)
                    
                    // Error Message
                    if showMessageAppleAccount {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .frame(height: 120)
                                .foregroundColor(.red)
                                .opacity(0.4)
                            Text("You have already an **Apple Sign In** account on this email address. Log in with Apple instead.")
                                .font(.body)
                                .fontWeight(.light)
                                .padding(.horizontal)
                        }
                        Button(action: {
                            authVM.authState = .signedOut
                        }, label: {
                            Text("Close")
                                .font(.body)
                                .fontWeight(.light)
                                .frame(maxWidth: 500)
                        })
                        .controlSize(.large)
                        .tint(.accentColor)
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.defaultAction)
                    }
                    
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
                                Text("Open Mail app")
                                    .font(.body)
                                    .fontWeight(.light)
                                    .frame(maxWidth: 500)
                            }
                            .controlSize(.large)
                            .tint(.accentColor)
                            .buttonStyle(.borderedProminent)
                            .keyboardShortcut(.defaultAction)
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: 500)
                .padding()
            }
            .navigationTitle("Continue with email")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        authVM.authState = .signedOut
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                }
            }
            .onAppear {
                if authVM.emailLogIn.isValidEmail {
                    validEmail = true
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
                if Auth.auth().isSignIn(withEmailLink: link) {
                    passwordlessSignIn(email: authVM.emailLogIn, link: link) { result in
                        switch result {
                        case let .success(user):
                            let isEmailVerified = user?.isEmailVerified ?? false
                            if isEmailVerified {
                                let userDisplayName = user?.displayName
                                Task {
                                    if userDisplayName == nil {
                                        authVM.displayName = authVM.emailLogIn.emailFirstName()
                                        await authVM.updateDisplayName()
                                    }
                                    authVM.authState = .signedIn
                                }
                            }
                        case .failure(_):
                            let title = String(localized: "An authentication error occurred")
                            let message = String(localized: "The link has expired or has already been used.")
                            alertItem = AlertItem(
                                title: title,
                                message: message
                            )
                        }
                    }
                }
            }
            
        }
        .navigationViewStyle(.stack)
    }
    
    private func passwordlessSignIn(email: String, link: String,
                                    completion: @escaping (Result<User?, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, link: link) { result, error in
            if let error = error {
                print("ⓧ Authentication error: \(error.localizedDescription).")
                completion(.failure(error))
            } else {
                completion(.success(result?.user))
            }
        }
    }
    
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
    
    //Check if the email exists in Firebase, and if it´s with Apple Sign In.
    func signUpOrIn() async {
        let signInProviders = await authVM.checkSignInMethods(emailAddress: authVM.emailLogIn)
        if signInProviders.contains("apple.com") {
            showMessageAppleAccount = true
            validEmail = false
        } else if authVM.emailLogIn.isValidEmail {
            validEmail = false
            // Action: Send email-link
            sendSignInLink()
        }
    }
}

struct SignInWithEmailView_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithEmailView()
            .environmentObject(AuthViewModel())
    }
}
