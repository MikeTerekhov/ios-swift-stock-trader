//
//  ChartOneView.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/18/24.
//

import SwiftUI
import WebKit
import Alamofire
import SwiftyJSON

struct ChartOneView: View {
    var ticker: String
    var fromDate: String
    var toDate: String
    @State private var htmlContent = "<html></html>"
    
    var body: some View {
        WebView(htmlContent: $htmlContent)
            .onAppear {
                loadChartData()
            }
    }
    
    private func loadChartData() {
        fetchChartDataHourly(ticker: ticker, from: fromDate, to: toDate) { result in
            switch result {
            case .success(let chartData):
                // Format chart data and load into WebView
                updateWebView(with: chartData)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                // Handle errors appropriately
            }
        }
    }
    
    private func updateWebView(with data: [(Int, Double)]) {
        let lineColor = isMarketOpen() ? "green" : "red"
        let jsonData = data.map { "[\($0.0), \($0.1)]" }.joined(separator: ",")
        htmlContent = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>Dynamic Chart</title>
                <script src="https://code.highcharts.com/stock/highstock.js"></script>
                <script src="https://code.highcharts.com/modules/exporting.js"></script>
                <script src="https://code.highcharts.com/modules/navigator.js"></script>
            </head>
            <body>
                <div id="chart-container" style="height: 100%; width: 100%;"></div>
                <script>
                    document.addEventListener('DOMContentLoaded', function() {
                        const data = [\(jsonData)];
                        Highcharts.chart('chart-container', {
                            chart: {
                                type: 'line',
                                backgroundColor: 'white',
                                height: 800
                            },
                            navigator: {
                                enabled: false
                            },
                            scrollbar: {
                                    enabled: true
                            },
                            title: {
                                text: '\(ticker) Hourly Price Variation',
                                align: 'center',
                                style: {
                                     color: '#808080',
                                     fontSize: '50px'
                                }
                            },
                            xAxis: {
                                type: 'datetime',
                                tickInterval: 3600 * 1000 * 4, // One tick per hour assuming data is hourly
                                labels: {
                                    formatter: function() {
                                        return Highcharts.dateFormat('%H:%M', this.value); // Format the x-axis labels as hours and minutes
                                    },
                                     style: {
                                        fontSize: '20px'
                                    },
                                }
                            },
                            yAxis: {
                                opposite: true,
                                title: {
                                    text: 'Price',
                                    style: {
                                        fontSize: '30px' // Adjust font size as needed for yAxis title
                                    },
                                },
                               labels: {
                                       style: {
                                           fontSize: '30px' // Adjust font size as needed for yAxis labels
                                           }
                                       },
                            },
                            series: [{
                                name: '\(ticker)',
                                data: data,
                                lineWidth: 2,  // Increase line width
                                color: '\(lineColor)',  // Dynamic line color based on market open status
                                marker: {
                                    enabled: true,  // Enable markers
                                    fillColor: '\(lineColor)'  // Dynamic marker fill color
                                }
                            }],
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
                            tooltip: {
                                useHTML: true, // Allows the use of HTML to format the tooltip
                                headerFormat: '<table>',
                                pointFormat: '<tr><td style="color: {black};"><b>{point.x:%A, %b %e, %H:%M}</b>: </td>' +
                                                                        '<td style="text-align: right;"><b>{point.y}</b></td></tr>',
                                footerFormat: '</table>',
                                valueDecimals: 2,
                                shadow: true,
                                style: {
                                    width: '200px',
                                    fontSize: '30px'
                                },
                                borderWidth: 0, // Removes the default border around the tooltip
                                backgroundColor: 'white', // Semi-transparent white background
                                borderColor: '\(lineColor)', // Border color
                                borderRadius: 10, // Rounded corners
                                shape: 'square' // Shape of the tooltip
                            },
                            credits: {
                                enabled: true  // Disable the Highcharts.com credits
                            },
                            legend: {
                                enabled: false  // Disable the legend
                            }
                        });
                    });
                </script>
            </body>
            </html>
        """
    }
}

//struct WebView: UIViewRepresentable {
//    @Binding var htmlContent: String
//
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.navigationDelegate = context.coordinator // Set the navigation delegate
//        return webView
//    }
//
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        //print("Loading HTML content into WebView") // General log message
//        //print("HTML Content: \(htmlContent)") // Print the actual HTML content being loaded
//        webView.loadHTMLString(htmlContent, baseURL: nil)
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, WKNavigationDelegate {
//        var parent: WebView
//
//        init(_ webView: WebView) {
//            self.parent = webView
//        }
//
//        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//            decisionHandler(.allow) // Allow all navigation actions
//        }
//    }
//}





