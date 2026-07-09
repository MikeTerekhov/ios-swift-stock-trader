import SwiftUI

struct StocksView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @ObservedObject var autocompleteViewModel = AutocompleteViewModel()
    @State private var debounceWorkItem: DispatchWorkItem?
    @StateObject var portfolioViewModel = PortfolioViewModel()
    @StateObject var favoritesViewModel = FavoritesViewModel()
    
    @Binding var isEditing: Bool

    var body: some View {
        NavigationView {
            VStack {
                if isSearching {
                    if autocompleteViewModel.isLoading {
                        ProgressView("Fetching results...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .font(.system(size: 12))
                    } else {
                        List(autocompleteViewModel.results) { stock in
                            NavigationLink(destination: StockDetailView(symbol: stock.symbol)
                                .environmentObject(portfolioViewModel)
                                .environmentObject(favoritesViewModel)) {
                                VStack(alignment: .leading) {
                                    Text(stock.symbol)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    Text(stock.name)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                } else {
                    // Other views when not searching
                    DateView()
                    PortfolioView(viewModel: portfolioViewModel, viewModelFav: favoritesViewModel, isEditing: $isEditing)
                    FavoritesView(viewModel: favoritesViewModel, viewModelPort: portfolioViewModel, isEditing: $isEditing)
                    FooterView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 242 / 255, green: 242 / 255, blue: 247 / 255))
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: searchText) {
                debounceWorkItem?.cancel()
                let workItem = DispatchWorkItem {
                    self.autocompleteViewModel.fetchAutocompleteResults(query: searchText)
                }
                self.debounceWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
                withAnimation {
                    isSearching = !searchText.isEmpty
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if isSearching {
                        Button("Cancel") {
                            withAnimation {
                                searchText = ""
                                isSearching = false
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                        }
                    } else {
                        Button(action: {
                                   isEditing.toggle()
                               }) {
                                   Text(isEditing ? "Done" : "Edit")
                               }
                    }
                }
            }
            .navigationTitle(isSearching ? "" : "Stocks")
        }
    }
}


