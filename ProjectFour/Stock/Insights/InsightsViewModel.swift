//
//  InsightsViewModel.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/19/24.
//

import Foundation
import Alamofire
import SwiftyJSON

class InsightsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var totalPositiveChange = 0.0
    @Published var totalNegativeChange = 0.0
    @Published var totalChange = 0.0
    @Published var totalPositiveMSPR = 0.0
    @Published var totalNegativeMSPR = 0.0
    @Published var totalMSPR = 0.0
    @Published var errorMessage: String?

    func fetchInsights(query: String) {
        self.isLoading = true
        let endpointUrl = "\(Constants.baseURL)/api/insights/\(query)"
        
        AF.request(endpointUrl).responseData { [weak self] response in
            guard let strongSelf = self else { return }
            
            strongSelf.isLoading = false
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                //print("Fetched data INISGHT: \(json)") // Print the fetched JSON data.
                let data = json["data"].arrayValue

                for item in data {
                    let change = item["change"].doubleValue
                    let mspr = item["mspr"].doubleValue

                    strongSelf.totalChange += change
                    strongSelf.totalMSPR += mspr

                    if change > 0 { strongSelf.totalPositiveChange += change }
                    if mspr > 0 { strongSelf.totalPositiveMSPR += mspr }

                    if change < 0 { strongSelf.totalNegativeChange += change }
                    if mspr < 0 { strongSelf.totalNegativeMSPR += mspr }
                }
                
            case .failure(let error):
                strongSelf.errorMessage = "Error fetching data: \(error.localizedDescription)"
                print("Error fetching data: \(error.localizedDescription)")
            }
        }
    }

}
