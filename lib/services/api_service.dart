import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/crypto.dart';
import '../utils/cors_proxy.dart';

class ApiService {
  static const String baseUrl = 'https://rest.coincap.io/v3/assets';
  static const String apiKey = '75af2c89bce21d92fcb7db153b3853613197cae12da95e2a35ec4f51c66edc52';
  
  final http.Client _client;
  
  // Use a factory constructor to allow for better testability
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Crypto>> fetchCryptos() async {
    try {
      final url = '$baseUrl?limit=100';
      final headers = {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      
      final response = kIsWeb 
          ? await CorsProxy.get(url, headers: headers)
          : await _client.get(
              Uri.parse(url),
              headers: headers,
            );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> cryptoList = data['data'] ?? [];
        
        if (cryptoList.isEmpty) {
          throw Exception('No cryptocurrency data available');
        }
        
        return cryptoList.map((json) => Crypto.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load cryptos. Status code: ${response.statusCode}\n${response.body}'
        );
      }
    } catch (e) {
      debugPrint('Error in fetchCryptos: $e');
      rethrow;
    }
  }
  
  // Close the client when done (important for web)
  void dispose() {
    _client.close();
  }
}
