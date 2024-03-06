//
//  ProfileView.swift
//  
//
//  Created by Martin Poulsen on 2022-04-30.
//

import SwiftUI
import Firebase

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showReAuthenticateView = false
    @State private var showDoneButton = false
    @State private var displayName = ""
    @State private var showInfoAppleID = false
    @State private var emailPrivateRelayAppleID = false
    @State private var showAlert = false
    @State private var showProgressView = false
    @State private var isAnonymous = false
    let pasteboard = UIPasteboard.general

    var body: some View {
        NavigationView {
            ZStack {
                Color.accentColor
                    .opacity(colorScheme == .light ? authVM.opacityLightMode : authVM.opacityDarkMode)
                    .ignoresSafeArea()
                VStack {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.secondary)
                    Text(displayName.isEmpty ? "name?" : "\(displayName)")
                        .font(.title)
                        .fontWeight(.light)
                    if !isAnonymous {
                        Text("\(authVM.emailAddress)")
                            .font(.footnote)
                            .fontWeight(.light)
                    }
                    VStack(alignment: .leading) {
                        
                        // Display name
                        VStack(alignment: .leading) {
                            Text("Display name")
                                .font(.footnote)
                                .fontWeight(.light)
                                .padding(.top, 30)
                            TextField("Enter display name", text: $displayName)
                                .textFieldStyle(.roundedBorder)
                                .disableAutocorrection(true)
                                .onChange(of: displayName) {
                                    if authVM.displayName != displayName {
                                        showDoneButton = true
                                    } else {
                                        showDoneButton = false
                                    }
                                }
                                .gesture(
                                    DragGesture()
                                        .onEnded { _ in
                                            if !displayName.isEmpty {
                                                displayName.removeLast()
                                            }
                                        }
                                )
                        }
                        
                        // Email address
                        if !isAnonymous {
                            HStack {
                                Text("Email address")
                                    .font(.footnote)
                                    .fontWeight(.light)
                                Button {
                                    pasteboard.string = authVM.emailAddress
                                } label: {
                                    Image(systemName: "doc.on.clipboard")
                                }
                                Button {
                                    if emailPrivateRelayAppleID {
                                        showInfoAppleID.toggle()
                                    }
                                } label: {
                                    if emailPrivateRelayAppleID {
                                        Image(systemName: "info.circle")
                                    }
                                }
                            }
                            .padding(.top, 20)
                            Text("\(authVM.emailAddress)")
                                .fontWeight(.light)
                                .padding(.top, 1)
                        }
                            
                        Spacer()
                        if showProgressView {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .scaleEffect(3)
                                Spacer()
                            }
                            .padding(.bottom, 200)
                        }
                    }
                }
                .frame(maxWidth: 500)
                .padding()
            }
            .onAppear {
                displayName = authVM.displayName
                if authVM.emailAddress.contains("privaterelay.appleid.com") {
                    emailPrivateRelayAppleID = true
                }
                if let isA = Auth.auth().currentUser?.isAnonymous {
                    isAnonymous = isA
                }
            }
            .navigationTitle("Your account")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showInfoAppleID) {
                InfoAppleIDView()
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    // Delete account - button
                    Button {
                        showAlert.toggle()
                    } label: {
                        Text("Delete account")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding()
                    
                    // Logout - button
                    if !isAnonymous {
                        Button {
                            authVM.logout()
                        } label: {
                            Text("Logout")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding()
                    }
                }
                
                // Cancel - button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                
                // Done - button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            authVM.displayName = displayName
                            dismiss()
                        }
                    } label: {
                        Text(showDoneButton ? "Done" : "")
                            .fontWeight(.bold)
                    }
                }
            }
            .alert("Delete account?", isPresented: $showAlert, actions: {
                // 1
                  Button("Cancel", role: .cancel, action: {})

                  Button("Delete account", role: .destructive, action: {
                      Task {
                          await deleteAccount()
                      }
                  })
                }, message: {
                  Text("Your teams will be deleted!")
                })
        }
        .navigationViewStyle(.stack)
    }
    
    func deleteAccount() async {
        showProgressView = true
        authVM.emailLogIn = authVM.emailAddress
        if isAnonymous {
            // Logout
            authVM.showLeaveMessageView = true
            authVM.logout()
        } else {
            // Reautenticate
            authVM.authState = .reAuthenticate
        }
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
