//
//  AboutView.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/29/24.
//

import SwiftUI

struct AboutView: View {
    @ObservedObject var viewModel: StockDetailViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("About")
                .font(.system(size: 20))
            HStack {
                VStack(alignment: .leading) {
                    Text("IPO Start Date:").bold().padding(.vertical, 5)
                    Text("Industry:").bold().bold().padding(.vertical, 5)
                    Text("Webpage:").bold().bold().padding(.vertical, 5)
                    Text("Company Peers:").bold().padding(.vertical, 5)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text(viewModel.ipo.map { String($0) } ?? "N/A").padding(.vertical, 5)
                    Text(viewModel.finnhubIndustry.map { String($0) } ?? "N/A").padding(.vertical, 5)
                    webpageLink.padding(.vertical, 5)
                    PeersView(peers: viewModel.peers).padding(.vertical, 5)
                }
            }
            .font(.system(size: 12))
        }
        .padding()
    }

    private var webpageLink: some View {
        Group {
            if let url = viewModel.weburl, let urlComponent = URL(string: url) {
                Link(url, destination: urlComponent)
                    .foregroundColor(.blue)
            } else {
                Text("N/A")
            }
        }
    }
}

