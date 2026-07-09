//
//  FetchChartData.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/17/24.
//

import Foundation
import Alamofire
import SwiftyJSON

struct ChartData: Encodable {
    let time: Double
    let open: Double
    let high: Double
    let low: Double
    let close: Double
}

struct VolumeData: Encodable {
    let time: Double
    let volume: Double
}

struct ChartResponse: Decodable {
    let results: [ChartResult]
}

struct ChartResult: Decodable {
    let t: Double
    let o: Double
    let h: Double
    let l: Double
    let c: Double
    let v: Double
}

/// Calls the Node.js backend endpoint to fetch hourly aggregated chart data.
func fetchChartDataHourly(ticker: String, from: String, to: String, completion: @escaping (Result<[(Int, Double)], Error>) -> Void) {
    let urlString = "\(Constants.baseURL)/api/charts/\(ticker)/\(from)/\(to)"
    // Making a GET request to the Node.js backend
    AF.request(urlString).validate().responseData { response in
        switch response.result {
        case .success(let data):
            let json = JSON(data)
            //print("Raw JSON Data: \(json)") // Print the raw JSON data for inspection

            if let results = json["results"].array {
                let chartData = results.compactMap { result -> (Int, Double)? in
                    if let time = result["t"].int, let cost = result["c"].double {
                        // Convert Unix timestamp to milliseconds (JavaScript timestamp)
                        return (time, cost)
                    }
                    return nil
                }
                //print("Formatted Chart Data: \(chartData)") // Print formatted data to see what is being returned
                completion(.success(chartData))
            } else {
                print("Error: Invalid data format in JSON response.") // Provide feedback on data format errors
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"])))
            }
        case .failure(let error):
            print("Error fetching data: \(error.localizedDescription)") // Print error if the request fails
            completion(.failure(error))
        }
    }
}

/// Calls the Node.js backend endpoint to fetch daily aggregated chart data.
/// Calls the Node.js backend endpoint to fetch daily aggregated chart data.
func fetchAndUpdateChartData2(ticker: String) async throws -> ([ChartData], [VolumeData]) {
    let twoYearsAgo = getDateTwoYearsAgo()
    let todaysDate = getTodaysDate()
    let urlString = "\(Constants.baseURL)/api/charts2/\(ticker)/\(twoYearsAgo)/\(todaysDate)"

    let request = AF.request(urlString)
    let dataResponse = await request.serializingData().response

    switch dataResponse.result {
    case .success(let data):
        // Print the raw JSON data for debugging
        //print("Raw JSON CHART2222222222 data: \(String(decoding: data, as: UTF8.self))")
        
        // Decode the JSON response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        do {
            let response = try decoder.decode(ChartResponse.self, from: data)
            let ohlcData = response.results.map { ChartData(time: $0.t, open: $0.o, high: $0.h, low: $0.l, close: $0.c) }
            let volumeData = response.results.map { VolumeData(time: $0.t, volume: $0.v) }
            
            // Print processed data for debugging
            //print("Processed OHLC Data: \(ohlcData)")
            //print("Processed Volume Data: \(volumeData)")
            
            return (ohlcData, volumeData)
        } catch {
            print("Error decoding JSON: \(error.localizedDescription)")
            throw error
        }
    case .failure(let error):
        print("Error fetching chart data: \(error.localizedDescription)")
        throw error
    }
}


// Helper function to get the date two years ago in 'yyyy-MM-dd' format
func getDateTwoYearsAgo() -> String {
    let twoYearsAgo = Calendar.current.date(byAdding: .year, value: -2, to: Date())!
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: twoYearsAgo)
}

// Helper function to get today's date in 'yyyy-MM-dd' format
func getTodaysDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: Date())
}

/// Fetches recommendation data from the server and processes it into categories and recommendation data for charting.

struct RecommendationData {
    let period: String  // Keeping period as string
    let strongBuy: Int
    let buy: Int
    let hold: Int
    let sell: Int
    let strongSell: Int
}

struct RecData {
    let x: TimeInterval // Date converted to TimeInterval for use in charts
    let y: [Int]
}

/// Fetches recommendation data from the server and processes it into categories and recommendation data for charting.
extension String {
    func toDate(withFormat format: String = "yyyy-MM-dd") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: self)
    }
}

func fetchRecommendationData(query: String) async throws -> ([String], [RecData]) {
    let urlString = "\(Constants.baseURL)/api/recs/\(query)"
    
    do {
        let request = AF.request(urlString)
        let dataResponse = await request.serializingData().response
        
        switch dataResponse.result {
        case .success(let data):
            let json = JSON(data)
            
            let recommendationArray = json.arrayValue.compactMap { item -> RecommendationData? in
                let periodStr = item["period"].stringValue
                return RecommendationData(
                    period: periodStr,
                    strongBuy: item["strongBuy"].intValue,
                    buy: item["buy"].intValue,
                    hold: item["hold"].intValue,
                    sell: item["sell"].intValue,
                    strongSell: item["strongSell"].intValue
                )
            }
            
            let categories = recommendationArray.map { $0.period }
            let recData = recommendationArray.compactMap { item -> RecData? in
                guard let date = item.period.toDate() else { return nil }
                return RecData(
                    x: date.timeIntervalSince1970,
                    y: [item.strongBuy, item.buy, item.hold, item.sell, item.strongSell]
                )
            }
            
            // Ensure that the recData array is not empty
            guard !recData.isEmpty else {
                print("Date conversion failed or recData is empty.")
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Date conversion failed or recData is empty."])
            }
            
            return (categories, recData)
        
        case .failure(let error):
            throw error
        }
    } catch {
        throw error
    }
}


// Define a struct to model the earnings data if you have a predefined format.
struct Earning {
    let period: String
    let actual: Double?
    let estimate: Double?
    let surprise: Double?
}

func fetchEarn(query: String) async throws -> ([String], [Double?], [Double?], [Double?]) {
    let urlString = "\(Constants.baseURL)/api/earn/\(query)"
    
    let request = AF.request(urlString)
    let dataResponse = await request.serializingData().response
    
    switch dataResponse.result {
    case .success(let data):
        let json = JSON(data)
        //print("Raw EARNNNNNNNNNNN JSON data: \(json)") // Print the raw JSON data
        
        let earningsArray = json.arrayValue.map { item -> Earning in
            // Parse each item into an Earning struct
            let periodStr = item["period"].stringValue
            let actual = item["actual"].double
            let estimate = item["estimate"].double
            let surprise = item["surprise"].double
            return Earning(period: periodStr, actual: actual, estimate: estimate, surprise: surprise)
        }
        
        // Print parsed values
        earningsArray.forEach { earning in
            //print("Period: \(earning.period), Actual: \(String(describing: earning.actual)), Estimate: \(String(describing: earning.estimate)), Surprise: \(String(describing: earning.surprise))")
        }
        
        let categories = earningsArray.map { $0.period }
        let actuals = earningsArray.map { $0.actual }
        let estimates = earningsArray.map { $0.estimate }
        let surprises = earningsArray.map { $0.surprise }
        
        return (categories, actuals, estimates, surprises)
    
    case .failure(let error):
        print("Error fetching earnings data: \(error.localizedDescription)") // Print error message
        throw error
    }
}
