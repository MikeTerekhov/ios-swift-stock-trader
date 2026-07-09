//
//  PeersView.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/19/24.
//

import SwiftUI

struct PeersView: View {
    let peers: [String]
    
    @StateObject var portfolioViewModel = PortfolioViewModel()
    @StateObject var favoritesViewModel = FavoritesViewModel()

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(peers.indices, id: \.self) { index in
                    NavigationLink(destination: StockDetailView(symbol: peers[index])
                        .environmentObject(portfolioViewModel) // Pass `portfolioViewModel` as an environment object
                        .environmentObject(favoritesViewModel)
                    ) {
                        Text(peers[index])
                            .foregroundColor(.blue)
                        + Text(index < peers.count - 1 ? "," : "")
                            .foregroundColor(.blue)
                        
                        NavigationLink(destination: StockDetailView(symbol: peers[index])) {
                            EmptyView()
                        }
                        .frame(width: 0)
                        .opacity(0)
                    }
                }
            }
        }
    }
}


//NavigationLink(destination: StockDetailView(symbol: peer)) {
