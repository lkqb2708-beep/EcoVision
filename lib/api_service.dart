import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Service that communicates with the FastAPI backend.
/// Uses 10.0.2.2 which maps to host machine's localhost from Android emulator.
class ApiService {
  // 192.168.1.21 = Your computer's actual local IP address (works for real devices on the same Wi-Fi)
  static const String _baseUrl = 'http://192.168.1.21:8000';

  /// Sends a captured image file to the backend for trash analysis.
  /// Returns a Map with: has_trash, trash_type, trash_category, confidence, bin_color, instruction
  static Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      // Read the image file and convert to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Send POST request to backend
      final response = await http
          .post(
            Uri.parse('$_baseUrl/analyze'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'image_base64': base64Image}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {
          'error': true,
          'message': 'Server error: ${response.statusCode}',
          'has_trash': false,
          'trash_type': 'none',
          'trash_category': 'error',
          'confidence': 0.0,
          'bin_color': 'none',
          'instruction': '',
        };
      }
    } on SocketException {
      return {
        'error': true,
        'message': 'Cannot connect to server. Is the backend running?',
        'has_trash': false,
        'trash_type': 'none',
        'trash_category': 'error',
        'confidence': 0.0,
        'bin_color': 'none',
        'instruction': '',
      };
    } catch (e) {
      return {
        'error': true,
        'message': 'Error: $e',
        'has_trash': false,
        'trash_type': 'none',
        'trash_category': 'error',
        'confidence': 0.0,
        'bin_color': 'none',
        'instruction': '',
      };
    }
  }
}
