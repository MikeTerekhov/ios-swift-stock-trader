//
//  NewsViewModel.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/20/24.
//

import Foundation
import Alamofire
import SwiftyJSON

struct NewsItem: Codable, Identifiable, Hashable {
    let id: Int // Change to Int to match the JSON data type
    let source: String
    var publishedDate: Int
    let headline: String
    let summary: String
    let url: String
    let img: String
    
    // Define coding keys to map the JSON fields to your struct properties
    enum CodingKeys: String, CodingKey {
        case id
        case source
        case publishedDate = "datetime" // Change to match the JSON field for date
        case headline
        case summary
        case url
        case img = "image" // Change to match the JSON field for image
    }
}

func dateOneWeekAgo() -> String {
    let currentDate = Date()
    if let oneWeekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: oneWeekAgo)
    } else {
        return "Date conversion error"
    }
}

class NewsViewModel: ObservableObject {
    @Published var newsItems: [NewsItem] = []
    @Published var isLoading = true  // Track loading state

    func fetchNews(ticker: String) async {
            let to = getTodaysDate()
            let from = dateOneWeekAgo()
            let url = "\(Constants.baseURL)/api/news/\(ticker)/\(from)/\(to)"
            
            DispatchQueue.main.async {
                self.isLoading = true  // Set isLoading to true on the main thread
            }
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false  // Ensure isLoading is set to false on the main thread when the function exits
                }
            }
            
            do {
                let request = AF.request(url).validate()  // Create a request and validate the response
                let data = try await request.serializingData().value  // Wait for data serialization
                let decodedItems = try JSONDecoder().decode([NewsItem].self, from: data)  // Decode data
                DispatchQueue.main.async {
                    self.newsItems = decodedItems  // Update newsItems on the main thread
                    //print("Fetched \(self.newsItems.count) news items")
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error fetching or decoding news: \(error)")
                }
            }
        }

}





