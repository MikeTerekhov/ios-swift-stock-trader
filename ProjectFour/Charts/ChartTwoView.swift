import SwiftUI
import WebKit
import Alamofire
import SwiftyJSON

struct ChartTwoView: View {
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
        Task {
            do {
                let (ohlcData, volumeData) = try await fetchAndUpdateChartData2(ticker: ticker)
                // Format data for the Highcharts configuration
                let formattedOhlcData = ohlcData.map { "[\($0.time), \($0.open), \($0.high), \($0.low), \($0.close)]" }.joined(separator: ",")
                let formattedVolumeData = volumeData.map { "[\($0.time), \($0.volume)]" }.joined(separator: ",")
                
                //print("OHLC Data: \(formattedOhlcData)")
                //print("Volume Data: \(formattedVolumeData)")
                
                DispatchQueue.main.async {
                    self.updateWebView(withOhlc: formattedOhlcData, volume: formattedVolumeData)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                // Handle errors appropriately
            }
        }
    }
    
    private func updateWebView(withOhlc ohlcData: String, volume volumeData: String) {
        htmlContent = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>Dynamic Chart</title>
             <script src="https://code.highcharts.com/stock/highstock.js"></script>
             <script src="https://code.highcharts.com/stock/modules/drag-panes.js"></script>
             <script src="https://code.highcharts.com/stock/modules/exporting.js"></script>
             <script src="https://code.highcharts.com/stock/indicators/indicators.js"></script>
             <script src="https://code.highcharts.com/stock/indicators/volume-by-price.js"></script>
             <script src="https://code.highcharts.com/modules/accessibility.js"></script>
                
            </head>
            <body>
                <div id="chart-container" style="height: 100%; width: 100%;"></div>
                <script>
                    document.addEventListener('DOMContentLoaded', function() {
                        Highcharts.stockChart('chart-container', {
                            chart: {
                                backgroundColor: 'white',
                                height: 800
                            },
                            rangeSelector: {
                                dropdown: 'always',
                                enabled: true,
                                inputEnabled: false,
                                selected: 2,
                                buttonTheme: { // Apply styles to all buttons
                                        style: {
                                            color: '#D3D3D3',
                                            fontSize: '30px',
                                            padding: '15px',
                                        },
                                        states: {
                                            hover: {
                                                fill: '#b0b0b0'
                                            },
                                            select: {
                                                fill: '#e0e0e0'
                                            }
                                        }
                                    },
                                buttons: [
                                    { type: 'month', count: 1, text: '1m' },
                                    { type: 'month', count: 3, text: '3m' },
                                    { type: 'month', count: 6, text: '6m' },
                                    { type: 'ytd', text: 'YTD' },
                                    { type: 'year', count: 1, text: '1y' },
                                    { type: 'all', text: 'All' }
                                ],
                            },
                            exporting: { enabled: false },
                            title: {
                                text: '\(ticker) Historical',
                                align: 'center',
                                style: {
                                     color: 'black',
                                     fontSize: '50px'
                                }
                            },
                            subtitle: {
                                text: 'With SMA and Volume by Price technical indicators',
                                align: 'center',
                                style: {
                                     fontSize: '30px'
                                }
                            },
                            xAxis: {
                                ordinal: true,
                                type: 'datetime',
                                dateTimeLabelFormats: {
                                    day: '%e %b'
                                },
                                labels: {
                                     style: {
                                        fontSize: '20px'
                                    },
                                },
                            },
                            yAxis: [{
                                startOnTick: false,
                                endOnTick: false,
                                opposite: true,
                                labels: {
                                    align: 'left',
                                    style: {
                                        fontSize: '25px'
                                    },
                                },
                                title: {
                                    text: 'OHLC',
                                    style: {
                                        fontSize: '25px' // Bigger font size for the label
                                    }
                                },
                                height: '60%',
                                lineWidth: 2,
                                resize: {
                                    enabled: true
                                },
                                labels: {
                                     style: {
                                        fontSize: '25px'
                                    },
                                },
                            }, {
                                labels: {
                                    style: {
                                        fontSize: '25px'
                                    },
                                },
                                title: {
                                    text: 'Volume',
                                    style: {
                                        fontSize: '25px' // Bigger font size for the label
                                    }
                                },
                                resize: {
                                    enabled: true
                                },
                                top: '65%',
                                height: '35%',
                                offset: 0,
                                lineWidth: 2,
                                opposite: true
                            }],
                            series: [{
                                type: 'candlestick',
                                name: '\(ticker)',
                                id: 'aapl',
                                zIndex: 2,
                                data: [\(ohlcData)]
                            }, {
                                type: 'column',
                                name: 'Volume',
                                id: 'volume',
                                data: [\(volumeData)],
                                yAxis: 1,
                            }, {
                                type: 'vbp',
                                linkedTo: 'aapl',
                                params: {
                                    volumeSeriesID: 'volume'
                                },
                                dataLabels: {
                                    enabled: false
                                },
                                zoneLines: {
                                    enabled: false
                                }
                            }, {
                                type: 'sma',
                                linkedTo: 'aapl',
                                zIndex: 1,
                                marker: {
                                    enabled: false
                                }
                            }],
                            tooltip: {
                                style: {
                                    fontSize: '30px'
                                },
                            },
                           navigator: {
                               enabled: true,
                               xAxis: {
                                   labels: {
                                       style: {
                                           fontSize: '25px',  // Adjust the font size as needed
                                       }
                                   }
                               }
                           },
                            legend: {
                                enabled: false
                            }
                        });
                    });
                </script>
            </body>
            </html>
            """
    }
}

struct WebView: UIViewRepresentable {
    @Binding var htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator // Set the navigation delegate
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        //print("Loading HTML content into WebView") // General log message
        //print("HTML Content: \(htmlContent)") // Print the actual HTML content being loaded
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ webView: WebView) {
            self.parent = webView
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow) // Allow all navigation actions
        }
    }
}

