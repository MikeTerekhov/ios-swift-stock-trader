import SwiftUI

struct PortfolioView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    @ObservedObject var viewModelFav: FavoritesViewModel
    @Binding var isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Portfolio")
                .padding(.leading, 10)
                .fontWeight(.light)
                .foregroundColor(.gray)
            List {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Net Worth")
                        Text("$\(viewModel.netWorth, specifier: "%.2f")")
                            .font(.title2).bold()
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Cash Balance")
                        Text("$\(viewModel.cashBalance, specifier: "%.2f")")
                            .font(.title2).bold()
                    }
                }
                ForEach(viewModel.stocks) { stock in
                    NavigationLink(destination: StockDetailView(symbol: stock.ticker).environmentObject(viewModel).environmentObject(viewModelFav)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(stock.ticker)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text("\(stock.shares) \(stock.shares == 1 ? "share" : "shares")")
                                    .font(.subheadline)
                                    .fontWeight(.light)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 5) {
                                Text("$\(stock.currentPrice * Double(stock.shares), specifier: "%.2f")")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                HStack(spacing: 2) {
                                    
                                    
                                    let averageCostPerShare = stock.totalCost / Double(stock.shares)
                                    let changeInPriceFromTotalCost = (stock.currentPrice - averageCostPerShare) * Double(stock.shares)
                                    let percentChange = calculatePriceChangePercentage(stock: stock)
                                    
                                    let isAnyValueZero = changeInPriceFromTotalCost == 0 || percentChange == 0
                                    
                                    // Price change arrow indicator
                                    Image(systemName: isAnyValueZero ? "minus" : (changeInPriceFromTotalCost >= 0 ? "arrow.up.right" : "arrow.down.right"))
                                                .foregroundColor(isAnyValueZero ? .gray : (changeInPriceFromTotalCost >= 0 ? .green : .red))
            
                                    Text(String(format: "$%.2f", changeInPriceFromTotalCost))
                                                .foregroundColor(isAnyValueZero ? .gray : (changeInPriceFromTotalCost >= 0 ? .green : .red))
                                    
                                    // Opening parenthesis for percentage change
                                    Text("(")
                                        .foregroundColor(isAnyValueZero ? .gray : (percentChange >= 0 ? .green : .red))
                                    
                                    Text(String(format: "%.2f%%", percentChange))
                                                .foregroundColor(isAnyValueZero ? .gray : (percentChange >= 0 ? .green : .red))
                                    
                                    // Closing parenthesis for percentage change
                                    Text(")")
                                        .foregroundColor(isAnyValueZero ? .gray : (percentChange >= 0 ? .green : .red))
                                }
                                .font(.subheadline)
                            }
                        }
                    }
                }
                .onMove { sourceIndices, destinationIndex in
                                   viewModel.stocks.move(fromOffsets: sourceIndices, toOffset: destinationIndex)
                               }

            }
            .listStyle(.plain)
            .environment(\.editMode, isEditing ? .constant(.active) : .constant(.inactive))
            .cornerRadius(10) // Set the corner radius you want
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.loadData()
            }
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
    }
}

func calculatePriceChangePercentage(stock: StockPurchase) -> Double {
    // Calculate the average cost per share
    let averageCostPerShare = stock.totalCost / Double(stock.shares)
    
    // Calculate the change in price from total cost
    let changeInPriceFromTotalCost = (stock.currentPrice - averageCostPerShare) * Double(stock.shares)
    
    // Calculate the total cost of the stock (average cost * number of shares owned)
    let totalCostOfStock = averageCostPerShare * Double(stock.shares)
    
    // Calculate the change in price from total cost percentage
    let changeInPriceFromTotalCostPercentage = (changeInPriceFromTotalCost / totalCostOfStock) * 100
    
    return changeInPriceFromTotalCostPercentage
}

