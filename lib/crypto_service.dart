import 'dart:convert';
import 'package:http/http.dart' as http;
import 'crypto_data.dart';

class CryptoService {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';

  Future<List<CryptoData>> getCryptoData(String cryptoId, String period) async {
    final response = await http.get(
      Uri.parse('$baseUrl/coins/$cryptoId/market_chart?vs_currency=usd&days=$period'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<List<dynamic>> prices = List<List<dynamic>>.from(data['prices']);

      return prices.map((price) {
        return CryptoData(
          price: price[1].toDouble(),
          date: DateTime.fromMillisecondsSinceEpoch(price[0].toInt()),
        );
      }).toList();
    } else {
      throw Exception('Erreur lors du chargement des données de la crypto.');
    }
  }
}
