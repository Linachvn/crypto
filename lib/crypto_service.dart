import 'dart:convert';
import 'package:http/http.dart' as http;
import 'crypto_data.dart';

class CryptoService {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';
  static const String apiKey = 'CG-SxumtHW6cvevST3sMUG4wh4f'; // Votre clé d'API ici

  Future<List<CryptoData>> getCryptoData(String cryptoId, String period) async {
    // Construction de l'URL avec la clé d'API
    final url = Uri.parse('$baseUrl/coins/$cryptoId/market_chart?vs_currency=usd&days=$period');

    try {
      // Envoi de la requête avec la clé d'API dans les en-têtes
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey', // Ajout de la clé d'API dans l'en-tête
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<List<dynamic>> prices = List<List<dynamic>>.from(data['prices']);

        // Convertir les données récupérées en une liste d'objets CryptoData
        return prices.map((price) => CryptoData(
          price: price[1].toDouble(),
          date: DateTime.fromMillisecondsSinceEpoch(price[0].toInt()),
        )).toList();
      } else {
        print('Erreur lors de la récupération des données : ${response.statusCode}');
        throw Exception('Échec du chargement des données des cryptomonnaies');
      }
    } catch (e) {
      print('Erreur : $e');
      throw Exception('Échec du chargement des données');
    }
  }

  Future<int> getDailyTransactions(String cryptoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/coins/$cryptoId?localization=false&tickers=true&market_data=true&community_data=false&developer_data=false&sparkline=false'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Récupérer le volume des transactions sur 24h
        return data['market_data']['total_volume']['usd'].toInt();
      } else {
        print('Erreur lors de la récupération des transactions : ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Erreur lors de la récupération des transactions : $e');
      return 0;
    }
  }
}
