//
//  FavoritesViewModel.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/24/24.
//

import Foundation
import Alamofire
import Combine

struct Favorite: Codable, Identifiable {
    var id: UUID // Note: no default value here, it will be assigned in the init
    let ticker: String
    var corpName: String
    var highPrice: Double
    var change: Double
    var percentChange: Double

    // Default initializer
    init(ticker: String, corpName: String, highPrice: Double, change: Double, percentChange: Double) {
        self.id = UUID() // Generate a new UUID
        self.ticker = ticker
        self.corpName = corpName
        self.highPrice = highPrice
        self.change = change
        self.percentChange = percentChange
    }

    // Custom decoder to handle the JSON decoding.
    // Since 'id' is not in the JSON, it's generated here and not decoded.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode all properties from the JSON except for the 'id'.
        let ticker = try container.decode(String.self, forKey: .ticker)
        let corpName = try container.decode(String.self, forKey: .corpName)
        let highPrice = try container.decode(Double.self, forKey: .highPrice)
        let change = try container.decode(Double.self, forKey: .change)
        let percentChange = try container.decode(Double.self, forKey: .percentChange)

        // Initialize using the default initializer.
        self.init(ticker: ticker, corpName: corpName, highPrice: highPrice, change: change, percentChange: percentChange)
    }

    // Define the CodingKeys enum to match the JSON structure,
    // excluding the 'id' property which is not in the JSON.
    enum CodingKeys: String, CodingKey {
        case ticker, corpName, highPrice, change, percentChange
    }
}

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Favorite] = []
    @Published var errorMessage: String?
    
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
    
    deinit {
            timer?.cancel()
    }
    
    init() {
        Task {
            await loadData()
        }
    }
    
    func isFav(ticker: String) -> Bool {
        return favorites.contains { $0.ticker == ticker }
    }
    
    @MainActor
    func updateUI(favorites: [Favorite]) {
        self.favorites = favorites
    }
    
    func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    func loadData() async {
        do {
            print("LOAD FAVSSSSSSS")
            async let fetchedFavorites = try await fetchFavorites()
            
            let favorites = try await fetchedFavorites

            await updateUI(favorites: favorites)
            
            await updateFavorites()
            
        } catch {
            print("An error occurred while fetching data: \(error)")
        }
    }
    
    func updateFavorites() async {
        for favorite in favorites {
            Task {
                do {
                    let response = try await updateFavoriteStock(favorite: favorite)
                    DispatchQueue.main.async {
                        if let index = self.favorites.firstIndex(where: { $0.ticker == favorite.ticker }) {
                            self.favorites[index].corpName = favorite.corpName
                            self.favorites[index].highPrice = favorite.highPrice
                            self.favorites[index].change = favorite.change
                            self.favorites[index].percentChange = favorite.percentChange
                            print(response.message)
                        }
                    }
                } catch {
                    print("An error occurred while updating the favorite for ticker: \(favorite.ticker)")
                }
            }
        }
    }
        
    func addFavorite(favorite: Favorite) {
        addFavorite_backend(favorite: favorite) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.favorites.append(favorite)
                    print("Successfully added to favorites")
                case .failure(let error):
                    self?.errorMessage = "Failed to add favorite: \(error.localizedDescription)"
                    print("Error adding favorite: \(error)")
                }
            }
        }
    }
    
    func deleteFavorite(ticker: String) async {
            do {
                let response = try await deleteFavorite_backend(ticker: ticker)
                DispatchQueue.main.async {
                    if let index = self.favorites.firstIndex(where: { $0.ticker == response.ticker }) {
                        self.favorites.remove(at: index)
                        print(response.message)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to delete favorite: \(error.localizedDescription)"
                    print("Error removing favorite: \(error.localizedDescription)")
                }
            }
        }
}

func addFavorite_backend(favorite: Favorite, completion: @escaping (Result<Bool, Error>) -> Void) {
    let url = "\(baseURL)/favorites"

    // Directly pass the Favorite object which conforms to Encodable
    AF.request(url, method: .post, parameters: favorite, encoder: JSONParameterEncoder.default).validate().response { response in
        switch response.result {
        case .success:
            completion(.success(true))
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

struct DeleteFavoriteResponse: Decodable {
    let message: String
    let ticker: String?
}

func deleteFavorite_backend(ticker: String) async throws -> DeleteFavoriteResponse {
    let url = "\(baseURL)/favorites/del/\(ticker)"
    
    let request = AF.request(url, method: .delete)
    let dataResponse = await request.serializingDecodable(DeleteFavoriteResponse.self).response
    
    switch dataResponse.result {
    case .success(let response):
        return response
        
    case .failure(let error):
        print("Error removing favorite: \(error.localizedDescription)")
        throw error
    }
}

struct UpdateFavoriteResponse: Decodable {
    let message: String
}

func updateFavoriteStock(favorite: Favorite) async throws -> UpdateFavoriteResponse {
    let url = "\(baseURL)/updateFavorite"  // Replace `baseURL` with your server's base URL

    let headers: HTTPHeaders = [
        "Content-Type": "application/json"
    ]
    
    let request = AF.request(url, method: .post, parameters: favorite, encoder: JSONParameterEncoder.default, headers: headers)
    let dataResponse = await request.serializingDecodable(UpdateFavoriteResponse.self).response
    
    switch dataResponse.result {
    case .success(let response):
        return response
        
    case .failure(let error):
        print("Error updating favorite: \(error.localizedDescription)")
        throw error
    }
}

