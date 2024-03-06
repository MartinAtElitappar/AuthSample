//
//  CoverView.swift
//  
//
//  Created by Martin Poulsen on 2022-04-25.
//

import SwiftUI
import Network

struct CoverView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var timerPart: Timer?
    
    //Check internet connection
    let monitor = NWPathMonitor()
    @State private var noInternet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.accentColor
                    .opacity(colorScheme == .light ? 0.5 : 0.5)
                    .ignoresSafeArea()
                Text("Auth Sample")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .kerning(3)
                VStack(spacing: 300) {
                    Spacer()
                    Logotype()
                        .padding(.bottom, 30)
                }
            }
        }
        .navigationViewStyle(.stack)
        .alert(String(localized: "No internet connection", comment: "Alert: No internet connection"), isPresented: $noInternet) {
            Button(String(localized: "OK", comment: "Button OK")) {
                authVM.showCoverView = false
                dismiss()
            }
        }
        .onAppear(perform: {
            checkInternetConnection()
            timerPart = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
                if !noInternet {
                    authVM.showCoverView = false
                    dismiss()
                }
                timer.invalidate()
            }
        })
    }

    func checkInternetConnection() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Print: We have internet connection.")
                noInternet = false
            } else {
                print("Print: NO internet connection.")
                noInternet = true
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}

struct CoverView_Previews: PreviewProvider {
    static var previews: some View {
        CoverView()
            .environmentObject(AuthViewModel())
    }
}
