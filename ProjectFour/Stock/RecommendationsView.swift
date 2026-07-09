//
//  ChartThreeView.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/19/24.
//

import SwiftUI
import WebKit
import Alamofire
import SwiftyJSON

struct RecommendationsView: View {
    var ticker: String
    @State private var htmlContent = "<html></html>"
    
    var body: some View {
        WebView(htmlContent: $htmlContent)
            .onAppear {
                loadRecommendationData()
            }
    }
    
    private func loadRecommendationData() {
        Task {
            do {
                let (categories, recData) = try await fetchRecommendationData(query: ticker)
                // Format data for the Highcharts configuration
                let seriesDataStrongBuy = recData.map { $0.y[0] }
                let seriesDataBuy = recData.map { $0.y[1] }
                let seriesDataHold = recData.map { $0.y[2] }
                let seriesDataSell = recData.map { $0.y[3] }
                let seriesDataStrongSell = recData.map { $0.y[4] }
                
                DispatchQueue.main.async {
                    self.updateWebView(with: categories, strongBuy: seriesDataStrongBuy, buy: seriesDataBuy, hold: seriesDataHold, sell: seriesDataSell, strongSell: seriesDataStrongSell)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                // Handle errors appropriately
            }
        }
    }
    
    private func updateWebView(with categories: [String], strongBuy: [Int], buy: [Int], hold: [Int], sell: [Int], strongSell: [Int]) {
        htmlContent = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>Recommendation Trends</title>
                <script src="https://code.highcharts.com/highcharts.js"></script>
                <script src="https://code.highcharts.com/modules/exporting.js"></script>
            </head>
            <body>
                <div id="container" style="height: 100%; width: 100%;"></div>
                <script>
                    document.addEventListener('DOMContentLoaded', function() {
                        Highcharts.chart('container', {
                            exporting: { enabled: true },
                            chart: {
                                type: 'column',
                                backgroundColor: 'white',
                                height: 900
                            },
                            title: {
                                text: 'Recommendation Trends',
                                style: {
                                     fontSize: '50px'
                                }
                            },
                            xAxis: {
                                categories: \(categories.map{ "'\($0)'" }),
                                type: 'datetime',
                                dateTimeLabelFormats: {
                                    day: '%e %b'
                                },
                                labels: {
                                        style: {
                                            fontSize: '30px' // Adjust font size as needed for yAxis labels
                                            }
                                        },
                            },
                            yAxis: {
                                min: 0,
                                title: {
                                    text: '# Analysis',
                                    style: {
                                        fontSize: '30px' // Adjust font size as needed for yAxis title
                                    }
                                },
                                labels: {
                                        style: {
                                            fontSize: '30px' // Adjust font size as needed for yAxis labels
                                            }
                                        },
                                stackLabels: {
                                    enabled: false
                                },
                            },
                            tooltip: {
                                shared: true,
                                 style: {
                                            fontSize: '30px' // Change this value to the desired font size for tooltip text
                                }
                            },
                            plotOptions: {
                                column: {
                                    stacking: 'normal',
                                    dataLabels: {
                                        enabled: true,
                                        inside: true,
                                        verticalAlign: 'middle',
                                    }
                                }
                            },
                            series: [
                                {
                                    name: 'Strong Buy',
                                    data: \(strongBuy),
                                    color: '#1A6334'
                                },
                                {
                                    name: 'Buy',
                                    data: \(buy),
                                    color: '#25AF51'
                                },
                                {
                                    name: 'Hold',
                                    data: \(hold),
                                    color: '#B17E29'
                                },
                                {
                                    name: 'Sell',
                                    data: \(sell),
                                    color: '#F15053'
                                },
                                {
                                    name: 'Strong Sell',
                                    data: \(strongSell),
                                    color: '#752B2C'
                                }
                            ],
                            credits: {
                                enabled: false
                            },
                            exporting: {
                                enabled: true,
                                buttons: {
                                            contextButton: {
                                                symbolSize: 44,  // Increase the size as needed
                                                symbolStrokeWidth: 2,  // You can also adjust the stroke width
                                                // You can also specify height and width if needed
                                                 height: 30,
                                                 width: 30,
                                                fontSize: 30
                                            }
                                        }
                            },
                            legend: {
                                    // Other legend options can be added here as well
                                    itemStyle: {
                                        fontSize: '35px' // Adjust font size as needed for legend labels
                                    }
                                },
                        });
                    });
                </script>
            </body>
            </html>
            """
    }
}
