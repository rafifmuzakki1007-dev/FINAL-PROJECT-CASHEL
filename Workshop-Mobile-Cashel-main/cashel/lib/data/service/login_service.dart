import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../service/session_service.dart';

class LoginService {
  final String baseUrl = "http://192.168.18.154/api_cashel/auth/login.php";

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          "email": email,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        final model = UserModel.fromJson(jsonDecode(response.body));

        // otomatis simpan ke session jika login berhasil
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
        message: "Koneksi login gagal: $e",
      );
    }
  }
}