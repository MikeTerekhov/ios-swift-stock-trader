//
//  NetworkManager.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/23/24.
//

import Foundation
import Alamofire


class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = Constants.baseURL 

    private init() {}

    struct BuyStockResponse: Decodable {
        let message: String
        // Add other response properties if needed
    }

    func buyStock(ticker: String, shares: Int, purchasePrice: Double, currentPrice: Double, corpName: String) async throws -> BuyStockResponse {
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

    func sellStock(ticker: String, sharesToSell: Int) async throws -> SellStockResponse {
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
    
    struct UpdateCurrentPriceResponse: Codable {
        let message: String
        let result: UpdateResult?
        
        struct UpdateResult: Codable {
            // Define the properties of the update result as per your JSON response
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


}
