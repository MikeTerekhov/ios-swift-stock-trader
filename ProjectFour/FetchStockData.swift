//
//  FetchStockData.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/17/24.
//

import Foundation
import Alamofire
import SwiftyJSON

struct StockProfile: Codable {
    let name: String
    let ticker: String
    let logo: String
    let finnhubIndustry: String
    let weburl: String
    let ipo: String
}

struct StockQuote: Codable {
    // price
    let c: Double
    //high
    let h: Double
    // low
    let l: Double
    // open price
    let o: Double
    // prev close
    let pc: Double
    // price change
    let d: Double
    // percent change
    let dp: Double
}

struct StockData: Codable {
    let profile: StockProfile
    let quote: StockQuote
    let peers: [String]
}

class StockService {
    static let shared = StockService()
    
    func fetchStockData(for symbol: String, completion: @escaping (Result<StockData, Error>) -> Void) {
        let urlString = "\(Constants.baseURL)/search/\(symbol)"
        
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let value):
                // Print the raw data received from the response
                //print("Raw JSON response data:", String(data: value, encoding: .utf8) ?? "Invalid raw data")
                
                let json = JSON(value)
                
                do {
                    let profileData = try json["profile"].rawData()
                    let quoteData = try json["quote"].rawData()
                    let peersData = try json["peers"].rawData()
                    
                    let decoder = JSONDecoder()
                    let profile = try decoder.decode(StockProfile.self, from: profileData)
                    let quote = try decoder.decode(StockQuote.self, from: quoteData)
                    let peers = try decoder.decode([String].self, from: peersData)
                    
                    let stockData = StockData(profile: profile, quote: quote, peers: peers)
                    completion(.success(stockData))
                } catch {
                    print("Error parsing stock data:", error)
                    completion(.failure(error))
                }
                
            case .failure(let error):
                print("Error fetching stock data:", error)
                completion(.failure(error))
            }
        }
    }
}

