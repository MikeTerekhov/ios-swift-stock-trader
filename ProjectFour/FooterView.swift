//
//  FooterView.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/17/24.
//

import SwiftUI

struct FooterView: View {
    var body: some View {
        Text("Powered by Finnhub.io")
            .font(.caption)
            .fontWeight(.light)
            .foregroundColor(.gray)
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
            .padding(.horizontal, 20)
            .onTapGesture {
                openFinnhubWebsite()
            }
    }
    
    func openFinnhubWebsite() {
        guard let url = URL(string: "https://www.finnhub.io") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

#Preview {
    FooterView()
}
