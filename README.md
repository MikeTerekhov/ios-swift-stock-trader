# ProjectFour — iOS Stock Trading Simulator

A SwiftUI iOS app for browsing stocks, tracking a watchlist, and simulating trades with a virtual cash balance. Paired with a Node/Express backend that proxies market data and persists portfolio state in MongoDB.

## Features

- **Search & autocomplete** — debounced ticker search backed by Finnhub
- **Stock detail pages** — profile, quote, stats, earnings, insider sentiment, analyst recommendations, peer comparisons, and recent news for any ticker
- **Interactive price charts** — intraday and daily views (Polygon.io), with a chart-type selector
- **Portfolio** — buy/sell simulated shares against a virtual cash balance, with live P/L
- **Favorites/watchlist** — track tickers without owning them
- **News feed** — recent company news per ticker

## Architecture

**iOS app** (`ProjectFour/`) — SwiftUI, MVVM
- Each feature area is a View + `ObservableObject` ViewModel (`Port/`, `Fav/`, `News/`, `Stock/`, `StockDetail/`, `Charts/`, `Trade/`)
- `PortfolioViewModel` and `FavoritesViewModel` are shared across views via `@StateObject`/`.environmentObject`
- Networking via Alamofire (`NetworkManager.swift`, `FetchStockData.swift`) against the backend's REST API

**Backend** (`backend.js`) — Express (ESM)
- Proxies Finnhub (search, quotes, profiles, news, insights, recommendations, earnings) and Polygon.io (chart data), keeping API keys server-side
- Persists portfolio holdings, favorites, and cash balance in MongoDB

## Running the backend locally

```bash
npm install
cp .env.example .env   # fill in your own API keys and Mongo URI
npm start
```

Requires a free [Finnhub](https://finnhub.io) API key, a [Polygon.io](https://polygon.io) API key, and a MongoDB connection string (e.g. from MongoDB Atlas).

## Running the iOS app

Open `ProjectFour.xcodeproj` in Xcode and run on a simulator or device. Update `Constants.baseURL` in `ProjectFour/Constants.swift` to point at your backend (local or deployed).
