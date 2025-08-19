
📱 Crypto Tracker App

A simple and clean Flutter cryptocurrency tracker app that fetches live data from the CoinCap API and stores it locally using Sqflite for offline support.

✨ Features

📊 Fetch real-time cryptocurrency data from CoinCap API
💾 Store received data locally using Sqflite database.
🌐 Offline mode – show last stored data when there is no internet connection.
🔍 Display cryptocurrency Name, Symbol, Price, Market Cap, Volume, and Supply.
📈 Show percentage change (24h) with green for gain and red for loss.
🔄 Pull-to-refresh option to get the latest prices.
🖼️ Simple, responsive, and modern UI with scrollable list.

🛠️ Tech Stack

Flutter (Dart)
CoinCap API – for fetching live crypto data
Sqflite – for storing data locally

📂 Project Setup

1. Clone the repository:
git clone https://github.com/YOUR_USERNAME/crypto_app.git
cd crypto_app
2. Install dependencies:
flutter pub get
3. Run the app:
flutter run

🔑 API Setup

Visit CoinCap API and generate your free API key.
Replace your key in api_service.dart:
  static const String apiKey = "YOUR_API_KEY_HERE";
  
🚀 Future Improvements
Add favorites/watchlist
Implement search & filter
Add price history charts
Push notifications for price alerts



