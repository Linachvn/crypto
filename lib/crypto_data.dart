class CryptoData {
  final double price;
  final DateTime date;

  CryptoData({required this.price, required this.date});

  factory CryptoData.fromJson(Map<String, dynamic> json) {
    return CryptoData(
      price: double.parse(json['price'].toString()),
      date: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] * 1000),
    );
  }
}
