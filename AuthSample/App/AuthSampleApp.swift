//
//  ElitDrawTheWordApp.swift
//  ElitDrawTheWord
//
//  Created by Martin Poulsen on 2022-05-11.
//

import SwiftUI
import Firebase

@main
struct AuthSampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var authVM = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch authVM.authState {
                case .undefined:
                    ProgressView()
                case .signedIn:
                    HomeView()
                        .onAppear {
                            authVM.startHomeViewListeners()
                        }
                case .signedOut:
                    LoginView()
                case .reAuthenticate:
                    ReAuthenticateView()
                }
            }
            .environmentObject(authVM)
            
        }
    }
}
