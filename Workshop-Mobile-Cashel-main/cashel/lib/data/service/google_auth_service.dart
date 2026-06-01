import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../service/session_service.dart';

class GoogleAuthService {
  final String baseUrl = "http://192.168.18.154/api_cashel/auth/google_login.php";

  Future<UserModel> loginWithGoogle({
    required String nama,
    required String email,
    required String uid,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          "nama":  nama,
          "email": email,
          "uid":   uid,
        },
      );

      if (response.statusCode == 200) {
        final model = UserModel.fromJson(jsonDecode(response.body));

        // otomatis simpan ke session
        if (model.status == 'success' && model.data != null) {
          await SessionService.saveUser(model.data!);
        }

        return model;
      } else {
        return UserModel(
          status: "error",
          message: "Server Error: ${response.statusCode}",
        );
      }
    } catch (e) {
      return UserModel(
        status: "error",
        message: "Koneksi Google login gagal: $e",
      );
    }
  }
}