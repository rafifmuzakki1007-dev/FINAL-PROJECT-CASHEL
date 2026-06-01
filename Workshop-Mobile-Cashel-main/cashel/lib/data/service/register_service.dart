import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class RegisterService {
  // Langsung tembak ke file register.php
  final String baseUrl = "http://192.168.18.154/api_cashel/auth/register.php";

  Future<UserModel> register({
    required String nama,
    required String email,
    required String noHp,
    required String password,
    required String alamat,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          "nama": nama,
          "email": email,
          "no_hp": noHp,
          "password": password,
          "alamat": alamat,
        },
      );

      print("Response dari PHP: ${response.body}");

      if (response.statusCode == 200) {
        // data dikirim ke register.php dan hasilnya diubah ke UserModel
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        return UserModel(
          status: "error",
          message: "Gagal terhubung ke server pendaftaran"
        );
      }
    } catch (e) {
      return UserModel(
        status: "error",
        message: "Terjadi kesalahan jaringan saat daftar: $e"
      );
    }
  }
}