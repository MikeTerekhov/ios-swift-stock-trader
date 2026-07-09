import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: FavoritesViewModel
    @ObservedObject var viewModelPort: PortfolioViewModel
    @Binding var isEditing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("FAVORITES")
                .padding(.leading, 10)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            List {
                ForEach(viewModel.favorites) { favorite in
                    NavigationLink(destination: StockDetailView(symbol: favorite.ticker).environmentObject(viewModel).environmentObject(viewModelPort)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(favorite.ticker)
                                    .fontWeight(.bold)
                                Text(favorite.corpName)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(String(format: "$%.2f", favorite.highPrice))
                                    .fontWeight(.bold)
                                HStack(spacing: 3) {
                                    Image(systemName: favorite.change >= 0 ? "arrow.up.right" : "arrow.down.right")
                                        .foregroundColor(favorite.change >= 0 ? .green : .red)
                                    Text(String(format: "%+.2f (%+.2f%%)", favorite.change, favorite.percentChange))
                                        .foregroundColor(favorite.change >= 0 ? .green : .red)
                                        .padding(.trailing, 10)
                                }
                                .font(.caption)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteFavorite(ticker: favorite.ticker)
                            }
                        } label: {
                            Text("Delete")
                        }
                    }
                }
                .onMove { sourceIndices, destinationIndex in
                                   viewModel.favorites.move(fromOffsets: sourceIndices, toOffset: destinationIndex)
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(PlainListStyle())
            .environment(\.editMode, isEditing ? .constant(.active) : .constant(.inactive))
            .cornerRadius(10) // Set the corner radius you want
                        // Mask the list to a background that has rounded corners
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(Color.white) // Use the appropriate background color
//                        )
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
    
    private func deleteItems(at offsets: IndexSet) {
           // Map the indices to ticker symbols
           let tickersToDelete = offsets.compactMap { viewModel.favorites[$0].ticker }
           
           // Call deleteFavorite for each ticker
           for ticker in tickersToDelete {
               Task {
                   await viewModel.deleteFavorite(ticker: ticker)
               }
           }
    }
}




