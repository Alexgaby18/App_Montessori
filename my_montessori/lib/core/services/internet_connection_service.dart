import 'package:http/http.dart' as http;

class InternetConnectionService {
  static final http.Client _client = http.Client();

  static Future<bool> hasInternetAccess() async {
    try {
      final response = await _client
          .get(Uri.https('connectivitycheck.gstatic.com', '/generate_204'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}