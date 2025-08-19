import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../models/crypto.dart';
import '../db/database_helper.dart';
import '../services/api_service.dart';

class CryptoScreen extends StatefulWidget {
  const CryptoScreen({super.key});

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  late final ApiService _apiService;
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Crypto> cryptos = [];
  bool isLoading = true;
  String? errorMessage;
  
  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _initializeApp();
  }
  
  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }


  Future<void> _initializeApp() async {
    try {
      // Initialize database
      await dbHelper.database;
      // Then load data
      await _loadData();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to initialize app: ${e.toString()}';
      });
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      // First, try to reset the database to ensure schema is up to date
      await dbHelper.resetDatabase();
      
      // Fetch data from API
      final apiCryptos = await _apiService.fetchCryptos();
      
      // Insert into database
      for (var crypto in apiCryptos) {
        await dbHelper.insertCrypto(crypto);
      }
      
      // Read from database to ensure we have the latest data
      final dbCryptos = await dbHelper.getCryptos();
      
      if (mounted) {
        setState(() {
          cryptos = dbCryptos;
          isLoading = false;
        });
      }
    } catch (e) {
      // If API fails, try to load from database
      try {
        final dbCryptos = await dbHelper.getCryptos();
        if (mounted) {
          setState(() {
            cryptos = dbCryptos;
            isLoading = false;
            errorMessage = 'Using cached data. ${e.toString()}';
          });
        }
      } catch (dbError) {
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = 'Failed to load data: ${e.toString()}\nAlso failed to load from cache: ${dbError.toString()}';
          });
        }
      }
    }
  }

  // Generate a random color based on the crypto symbol
  Color _getRandomColor(String symbol) {
    final random = Random(symbol.hashCode);
    return Color.fromARGB(
      255,
      50 + random.nextInt(150), // R
      50 + random.nextInt(150), // G
      50 + random.nextInt(150), // B
    );
  }

  // Format large numbers to be more readable
  String _formatNumber(double number) {
    if (number >= 1000000000) {
      return '\$${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '\$${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '\$${(number / 1000).toStringAsFixed(2)}K';
    }
    return '\$${number.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: theme.primaryColor,
          title: Text(
            'Crypto Tracker',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadData,
            ),
          ],
        ),
        body: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading Crypto Data...',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              )
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[400],
                          size: 60,
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Failed to load data: $errorMessage',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.red[400],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2,
                          ),
                          onPressed: _loadData,
                          child: Text(
                            'Retry',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: theme.primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cryptos.length,
                      itemBuilder: (context, index) {
                        final crypto = cryptos[index];
                        final color = _getRandomColor(crypto.symbol);
                        final isPositive = (crypto.changePercent24Hr ?? 0) >= 0;
                        
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Material(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            elevation: 2,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                // Add navigation to detail screen here
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              crypto.symbol.substring(0, 2),
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: color,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                crypto.name,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: theme.textTheme.titleLarge?.color,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                crypto.symbol,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: theme.hintColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '\$${crypto.priceUsd.toStringAsFixed(2)}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: theme.textTheme.titleLarge?.color,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isPositive
                                                    ? Colors.green.withOpacity(0.1)
                                                    : Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '${isPositive ? '+' : ''}${crypto.changePercent24Hr?.toStringAsFixed(2) ?? '0.00'}%',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: isPositive
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildInfoBox(
                                          context,
                                          'Market Cap',
                                          _formatNumber(crypto.marketCapUsd ?? 0),
                                        ),
                                        _buildInfoBox(
                                          context,
                                          'Volume (24h)',
                                          _formatNumber(crypto.volumeUsd24Hr ?? 0),
                                        ),
                                        _buildInfoBox(
                                          context,
                                          'Supply',
                                          '${(crypto.supply ?? 0).toStringAsFixed(2)}M',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
  
  Widget _buildInfoBox(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).hoverColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
