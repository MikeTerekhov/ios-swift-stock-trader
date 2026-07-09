//
//  ChartSelectorView.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/18/24.
//

import SwiftUI

//struct ChartSelectorView: View {
//    @State public var selectedChart: ChartType = .hourly
//    @StateObject public var viewModel: StockDetailViewModel
//
//    enum ChartType {
//        case hourly, historical
//    }
//
//    var body: some View {
//        VStack {
//            
//            Group {
//                switch selectedChart {
//                case .hourly:
//                    if let chartDates1 = generateChartDates() {
//                        ChartOneView(ticker: viewModel.symbol, fromDate: chartDates1.from, toDate: chartDates1.to)
//                            .frame(height: 350)
//                    }
//                case .historical:
//                    let from = getDateTwoYearsAgo()
//                    let to = getTodaysDate()
//                    ChartTwoView(ticker: viewModel.symbol, fromDate: from, toDate: to)
//                        .frame(height: 350)
//                }
//            }
//            .padding(.bottom)
//            
//            Picker("Chart Type", selection: $selectedChart) {
//                Image(systemName: "calendar") // Replace with your own image or system image
//                    .tag(ChartType.hourly)
//                Image(systemName: "calendar") // Replace with your own image or system image
//                    .tag(ChartType.historical)
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            .padding()
//        }
//    }
//}
//
//#Preview {
//    ChartSelectorView(viewModel: StockDetailViewModel(symbol: "AAPL"))
//}


enum ChartType: String, CaseIterable, Identifiable {
    case hourly, historical
    
    var id: String { self.rawValue }
    
    var displayImage: String {
        switch self {
        case .hourly:
            return "chart.xyaxis.line" // System image name or your custom image
        case .historical:
            return "clock.fill" // System image name or your custom image
        }
    }
    
    var labelText: String {
        switch self {
        case .hourly:
            return "Hourly"
        case .historical:
            return "Historical"
        }
    }
}

struct ChartSelectorView: View {
    @State private var selectedChart: ChartType = .hourly
    @StateObject var viewModel: StockDetailViewModel

    var body: some View {
        VStack {
            // Custom Segmented Picker
            // Chart View based on selection
            Group {
                switch selectedChart {
                case .hourly:
                    if let chartDates1 = generateChartDates() {
                        ChartOneView(ticker: viewModel.symbol, fromDate: chartDates1.from, toDate: chartDates1.to)
                            .frame(height: 350)
                    }
                case .historical:
                    let from = getDateTwoYearsAgo()
                    let to = getTodaysDate()
                    ChartTwoView(ticker: viewModel.symbol, fromDate: from, toDate: to)
                        .frame(height: 350)
                }
            }
            .frame(height: 320)
            
            HStack {
                ForEach(ChartType.allCases) { type in
                    VStack {
                        Image(systemName: type.displayImage)
                            .frame(width: 150, height: 10)
                        Text(type.labelText)
                            .font(.system(size: 10))
                    }
                    .padding()
                    .background(Color.white)
                    .foregroundColor(selectedChart == type ? Color.blue : Color.gray)
                    .onTapGesture {
                        selectedChart = type
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
