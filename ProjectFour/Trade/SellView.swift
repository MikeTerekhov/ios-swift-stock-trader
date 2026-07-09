//
//  SellView.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/28/24.
//

import SwiftUI

struct SellView: View {
    @ObservedObject var manager: PresentationManager
    
    var numberOfShares: Int
    var ticker: String

    var body: some View {
        VStack {
            Spacer()
            
            Text("Congratulations!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("You have successfully sold \(numberOfShares) \(numberOfShares == 1 ? "share" : "shares") of \(ticker).")
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .font(.system(size: 15))
            
            Spacer()
            
            Button(action: {
                manager.showSellView = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    manager.showParent = false
                }
            }) {
                Text("Done")
                    .foregroundColor(.green)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(30) // Use a large enough corner radius to get the capsule shape
                    .padding(.horizontal)
                    .padding(.vertical, 10) // Adjust vertical padding as needed
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green)
        .ignoresSafeArea() // Make sure it extends to the top and bottom edges of the screen
    }
}


