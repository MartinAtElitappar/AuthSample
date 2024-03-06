//
//  Logotype.swift
//  
//
//  Created by Martin Poulsen on 2022-04-25.
//

import SwiftUI

struct Logotype: View {
    var body: some View {
        //Logotype Elitappar
        HStack {
            Spacer()
            Text("created by", comment: "created by Elitappar, part of Logotype-tag")
                .font(.caption)
                .fontWeight(.thin)
                .foregroundColor(Color.primary)
            HStack(spacing: 0) {
                // Using let because we dont wont to translate the Logotype
                let elit = "Elit"
                Text(elit)
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(Color.primary)
                    .opacity(1)
                    .shadow(color: .secondary, radius: 1)
                // Using let because we dont wont to translate the Logotype
                let appar = "appar"
                Text(appar)
                    .font(.callout)
                    .fontWeight(.thin)
                    .foregroundColor(Color.primary)
                    .opacity(1)
                    .shadow(color: .secondary, radius: 1)
            }
            Spacer()
        }
    }
}

struct Logotype_Previews: PreviewProvider {
    static var previews: some View {
        Logotype()
    }
}
