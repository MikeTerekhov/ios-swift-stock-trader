import SwiftUI

struct SheetView: View {
    let item: NewsItem
    let compName: String
    
    // Environment property to manage presentation mode
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                Button(action: {
                    // Action to dismiss the sheet
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 5) {
                Text(compName)
                    .font(.system(size: 20))
                    .bold()
                Text(formatDate(fromTimestamp: item.publishedDate))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                
                Divider()
                
                Text(item.headline)
                    .font(.system(size: 15))
                    .fontWeight(.bold)
                
                Text(item.summary)
                    .font(.system(size: 10))
                
                HStack {
                    Text("For more details click ")
                        .font(.system(size: 10))
                        .foregroundColor(Color.gray)
                    Link("here", destination: URL(string: item.url)!)
                        .font(.system(size: 10))
                        .foregroundColor(.blue)
                }
                HStack {
                          Button(action: {
                              shareOnTwitter()
                          }) {
                              Image("x")
                                  .resizable()
                                  .scaledToFit()
                                  .frame(width: 50, height: 50)
                          }
                          
                          Button(action: {
                              shareOnFacebook()
                          }) {
                              Image("facebook")
                                  .resizable()
                                  .scaledToFit()
                                  .frame(width: 50, height: 50)
                          }
                      }
                
            }
            .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
    
    func shareOnTwitter() {
            let headline = item.headline.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
            let url = item.url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
            let tweetUrl = "https://twitter.com/intent/tweet?text=\(headline)&url=\(url)"
            
            if let url = URL(string: tweetUrl) {
                UIApplication.shared.open(url)
            }
        }
        
        func shareOnFacebook() {
            let url = item.url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
            let facebookUrl = "https://www.facebook.com/sharer/sharer.php?u=\(url)"
            
            if let url = URL(string: facebookUrl) {
                UIApplication.shared.open(url)
            }
        }
}

struct NewsView: View {
    let ticker: String
    @StateObject var viewModel = NewsViewModel()
    let compName: String
    @State private var selectedItem: NewsItem? // State to hold the selected item

    var body: some View {
        VStack(alignment: .leading) {
            //print("Rendering NewsView for \(ticker)") // Debug print statement
            Text("News").font(.system(size: 20)).padding(.horizontal)

            if viewModel.newsItems.isEmpty {
                Text("No news available") // This confirms if newsItems is empty
                //print("No news items to display.")
            } else {
                if let firstArticle = viewModel.newsItems.first {
                    FeaturedNewsArticleView(item: firstArticle, compName: compName)
                        .onTapGesture {
                            self.selectedItem = firstArticle
                            //print("First news item selected: \(firstArticle.headline)")
                        }
                        .onAppear {
                            //print("First news item appeared: \(firstArticle.headline)")
                        }
                }

                Divider()

                ForEach(Array(viewModel.newsItems.filter { !$0.img.isEmpty }.prefix(20))) { item in
                    StandardNewsArticleView(item: item, compName: compName)
                        .padding(.horizontal)
                        .onTapGesture {
                            self.selectedItem = item
                            //print("News item selected: \(item.headline)")
                        }
                        .onAppear {
                            //print("News item appeared: \(item.headline)")
                        }
                }

            }
        }
        .onAppear {
            //print("NewsView appeared, fetching news for \(ticker)")
            Task {
                await viewModel.fetchNews(ticker: ticker)
            }
        }
        .sheet(item: $selectedItem) { item in
            SheetView(item: item, compName: compName)
        }
    }
}

struct FeaturedNewsArticleView: View {
    let item: NewsItem
    let compName: String

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            AsyncImage(url: URL(string: item.img)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .aspectRatio(contentMode: .fill)
            .frame(height: 200)
            .frame(maxWidth: 360, maxHeight: 200)
            .cornerRadius(8)
            .clipped()
            
            HStack {
                Text(compName)
                Spacer()
                Text(timeElapsed(fromUnixTimestamp: item.publishedDate))
            }
            .font(.system(size: 15))
            .foregroundColor(Color.gray)

            VStack(alignment: .leading, spacing: 5) {
                Text(item.headline)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(3)
            }
            .padding(.bottom)
        }
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct StandardNewsArticleView: View {
    let item: NewsItem
    let compName: String

    var body: some View {
        HStack(spacing: 15) {

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(compName)
                    Spacer()
                    Text(timeElapsed(fromUnixTimestamp: item.publishedDate))
                }
                .font(.system(size: 10))
                .foregroundColor(Color.gray)
                Text(item.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundColor(.primary)
            }
            
            AsyncImage(url: URL(string: item.img)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 100, height: 60)
            .cornerRadius(8)
            
            Spacer()
        }
        .padding(.vertical)
    }
}

// Helper function to format the UNIX timestamp into a readable date format
private func formatDate(fromTimestamp timestamp: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

func timeElapsed(fromUnixTimestamp unixTimestamp: Int) -> String {
    let publishedDate = Date(timeIntervalSince1970: TimeInterval(unixTimestamp))
    let currentDate = Date()
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute], from: publishedDate, to: currentDate)

    let hours = components.hour ?? 0
    let minutes = components.minute ?? 0

    return "\(hours) hr, \(minutes) min"
}

