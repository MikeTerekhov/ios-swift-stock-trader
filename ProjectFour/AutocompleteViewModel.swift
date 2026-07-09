//
//  AutocompleteViewModel.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/17/24.
//

import Foundation
import SwiftUI
import Alamofire
import SwiftyJSON

struct Auto: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
}

class AutocompleteViewModel: ObservableObject {
    @Published var results = [Auto]()
    @Published var isLoading = false  // Manage loading state

    func fetchAutocompleteResults(query: String) {
        isLoading = true  // Start loading
        let urlString = "\(Constants.baseURL)/api/autocomplete/\(query)"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            print("Invalid URL string.")
            isLoading = false  // End loading if the URL is invalid
            return
        }

        AF.request(url).responseData { [weak self] response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    self?.results = self?.parseAutocompleteResults(json) ?? []
                case .failure(let error):
                    print("Error calling API:", error)
                }
                self?.isLoading = false  // Stop loading regardless of success or failure
            }
        }
    }

    private func parseAutocompleteResults(_ json: JSON) -> [Auto] {
        let filteredStocks = json["result"].arrayValue.filter {
            $0["type"].stringValue == "Common Stock" && !$0["symbol"].stringValue.contains(".")
        }
        
        return filteredStocks.map { item in
            Auto(symbol: item["symbol"].stringValue, name: item["description"].stringValue)
        }
    }
}
