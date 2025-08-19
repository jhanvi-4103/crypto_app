import 'package:http/http.dart' as http;

class CorsProxy {
  static const String _proxyUrl = 'https://cors-anywhere.herokuapp.com/';
  
  static Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    final response = await http.get(
      Uri.parse('$_proxyUrl$url'),
      headers: {
        ...?headers,
        'X-Requested-With': 'XMLHttpRequest',
      },
    );
    
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load data from proxy. Status: ${response.statusCode}');
    }
  }
}
