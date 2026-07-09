import SwiftUI

class PresentationManager: ObservableObject {
    @Published var showParent: Bool = false
    @Published var showBuyView: Bool = false
    @Published var showSellView: Bool = false
}

struct ProfileStockView: View {
    // for sheets
    @StateObject var manager = PresentationManager()
    
    @ObservedObject var viewModel: StockDetailViewModel
    @EnvironmentObject var viewModelPort: PortfolioViewModel
    @State private var showingTradeView = false

    var body: some View {
        HStack {
            if viewModelPort.stockExists(ticker: viewModel.symbol) {
                VStack(alignment: .leading) {
                    Text("Profile").font(.system(size: 20)).padding(2)
                    let stock = viewModelPort.getStockPurchase(forTicker: viewModel.symbol)!
                    stockDetailsView(stock: stock)
                }
                .font(.system(size: 12))
            } else {
                VStack(alignment: .leading) {
                    Text("Profile").font(.system(size: 20)).padding(2)
                    Text("You have 0 shares of \(viewModel.symbol).")
                        .font(.caption)
                        .padding(2)
                    Text("Start trading!")
                        .font(.caption)
                        .padding(2)
                }
            }
            
            Spacer()
            tradeButton
        }
        .padding()
    }

    private func stockDetailsView(stock: StockPurchase) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Shares Owned: ").bold()
                Text("\(stock.shares)")
            }
            .padding(2)
            HStack {
                Text("Avg. Cost / Share: ").bold()
                Text(String(format: "%.2f", stock.totalCost / Double(stock.shares)))
            }
            .padding(2)
            HStack {
                Text("Total Cost: ").bold()
                Text(String(format: "$%.2f", stock.totalCost))
            }
            .padding(2)
            HStack {
                Text("Change: ").bold()
                Text(String(format: "$%.2f", stock.currentPrice - stock.purchasePrice))
                    .foregroundColor(stock.currentPrice - stock.purchasePrice < 0 ? .red : .green)
            }
            .padding(2)
            HStack {
                Text("Market Value: ").bold()
                Text(String(format: "$%.2f", Double(stock.shares) * stock.currentPrice))
                    .foregroundColor(stock.currentPrice - stock.purchasePrice < 0 ? .red : .green)
            }
            .padding(2)
        }
    }

    private var tradeButton: some View {
        Button(action: {
            print("Trade button tapped")
            manager.showParent = true
        }) {
            Text("Trade")
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 40)
                .background(Color.green)
                .cornerRadius(20)
        }
        .sheet(isPresented: $manager.showParent) {
            TradeStockView(funds: viewModelPort.cashBalance, sharePrice: viewModel.currPrice!, ticker: viewModel.symbol, compName: viewModel.companyName, manager: manager).environmentObject(viewModelPort)
        }
    }
}
