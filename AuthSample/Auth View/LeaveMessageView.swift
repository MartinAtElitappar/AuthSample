//
//  LeaveMessageView.swift
//  
//
//  Created by Martin Poulsen on 2022-05-03.
//

import SwiftUI

struct LeaveMessageView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var timerPart: Timer?
    
    var body: some View {
        ZStack {
            Color.accentColor
                .opacity(colorScheme == .light ? 0.5 : 0.5)
                .ignoresSafeArea()
            Text("Sorry to see you go. You'll be missed.")
                .foregroundColor(.white)
                .font(.largeTitle)
                .fontWeight(.light)
                .kerning(3)
                .multilineTextAlignment(.center)
                .padding(30)
            VStack(spacing: 300) {
                Spacer()
                Logotype()
                    .padding(.bottom, 30)
            }
        }
        .onAppear(perform: {
            timerPart = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { timer in
                authVM.showLeaveMessageView = false
                dismiss()
                timer.invalidate()
            }
        })
    }
}

struct LeaveMessageView_Previews: PreviewProvider {
    static var previews: some View {
        LeaveMessageView()
            .environmentObject(AuthViewModel())
    }
}
