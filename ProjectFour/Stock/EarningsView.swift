import SwiftUI
import WebKit
import Alamofire
import SwiftyJSON

struct EarningsView: View {
    var ticker: String
    @State private var htmlContent = "<html></html>"
    
    var body: some View {
        WebView(htmlContent: $htmlContent)
            .onAppear {
                loadEarningsData()
            }
    }
    
    private func loadEarningsData() {
        Task {
            do {
                let (categories, actuals, estimates, surprises) = try await fetchEarn(query: ticker)
                DispatchQueue.main.async {
                    updateWebView(with: categories, actuals: actuals, estimates: estimates, surprises: surprises)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateWebView(with categories: [String], actuals: [Double?], estimates: [Double?], surprises: [Double?]) {
        let categoriesString = categories.map { "\"\($0)\"" }.joined(separator: ", ")
        let actualsString = actuals.map { ($0 != nil) ? "\($0!)" : "null" }.joined(separator: ", ")
        let estimatesString = estimates.map { ($0 != nil) ? "\($0!)" : "null" }.joined(separator: ", ")
        let surprisesString = surprises.map { ($0 != nil) ? "\($0!)" : "null" }.joined(separator: ", ")

        htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Historical EPS Surprises</title>
            <script src="https://code.highcharts.com/stock/highstock.js"></script>
            <script src="https://code.highcharts.com/modules/exporting.js"></script>
            <script src="https://code.highcharts.com/modules/navigator.js"></script>
        </head>
        <body>
            <div id="container" style="height: 100%; width: 100%;"></div>
            <script>
                document.addEventListener('DOMContentLoaded', function() {
                    const categories = [\(categoriesString)];
                    const actuals = [\(actualsString)];
                    const estimates = [\(estimatesString)];
                    const surprises = [\(surprisesString)];
                    Highcharts.chart('container', {
                        exporting: { enabled: false },
                        chart: {
                            type: 'line',
                            backgroundColor: 'white',
                            height: 900
                        },
                        title: {
                            text: 'Historical EPS Surprises',
                            style: {
                                 fontSize: '50px'
                            }
                            
                        },
                        xAxis: {
                            categories: categories,
                            labels: {
                                formatter: function() {
                                    const surpriseValue = surprises[this.pos];
                                    return `<div style="display: flex; flex-direction: column; align-items: center;">` +
                                        `<div>${this.value}</div>` +
                                        `<div>Surprise: ${Number(surpriseValue).toFixed(2)}</div>` +
                                        `</div>`;
                                },
                                style: {
                                    fontSize: '30px' // Adjust font size as needed for yAxis labels
                                    },
                                useHTML: true
                            },
                        },
                        yAxis: {
                            title: {
                                text: 'Quarterly EPS',
                                style: {
                                    fontSize: '30px' // Adjust font size as needed for yAxis title
                                }
                            },
                            labels: {
                                    style: {
                                        fontSize: '30px' // Adjust font size as needed for yAxis labels
                                        }
                                    },
                        },
                        series: [{
                            name: 'Actual',
                            data: actuals,
                        }, {
                            name: 'Estimate',
                            data: estimates,
                        }],
                        tooltip: {
                            shared: true,
                            pointFormatter: function() {
                                return `<span style="color:${this.color}">${this.series.name}</span>: <b>${this.y}</b>` +
                                    (this.surprise ? ` (Surprise: ${Number(this.surprise).toFixed(2)}%)` : '') + '<br/>';
                            },
                            valueDecimals: 2,
                             style: {
                                        fontSize: '30px' // Change this value to the desired font size for tooltip text
                                },
                        },
                        plotOptions: {
                            series: {
                                label: {
                                    connectorAllowed: false
                                },
                                dataLabels: {
                                    enabled: false,
                                    y: 18,
                                    align: 'center',
                                    verticalAlign: 'bottom'
                                }
                            }
                        },
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


