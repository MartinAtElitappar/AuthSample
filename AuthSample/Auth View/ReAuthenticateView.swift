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
                    .padding(.top, 20)
                    
                    
                    
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
                setStateShowPasswordField()
            }
        }
        .alert(item: $alertItem) { alert -> Alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message)
            )
        }
        .navigationViewStyle(.stack)
    }
    
    // ReAuthenticate - button action
    func reAuthenticate() {
        authenticateAndDelete()
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
    func setStateShowPasswordField() {
        providerApple = true
    }
    
}

struct ReAuthenticateView_Previews: PreviewProvider {
    static var previews: some View {
        ReAuthenticateView()
            .environmentObject(AuthViewModel())
    }
}
