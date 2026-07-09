//
//  StatsView.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/29/24.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: StockDetailViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Stats")
                .font(.system(size: 20))
            HStack {
                VStack {
                    statsDetail(title: "High Price:", value: viewModel.highPrice.map { String(format: "$%.2f", $0) } ?? "N/A")
                    statsDetail(title: "Low Price:", value: viewModel.lowPrice.map { String(format: "$%.2f", $0) } ?? "N/A")
                }

                VStack {
                    statsDetail(title: "Open Price:", value: viewModel.openPrice.map { String(format: "$%.2f", $0) } ?? "N/A")
                    statsDetail(title: "Prev. Close:", value: viewModel.prevClose.map { String(format: "$%.2f", $0) } ?? "N/A")
                }
            }
        }
        .padding()
        .font(.system(size: 12))
    }

    @ViewBuilder
    private func statsDetail(title: String, value: String) -> some View {
        HStack {
            Text(title).bold()
            Spacer()
            Text(value)
        }
        .padding(5)
    }
}

