import SwiftUI

struct TradeStockView: View {
    @State private var numberOfSharesText = "0" // The text input starts with a default value
    @State private var numberOfShares: Int = 0
    var funds: Double
    var sharePrice: Double
    var ticker: String
    var compName: String
    
    @StateObject var manager = PresentationManager()
    
    @EnvironmentObject var viewModelPort: PortfolioViewModel
    
    @State private var showToast = false
    @State private var showToast2 = false
    @State private var showToast3 = false
    @State private var showToast4 = false
    @State private var showToast5 = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        manager.showParent = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
                
                Text("Trade \(compName) shares")
                    .font(.system(size: 20))
                    .padding(.top)
                
                Spacer()
                
                HStack {
                    // Shares count
                    TextField("", text: $numberOfSharesText)
                        //.keyboardType(.numberPad) // Ensures only numbers can be typed
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .font(.system(size: 100))
                        .fontWeight(.thin)
                        .foregroundColor(numberOfShares == 0 ? .gray : .primary)
                        .onReceive(numberOfSharesText.publisher.collect()) {
                            self.numberOfSharesText = String($0.prefix(4)) // Limiting character count to 4
                            self.numberOfShares = Int(self.numberOfSharesText) ?? 0
                        }
                    
                    //Spacer()
                    
                    VStack {
                        Text("\(numberOfShares == 1 || numberOfShares == 0 ? "Share" : "Shares")")
                            .font(.system(size: 24))
                            .foregroundColor(numberOfShares == 0 ? .gray : .primary)
                            .padding(.bottom)
                        
                        // Calculated price based on number of shares
                        Text("x $\(String(format: "%.2f", sharePrice))/share = $\(String(format: "%.2f", Double(numberOfShares) * sharePrice))")
                            .padding(.bottom)
                            .font(.system(size: 15))
                        
                    }
                    .padding()
                }
                .padding()
                
                Spacer()
                
                // Available funds
                Text("$\(String(format: "%.2f", funds)) available to buy \(ticker)")
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundColor(.gray)
                    .padding(.bottom)
                
                // Buy and Sell buttons
                HStack {
                    Button(action: {
                        // Action for Buy button
                        if !enoughToBuy(curr_price: sharePrice, num_shares: numberOfShares, money: funds) {
                            // Not enough funds to buy, so show the toast
                            withAnimation {
                                showToast = true // Show toast
                                // Hide the toast after 3 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showToast = false
                                }
                            }
                        } else if (numberOfShares <= 0) {
                            withAnimation {
                                showToast2 = true // Show toast
                                // Hide the toast after 3 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showToast2 = false
                                }
                            }

                        }
                        else if (!containsOnlyDigits(input: numberOfShares)) {
                            withAnimation {
                                showToast5 = true // Show toast
                                // Hide the toast after 3 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showToast5 = false
                                }
                            }
                        }
                        else {
                            // There are enough funds, proceed with buying logic
                            Task {
                                await viewModelPort.buyStock(ticker: ticker, shares: numberOfShares, purchasePrice: sharePrice, currentPrice: sharePrice, corpName: compName)
                            }
                            manager.showBuyView = true
                        }
                    }) {
                        Text("Buy")
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(25)
                    }
                    .sheet(isPresented: $manager.showBuyView) {
                                // This is where the TradeStockView gets presented
                        BuyView(manager: manager, numberOfShares: numberOfShares, ticker: ticker)
                    }
                    
                    Button(action: {
                        // Action for Sell button
                        if !enoughToSell(num_shares_buy: numberOfShares, num_shares_own: viewModelPort.numberOfShares(forTicker: ticker)) {
                            // Not enough funds to buy, so show the toast
                            withAnimation {
                                showToast3 = true // Show toast
                                // Hide the toast after 3 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showToast3 = false
                                }
                            }
                        } else if (numberOfShares <= 0) {
                            withAnimation {
                                showToast4 = true // Show toast
                                // Hide the toast after 3 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showToast4 = false
                                }
                            }

                        }
                        else if (!containsOnlyDigits(input: numberOfShares)) {
                            withAnimation {
                                showToast5 = true // Show toast
                                // Hide the toast after 3 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showToast5 = false
                                }
                            }
                        }
                        else {
                            // Selling logic
                            Task {
                                await viewModelPort.sellStock(ticker: ticker ,sharesToSell: numberOfShares)
                            }
                            manager.showSellView = true
                        }
                        
                    }) {
                        Text("Sell")
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(25)
                    }
                    .sheet(isPresented: $manager.showSellView) {
                        SellView(manager: manager, numberOfShares: numberOfShares, ticker: ticker)
                    }
                }
                .padding([.leading, .trailing])
            }
            .padding()
            .navigationBarHidden(true) // Assuming you want to hide the navigation bar
            if showToast {
                VStack {
                    Spacer()
                    Text("Not enough money to buy")
                        .foregroundColor(.white)
                        .padding(.vertical, 20) // Vertical padding
                        .padding(.horizontal, 40) // Horizontal padding to make the toast wider
                        .background(Color.gray)
                        .cornerRadius(25)
                        .frame(maxWidth: .infinity) // Make the toast as wide as possible
                    Spacer().frame(height: 20) // Adjust space from the bottom
                }
                .transition(.opacity) // Fade in/out transition for the toast
                .zIndex(1)
            }
            if showToast2 {
                VStack {
                    Spacer()
                    Text("Cannot buy non-positive shares")
                        .foregroundColor(.white)
                        .padding(.vertical, 20) // Vertical padding
                        .padding(.horizontal, 40) // Horizontal padding to make the toast wider
                        .background(Color.gray)
                        .cornerRadius(25)
                        .frame(maxWidth: .infinity) // Make the toast as wide as possible
                    Spacer().frame(height: 20) // Adjust space from the bottom
                }
                .transition(.opacity) // Fade in/out transition for the toast
                .zIndex(1)
            }
            if showToast3 {
                VStack {
                    Spacer()
                    Text("Not enough shares to sell")
                        .foregroundColor(.white)
                        .padding(.vertical, 20) // Vertical padding
                        .padding(.horizontal, 40) // Horizontal padding to make the toast wider
                        .background(Color.gray)
                        .cornerRadius(25)
                        .frame(maxWidth: .infinity) // Make the toast as wide as possible
                    Spacer().frame(height: 20) // Adjust space from the bottom
                }
                .transition(.opacity) // Fade in/out transition for the toast
                .zIndex(1)
            }
            if showToast4 {
                VStack {
                    Spacer()
                    Text("Cannot sell non-positive shares")
                        .foregroundColor(.white)
                        .padding(.vertical, 20) // Vertical padding
                        .padding(.horizontal, 40) // Horizontal padding to make the toast wider
                        .background(Color.gray)
                        .cornerRadius(25)
                        .frame(maxWidth: .infinity) // Make the toast as wide as possible
                    Spacer().frame(height: 20) // Adjust space from the bottom
                }
                .transition(.opacity) // Fade in/out transition for the toast
                .zIndex(1)
            }
            if showToast5 {
                VStack {
                    Spacer()
                    Text("Please enter a valid amount")
                        .foregroundColor(.white)
                        .padding(.vertical, 20) // Vertical padding
                        .padding(.horizontal, 40) // Horizontal padding to make the toast wider
                        .background(Color.gray)
                        .cornerRadius(25)
                        .frame(maxWidth: .infinity) 
                    Spacer().frame(height: 20)
                }
                .transition(.opacity) // Fade in/out transition for the toast
                .zIndex(1)
            }
        }
    }
}

func enoughToBuy(curr_price: Double, num_shares: Int, money: Double) -> Bool {
    let total_cost = curr_price * Double(num_shares)
    return total_cost <= money
}

func enoughToSell(num_shares_buy: Int, num_shares_own: Int) -> Bool {
    return num_shares_own >= num_shares_buy
}

func containsOnlyDigits(input: Int) -> Bool {
    let inputString = String(input)
    return inputString.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
}

