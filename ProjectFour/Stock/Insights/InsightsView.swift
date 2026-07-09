//
//  InsightsView.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/19/24.
//

import SwiftUI

struct InsightsView: View {
    @StateObject var viewModel = InsightsViewModel()
    let query: String
    let compName: String
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                VStack(alignment: .leading) {
                    Text("Insights")
                        .font(.system(size: 20))
                    
                    VStack(alignment: .center) {
                        Text("Insider Sentiments")
                            .font(.system(size: 20))
                            .padding(5)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(compName).bold()
                                Divider()
                                Text("Total").bold()
                                Divider()
                                Text("Positive").bold()
                                Divider()
                                Text("Negative").bold()
                                Divider()
                            }
                            VStack(alignment: .leading) {
                                Text("MSPR").bold()
                                Divider()
                                Text("\(viewModel.totalMSPR, specifier: "%.2f")")
                                Divider()
                                Text("\(viewModel.totalPositiveMSPR, specifier: "%.2f")")
                                Divider()
                                Text("\(viewModel.totalNegativeMSPR, specifier: "%.2f")")
                                Divider()
                            }
                            VStack(alignment: .leading) {
                                Text("Change").bold()
                                Divider()
                                Text("\(viewModel.totalChange, specifier: "%.2f")")
                                Divider()
                                Text("\(viewModel.totalPositiveChange, specifier: "%.2f")")
                                Divider()
                                Text("\(viewModel.totalNegativeChange, specifier: "%.2f")")
                                Divider()
                            }
                        }
                        .font(.system(size: 12))
                    }
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.fetchInsights(query: query)
        }
    }
}

