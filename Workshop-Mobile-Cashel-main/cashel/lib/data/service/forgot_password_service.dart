import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgotPasswordService {
  static const String _baseUrl = "http://192.168.18.154/api_cashel/auth";

  // cek apakah email ada di database 
  static Future<Map<String, dynamic>> checkEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/check_email.php"),
        body: {"email": email},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"status": "error", "message": "Server error: ${response.statusCode}"};
    } catch (e) {
      return {"status": "error", "message": "Koneksi gagal: $e"};
    }
  }

  // reset password — pakai update_password.php yang sudah ada
  static Future<Map<String, dynamic>> resetPassword({
    required String idAkun,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/update_password.php"),
        body: {
          "id_akun":       idAkun,
          "password_baru": newPassword,
          "mode":          "set", // bypass verifikasi password lama
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"status": "error", "message": "Server error: ${response.statusCode}"};
    } catch (e) {
      return {"status": "error", "message": "Koneksi gagal: $e"};
    }
  }
}