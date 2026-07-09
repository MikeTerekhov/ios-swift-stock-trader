import SwiftUI

struct StockDetailView: View {
    @StateObject private var viewModel: StockDetailViewModel
    @EnvironmentObject var viewModelFav: FavoritesViewModel
    @EnvironmentObject var viewModelPort: PortfolioViewModel
    @State private var showingTradeView = false
    
    // FAV toasts
    @State private var addFavToast = false
    @State private var remFavToast = false
    
    init(symbol: String) {
        _viewModel = StateObject(wrappedValue: StockDetailViewModel(symbol: symbol, stockService: StockService.shared))
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Fetching Data...")
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .font(.system(size: 12))
            }
            else {
                ScrollView {
                    HeaderView(viewModel: viewModel)
                    ChartSelectorView(viewModel: StockDetailViewModel(symbol: viewModel.symbol, stockService: .shared))
                    ProfileStockView(viewModel: viewModel).environmentObject(viewModelPort)
                    StatsView(viewModel: viewModel)
                    AboutView(viewModel: viewModel)
                    InsightsView(query: viewModel.symbol, compName: viewModel.companyName)
                    ScrollView {
                        RecommendationsView(ticker: viewModel.symbol).frame(height: 350)
                    }
                    .padding()
                    ScrollView {
                        EarningsView(ticker: viewModel.symbol).frame(height: 350)
                    }
                    .padding()
                    NewsView(ticker: viewModel.symbol, compName: viewModel.companyName)
                }
                .padding()
            }
        }
        .navigationBarItems(trailing: trailingButton)
        .onAppear {
            viewModel.startUpdatingPrice()
        }
        .onDisappear {
            viewModel.stopUpdatingPrice()
        }
        // Favorites TOAST
        .overlay(
            VStack {
                Spacer() // Push the message to the bottom
                if addFavToast || remFavToast {
                    Text(addFavToast ? "Adding \(viewModel.symbol) to Favorites" : "Removing \(viewModel.symbol) from Favorites")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(20)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 2.0), value: addFavToast || remFavToast)
                }
            }.padding()
            ,
            alignment: .bottom // Ensure it's aligned to the bottom of the overlay's bounds
        )
    }
    
    var trailingButton: some View {
            Button(action: {
                Task {
                    await FavButton(ticker: viewModel.symbol)
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(!viewModelFav.isFav(ticker: viewModel.symbol) ? .white : .blue)
                    .background(!viewModelFav.isFav(ticker: viewModel.symbol) ? Color.blue : Color.clear)
                    .clipShape(Circle())
            }
            .foregroundColor(.blue)
    }
    
    func FavButton(ticker: String) async -> Void {
        if (viewModelFav.isFav(ticker: ticker)) {
            await viewModelFav.deleteFavorite(ticker: ticker)
            
            remFavToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                remFavToast = false
            }
        }
        else {
            let myFavorite = Favorite(
                ticker: viewModel.symbol,
                corpName: viewModel.companyName,
                highPrice: viewModel.currPrice!,
                change: viewModel.priceChange!,
                percentChange: viewModel.percentChange!
            )
            viewModelFav.addFavorite(favorite: myFavorite)
            
            addFavToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                addFavToast = false
            }
        }
    }
}

