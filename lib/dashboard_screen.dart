import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'crypto_data.dart';
import 'crypto_service.dart';
import 'package:crypto_font_icons/crypto_font_icons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CryptoService _cryptoService = CryptoService();
  List<CryptoData> cryptoData = [];
  String selectedCrypto = 'bitcoin';
  String selectedPeriod = '30';
  bool isLoading = false;

  final Map<String, Map<String, dynamic>> cryptoList = {
    'bitcoin': {'name': 'Bitcoin', 'price': 96771.23, 'change': 0.1},
    'ethereum': {'name': 'Ethereum', 'price': 3682.52, 'change': 9.6},
    'solana': {'name': 'Solana', 'price': 242.83, 'change': -5.8},
    'binancecoin': {'name': 'Binance Coin', 'price': 668.56 , 'change': -1.8},
    'cardano': {'name': 'Cardano', 'price': 1.09 , 'change': 2.3},
    'ripple': {'name': 'Ripple', 'price': 0.62 , 'change': 4.5},
  };

  IconData _getCryptoIcon(String cryptoId) {
    switch (cryptoId) {
      case 'bitcoin':
        return CryptoFontIcons.BTC;
      case 'ethereum':
        return CryptoFontIcons.ETH;
      case 'solana':
        return MdiIcons.ethereum; // Icône alternative pour Solana
      case 'binancecoin':
        return MdiIcons.wallet; // Icône alternative pour Binance Coin
      case 'cardano':
        return MdiIcons.chartPie; // Icône alternative pour Cardano
      case 'ripple':
        return MdiIcons.currencyUsd; // Icône pour Ripple
      default:
        return Icons.currency_bitcoin; // Icône par défaut
    }
  }

  int _getTitleInterval() {
    switch (selectedPeriod) {
      case '1':
        return 12; // Toutes les 3 heures pour 24h
      case '7':
        return 6; // Tous les 6 points pour 7 jours
      case '30':
        return 30; // Tous les 8 points pour 30 jours
      case '365':
        return 15; // Tous les 15 points pour 1 an
      default:
        return 3;
    }
  }


  final Map<String, String> periods = {
    '1': '24h',
    '7': '7 jours',
    '30': '30 jours',
    '365': '1 an',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      cryptoData = await _cryptoService.getCryptoData(selectedCrypto, selectedPeriod);
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement des données. Vérifiez votre connexion.'),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Réessayer',
              onPressed: _loadData,
            ),
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, Map<String, dynamic>>> sortedCryptos =
    cryptoList.entries.toList()
      ..sort((a, b) => (b.value['change'] as double)
          .compareTo(a.value['change'] as double));

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildMainChart(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPerformanceList(sortedCryptos),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildStatsRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Titre avec ombre et texte stylisé
        const Text(
          'Crypto Dashboard',
          style: TextStyle(
            fontFamily: 'Montserrat', // Vous pouvez utiliser une autre police ici
            color: Colors.white,
            fontSize: 28, // Taille du texte légèrement plus grande
            fontWeight: FontWeight.w700, // Police plus grasse
            letterSpacing: 1.5, // Espace entre les lettres pour un effet moderne
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 4.0,
                color: Colors.black26, // Ombre subtile
              ),
            ],
          ),
        ),
        // Icone de rafraîchissement avec un effet de survol
        IconButton(
          icon: const Icon(
            Icons.refresh,
            color: Colors.white,
            size: 28, // Icône un peu plus grande
          ),
          onPressed: _loadData,
          splashColor: Colors.blueAccent, // Effet au survol
          highlightColor: Colors.transparent, // Supprime l'effet de fond
          iconSize: 32, // Taille de l'icône
        ),
      ],
    );
  }


  Widget _buildMainChart() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    if (cryptoData.isEmpty) {
      return const Center(
        child: Text(
          'Aucune donnée disponible',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCrypto,
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: const TextStyle(color: Colors.white),
                    isExpanded: true,
                    items: cryptoList.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCrypto = value;
                          _loadData();
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedPeriod,
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: const TextStyle(color: Colors.white),
                    isExpanded: true,
                    items: periods.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedPeriod = value;
                          _loadData();
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cryptoList[selectedCrypto]?['name'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${NumberFormat('#,##0.00').format(cryptoData.last.price)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 1,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: const Color(0xFF37434d),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < 0 || value.toInt() >= cryptoData.length) {
                                return const Text('');
                              }

                              // Sélectionner un interval de display basé sur la période
                              if (value.toInt() % _getTitleInterval() == 0) {
                                switch (selectedPeriod) {
                                  case '1': // 24 heures
                                    return Text(
                                      DateFormat('HH:mm').format(cryptoData[value.toInt()].date),
                                      style: const TextStyle(
                                        color: Color(0xFF68737d),
                                        fontSize: 10,
                                      ),
                                    );
                                  case '7': // 7 jours
                                  case '30': // 30 jours
                                  case '365': // 1 an
                                    return Text(
                                      DateFormat('dd/MM').format(cryptoData[value.toInt()].date),
                                      style: const TextStyle(
                                        color: Color(0xFF68737d),
                                        fontSize: 10,
                                      ),
                                    );
                                  default:
                                    return const Text('');
                                }
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: cryptoData.asMap().entries.map((entry) {
                            return FlSpot(entry.key.toDouble(), entry.value.price);
                          }).toList(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.withOpacity(0.3),
                                Colors.blue.withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceList(List<MapEntry<String, Map<String, dynamic>>> sortedCryptos) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Performances',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: sortedCryptos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final crypto = sortedCryptos[index];
                final isPositive = crypto.value['change'] >= 0;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF373737),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _getCryptoIcon(crypto.key),
                          color: isPositive ? Colors.green : Colors.red,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crypto.value['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${NumberFormat('#,##0.00').format(crypto.value['price'])}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${isPositive ? '+' : ''}${crypto.value['change']}%',
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    if (cryptoData.isEmpty) return Container();

    final highestPrice = cryptoData.map((e) => e.price).reduce((a, b) => a > b ? a : b);
    final lowestPrice = cryptoData.map((e) => e.price).reduce((a, b) => a < b ? a : b);

    return FutureBuilder<int>(
      future: _cryptoService.getDailyTransactions(selectedCrypto),
      builder: (context, snapshot) {
        final dailyTransactionsCount = snapshot.data ?? 0;

        return Row(
          children: [
            _buildStatCard('Plus Haut', '\$${NumberFormat('#,##0.00').format(highestPrice)}', Colors.green),
            const SizedBox(width: 16),
            _buildStatCard('Plus Bas', '\$${NumberFormat('#,##0.00').format(lowestPrice)}', Colors.red),
            const SizedBox(width: 16),
            _buildStatCard('Volume 24h', NumberFormat('#,###').format(dailyTransactionsCount), Colors.purple),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} // Fin de la classe _DashboardScreenState 
