//
//  HeaderView.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/29/24.
//

import SwiftUI

struct HeaderView: View {
    @ObservedObject var viewModel: StockDetailViewModel

    var body: some View {
        VStack (alignment: .leading) {
            Text(viewModel.symbol)
                .font(.title)
                .fontWeight(.bold)
            HStack {
                Text(viewModel.companyName)
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundColor(.gray)
                Spacer()
                AsyncImage(url: URL(string: viewModel.logo ?? "")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 1))
                } placeholder: {
                    ProgressView()
                }
            }
            HStack {
                Text("$\(String(format: "%.2f", viewModel.currPrice ?? 0))")
                    .font(.title)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: viewModel.priceChange ?? 0 >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .foregroundColor(viewModel.priceChange ?? 0 >= 0 ? .green : .red)
                Text("\(viewModel.priceChange ?? 0 >= 0 ? "+$" : "-$")\(abs(viewModel.priceChange ?? 0), specifier: "%.2f") (\(viewModel.priceChange ?? 0 >= 0 ? "+" : "")\(viewModel.percentChange ?? 0, specifier: "%.2f")%)")
                    .foregroundColor(viewModel.priceChange ?? 0 >= 0 ? .green : .red)
            }
        }
        .padding()
    }
}

