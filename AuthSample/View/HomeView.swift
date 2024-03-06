//
//  HomeView.swift
//  
//
//  Created by Martin Poulsen on 2022-04-20.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.accentColor
                    .opacity(colorScheme == .light ? authVM.opacityLightMode : authVM.opacityDarkMode)
                    .ignoresSafeArea()
                VStack {
                    Text("Home View")
                    
                }
            }
            .navigationTitle("Elit draw the word")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        authVM.showProfile.toggle()
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $authVM.showProfile) {
            ProfileView()
        }
        .fullScreenCover(isPresented: $authVM.showCoverView) {
            CoverView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
    }
}
