import 'dart:convert';
import 'package:http/http.dart' as http;
import 'crypto_data.dart';

class CryptoService {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';
  static const String apiKey = 'CG-SxumtHW6cvevST3sMUG4wh4f'; // Votre clé d'API ici

  /// Récupère les prix actuels des 10 premières cryptomonnaies.
  Future<Map<String, dynamic>> getCurrentCryptoPrices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=false'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        Map<String, dynamic> cryptoPrices = {};

        for (var coin in data) {
          String id = coin['id'];
          cryptoPrices[id] = {
            'name': coin['name'],
            'price': coin['current_price'],
            'change': coin['price_change_percentage_24h'],
            'icon': coin['image']
          };
        }

        return cryptoPrices;
      } else {
        throw Exception('Impossible de charger les prix des cryptomonnaies');
      }
    } catch (e) {
      print('Erreur lors de la récupération des prix : $e');
      // Retourne les données par défaut en cas d'erreur
      return {
        'bitcoin': {'name': 'Bitcoin', 'price': 96771.23, 'change': 0.1},
        'ethereum': {'name': 'Ethereum', 'price': 3682.52, 'change': 9.6},
        'solana': {'name': 'Solana', 'price': 242.83, 'change': -5.8},
        'binancecoin': {'name': 'Binance Coin', 'price': 668.56, 'change': -1.8},
        'cardano': {'name': 'Cardano', 'price': 1.09, 'change': 2.3},
        'ripple': {'name': 'Ripple', 'price': 0.62, 'change': 4.5},
      };
    }
  }

  /// Récupère les données historiques des prix d'une cryptomonnaie.
  Future<List<CryptoData>> getCryptoData(String cryptoId, String period) async {
    int maxRetries = 3;
    int retryDelay = 1000;
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final url = Uri.parse('$baseUrl/coins/$cryptoId/market_chart?vs_currency=usd&days=$period');
        final response = await http.get(url).timeout(Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          List<List<dynamic>> prices = List<List<dynamic>>.from(data['prices']);
          return prices.map((price) => CryptoData(
            price: price[1].toDouble(),
            date: DateTime.fromMillisecondsSinceEpoch(price[0].toInt()),
          )).toList();
        } else if (response.statusCode >= 500 && attempt < maxRetries) {
          await Future.delayed(Duration(milliseconds: retryDelay * (attempt + 1)));
          continue;
        }
      } catch (e) {
        print('Tentative ${attempt + 1} : Erreur de requête - $e');
        if (attempt == maxRetries) {
          throw Exception('Échec du chargement des données');
        }
        await Future.delayed(Duration(milliseconds: retryDelay * (attempt + 1)));
      }
    }
    throw Exception('Échec du chargement des données');
  }

  Future<int> getDailyTransactions(String cryptoId) async {
    int maxRetries = 3;
    int retryDelay = 1000;
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/coins/$cryptoId?localization=false&tickers=true&market_data=true&community_data=false&developer_data=false&sparkline=false'),
        ).timeout(Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['market_data']['total_volume']['usd'].toInt();
        } else if (response.statusCode >= 500 && attempt < maxRetries) {
          await Future.delayed(Duration(milliseconds: retryDelay * (attempt + 1)));
          continue;
        }
      } catch (e) {
        print('Tentative ${attempt + 1} : Erreur de requête - $e');
        if (attempt == maxRetries) {
          return 0;
        }
        await Future.delayed(Duration(milliseconds: retryDelay * (attempt + 1)));
      }
    }
    return 0;
  }
}
