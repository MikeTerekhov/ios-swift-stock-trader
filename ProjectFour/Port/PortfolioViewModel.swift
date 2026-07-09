//
//  PortfolioViewModel.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/23/24.
//

import Foundation
import SwiftUI
import Combine
import Alamofire

struct StockPurchase: Codable, Identifiable {
    let id: UUID
    let ticker: String
    let shares: Int
    let purchasePrice: Double
    let currentPrice: Double
    let corpName: String
    let totalCost: Double
    
    // The decoder will only decode the properties present in the JSON.
    // The `id` is generated during the initialization and not expected in the JSON.
    init(ticker: String, shares: Int, purchasePrice: Double, currentPrice: Double, corpName: String, totalCost: Double) {
        self.id = UUID() // Generate a new UUID
        self.ticker = ticker
        self.shares = shares
        self.purchasePrice = purchasePrice
        self.currentPrice = currentPrice
        self.corpName = corpName
        self.totalCost = totalCost
    }
    
    // Custom decoder to handle the JSON decoding.
    // Since 'id' is not in the JSON, it's generated here and not decoded.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties from the JSON except for the 'id'.
        let ticker = try container.decode(String.self, forKey: .ticker)
        let shares = try container.decode(Int.self, forKey: .shares)
        let purchasePrice = try container.decode(Double.self, forKey: .purchasePrice)
        let currentPrice = try container.decode(Double.self, forKey: .currentPrice)
        let corpName = try container.decode(String.self, forKey: .corpName)
        let totalCost = try container.decode(Double.self, forKey: .totalCost)
        
        // Initialize using the designated initializer.
        self.init(ticker: ticker, shares: shares, purchasePrice: purchasePrice, currentPrice: currentPrice, corpName: corpName, totalCost: totalCost)
    }
    
    // Define the CodingKeys enum to match the JSON structure,
    // excluding the 'id' property which is not in the JSON.
    enum CodingKeys: String, CodingKey {
        case ticker, shares, purchasePrice, currentPrice, corpName, totalCost
    }
}



class PortfolioViewModel: ObservableObject {
    @Published var stocks: [StockPurchase] = []
    @Published var netWorth: Double = 0.0
    @Published var cashBalance: Double = 0.0
    
    var timer: AnyCancellable?

    func startTimer() {
        // Cancel any existing timer
        timer?.cancel()

        // Create a new timer that fires every 15 seconds
        timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect().sink {_ in 
            Task {
                await self.loadData()  // Correctly using optional chaining here
            }
        }
    }
    
    @MainActor
    func updateUI(stockPurchases: [StockPurchase], balance: Double) {
        self.stocks = stockPurchases
        self.cashBalance = balance
        self.netWorth = self.stocks.reduce(balance) { $0 + $1.currentPrice * Double($1.shares) }
    }
    
    deinit {
            timer?.cancel()
    }
    
    func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    func loadData() async {
        do {
            // Fetch data concurrently
            print("LOADDDD")
            async let fetchedStockPurchases = try fetchStockPurchases()
            async let fetchedBalance = try getBalance()

            // Wait for the data to be fetched
            let (stockPurchases, balance) = await (try fetchedStockPurchases, try fetchedBalance)
            
            // Update the UI on the main thread
            await updateUI(stockPurchases: stockPurchases, balance: balance)
            
            // After updating UI, update prices
            await updatePrices()
            
        } catch {
            // If an error occurs, print it to the console
            print("An error occurred while fetching data: \(error)")
        }
    }
    
    func deleteStock(at index: Int) {
        stocks.remove(at: index)
    }
    
    func stockExists(ticker: String) -> Bool {
            return stocks.contains { $0.ticker.uppercased() == ticker.uppercased() }
    }
    
    func getStockPurchase(forTicker ticker: String) -> StockPurchase? {
            return stocks.first { $0.ticker.uppercased() == ticker.uppercased() }
    }
    
    func numberOfShares(forTicker ticker: String) -> Int {
            return stocks.first { $0.ticker.uppercased() == ticker.uppercased() }?.shares ?? 0
    }
    
    func updatePrices() async {
        for stock in stocks {
            Task {
                do {
                    let response = try await updateCurrentPrice(ticker: stock.ticker, currentPrice: stock.currentPrice)
                    print("Response message: \(response.message)")
                } catch {
                    print("An error occurred while updating the price for ticker: \(stock.ticker)")
                }
            }
        }
    }
    
    func buyStock(ticker: String, shares: Int, purchasePrice: Double, currentPrice: Double, corpName: String) async {
           do {
               let response = try await buyStock_backend(ticker: ticker, shares: shares, purchasePrice: purchasePrice, currentPrice: currentPrice, corpName: corpName)
               print(response.message)
               // After a successful buy, refresh the data
               await loadData()
           } catch {
               print("Error during stock purchase: \(error)")
           }
    }

    func sellStock(ticker: String, sharesToSell: Int) async {
       do {
           let response = try await sellStock_backend(ticker: ticker, sharesToSell: sharesToSell)
           print(response.message)
           // After a successful sell, refresh the data
           await loadData()
       } catch {
           print("Error during stock sale: \(error)")
       }
    }
    
}

struct BuyStockResponse: Decodable {
    let message: String
    // Add other response properties if needed
}

func buyStock_backend(ticker: String, shares: Int, purchasePrice: Double, currentPrice: Double, corpName: String) async throws -> BuyStockResponse {
    let url = "\(baseURL)/buyStock"
    let parameters: [String: Any] = [
        "ticker": ticker,
        "shares": shares,
        "purchasePrice": purchasePrice,
        "currentPrice": currentPrice,
        "corpName": corpName
    ]
    
    let request = AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
    let dataResponse = await request.serializingDecodable(BuyStockResponse.self).response
    
    switch dataResponse.result {
    case .success(let response):
        return response
        
    case .failure(let error):
        print("Error during stock purchase: \(error.localizedDescription)") // Print error message
        throw error
    }
}

struct SellStockResponse: Decodable {
    let message: String
    let totalSale: Double?
}

func sellStock_backend(ticker: String, sharesToSell: Int) async throws -> SellStockResponse {
    let url = "\(baseURL)/sellStock"  // Replace with your server's actual base URL
    let parameters: [String: Any] = [
        "ticker": ticker,
        "sharesToSell": sharesToSell
    ]
    
    let request = AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
    let dataResponse = await request.serializingDecodable(SellStockResponse.self).response
    
    switch dataResponse.result {
    case .success(let response):
        return response
        
    case .failure(let error):
        print("Error during stock sale: \(error.localizedDescription)") // Print error message
        throw error
    }
}

func fetchStockPurchases() async throws -> [StockPurchase] {
    let url = URL(string: "\(Constants.baseURL)/stockPurchases")! // GET stocks
    let request = AF.request(url)
    let dataResponse = await request.serializingDecodable([StockPurchase].self).response
    
    switch dataResponse.result {
    case .success(let stockPurchases):
        return stockPurchases
    case .failure(let error):
        print("Error fetching stock purchases: \(error.localizedDescription)")
        throw error
    }
}

func fetchFavorites() async throws -> [Favorite] {
    let url = URL(string: "\(Constants.baseURL)/favorites")! // GET favorites
    let request = AF.request(url)
    let dataResponse = await request.serializingDecodable([Favorite].self).response
    
    switch dataResponse.result {
    case .success(let favorites):
        return favorites
    case .failure(let error):
        print("Error fetching favorites: \(error.localizedDescription)")
        throw error
    }
}

func getBalance() async throws -> Double {
    print("Getting balance")
    let url = URL(string: "\(Constants.baseURL)/balance")!
    let request = AF.request(url, method: .get)
    let dataResponse = await request.serializingDecodable(Double.self).response

    print("RAW BAL: ", dataResponse)
    
    switch dataResponse.result {
    case .success(let balance):
        return balance
    case .failure(let error):
        print("Error fetching balance: \(error.localizedDescription)")
        throw error
    }
}

struct UpdateCurrentPriceResponse: Codable {
    let message: String
    let result: UpdateResult?
    
    struct UpdateResult: Codable {
    }
}

func updateCurrentPrice(ticker: String, currentPrice: Double) async throws -> UpdateCurrentPriceResponse {
    let url = URL(string: "\(Constants.baseURL)/updateCurrentPrice")!
    let parameters: [String: Any] = [
        "ticker": ticker,
        "currentPrice": currentPrice
    ]
    
    let request = AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
    let dataResponse = await request.serializingDecodable(UpdateCurrentPriceResponse.self).response
    
    switch dataResponse.result {
    case .success(let response):
        return response
    case .failure(let error):
        print("Error updating current price for \(ticker): \(error.localizedDescription)")
        throw error
    }
}
