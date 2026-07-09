import Foundation
import Combine
import SwiftUI

class StockDetailViewModel: ObservableObject {
    @Published var companyName: String = ""
    @Published var symbol: String
    @Published var currPrice: Double?
    @Published var logo: String?
    @Published var priceChange: Double?
    @Published var percentChange: Double?
    @Published var highPrice: Double?
    @Published var lowPrice: Double?
    @Published var openPrice: Double?
    @Published var prevClose: Double?
    @Published var ipo: String?
    @Published var finnhubIndustry: String?
    @Published var weburl: String?
    @Published var peers: [String] = []
    @Published var errorMessage: String = ""
    @Published var isLoading = false

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let stockService: StockService

    init(symbol: String, stockService: StockService = .shared) {
        self.symbol = symbol
        self.stockService = stockService
        self.loadStockInfo()
        self.setupTimer()
    }

    private func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.updateCurrentPrice()
        }
    }

    private func updateCurrentPrice() {
        stockService.fetchStockData(for: symbol) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let stockData):
                    self?.currPrice = stockData.quote.c
                    self?.priceChange = stockData.quote.d
                    self?.percentChange = stockData.quote.dp
                    print("Updated current price for \(self?.symbol ?? "unknown"): \(self?.currPrice ?? 0.0)")
                case .failure(let error):
                    self?.errorMessage = "Could not update price: \(error.localizedDescription)"
                }
            }
        }
    }

    func loadStockInfo() {
        isLoading = true
        stockService.fetchStockData(for: symbol) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let stockData):
                    self?.updateStockData(from: stockData)
                case .failure(let error):
                    self?.errorMessage = "Could not load data: \(error.localizedDescription)"
                }
            }
        }
    }

    private func updateStockData(from data: StockData) {
        companyName = data.profile.name
        symbol = data.profile.ticker
        currPrice = data.quote.c
        logo = data.profile.logo
        priceChange = data.quote.d
        percentChange = data.quote.dp
        highPrice = data.quote.h
        lowPrice = data.quote.l
        openPrice = data.quote.o
        prevClose = data.quote.pc
        ipo = data.profile.ipo
        finnhubIndustry = data.profile.finnhubIndustry
        weburl = data.profile.weburl
        peers = data.peers
    }

    deinit {
            print("ViewModel is being deinitialized")
            stopUpdatingPrice()
        }

        func startUpdatingPrice() {
            print("Starting price updates")
            setupTimer()
            updateCurrentPrice()  // Optionally update price immediately on view appearance
        }

        func stopUpdatingPrice() {
            print("Stopping price updates")
            timer?.invalidate()
            timer = nil
        }
}
