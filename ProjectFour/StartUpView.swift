//
//  StartUpView.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/12/24.
//

import SwiftUI

struct StartupView: View {
    @Binding var isShowing: Bool

    var body: some View {
        VStack {
            Image("StartUp")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            
        }
        .onAppear {
            // Simulate a loading process with a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isShowing = false  // After loading, show the ContentView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
    }
}
