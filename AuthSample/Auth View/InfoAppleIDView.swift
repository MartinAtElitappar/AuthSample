//
//  InfoAppleIDView.swift
//  
//
//  Created by Martin Poulsen on 2022-05-05.
//

import SwiftUI

struct InfoAppleIDView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.accentColor
                    .opacity(colorScheme == .light ? authVM.opacityLightMode : authVM.opacityDarkMode)
                    .ignoresSafeArea()
                VStack {
                    Text("@privaterelay.appleid.com", comment: "Header")
                        .fontWeight(.light)
                        .font(.title)
                        .foregroundColor(.secondary)
                        .padding()
                    Text("If you want to change the email address you have to **delete your account** from the app and **stop using Apple-ID** in the device settings menu. \n\n**1.** Open device Settings, tap your name, Password & Security, Apps Using Apple ID, tap the app, Stop using Apple-ID. \n\n**2.** Delete account in this app. \n\n**3.** You are now ready to sign up with Apple, and can pick email address. \n\n**Warning: All data in the app is deleted when you delete the account**", comment: "Help text")
                        .lineSpacing(5)
                    Spacer()
                }
                .frame(maxWidth: 500)
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct InfoAppleIDView_Previews: PreviewProvider {
    static var previews: some View {
        InfoAppleIDView()
            .environmentObject(AuthViewModel())
    }
}
