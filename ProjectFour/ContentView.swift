//
//  ContentView.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/12/24.
//

import SwiftUI

struct ContentView: View {
    @State private var showingStartup = true  // Initially, we are showing the startup screen
    @State private var isEditing = false  // Use @State here

    var body: some View {
        VStack {
            if showingStartup {
                StartupView(isShowing: $showingStartup)
            } else {
                StocksView(isEditing: $isEditing)
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
