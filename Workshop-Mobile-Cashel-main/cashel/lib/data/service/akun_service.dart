import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cashel/api/api_config.dart';

class AkunService {
  static final String _base = ApiConfig.baseUrl;

  // ── Update Nama ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> updateNama({
    required String idAkun,
    required String nama,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$_base/auth/update_profile.php"),
        body: {"id_akun": idAkun, "nama": nama, "no_hp": "", "alamat": ""},
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {"status": "error", "message": "Koneksi gagal: $e"};
    }
  }

  // ── Update Email ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> updateEmail({
    required String idAkun,
    required String email,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$_base/auth/update_profile.php"),
        body: {"id_akun": idAkun, "email": email},
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {"status": "error", "message": "Koneksi gagal: $e"};
    }
  }

  // ── Update No HP ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> updateNoHp({
    required String idAkun,
    required String noHp,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$_base/auth/update_profile.php"),
        body: {"id_akun": idAkun, "no_hp": noHp, "nama": "", "alamat": ""},
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {"status": "error", "message": "Koneksi gagal: $e"};
    }
  }

  // ── Ganti Password (akun biasa) ────────────────────────────────────────
  static Future<Map<String, dynamic>> updatePassword({
    required String idAkun,
    required String passwordLama,
    required String passwordBaru,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$_base/auth/update_password.php"),
        body: {
          "id_akun":       idAkun,
          "password_lama": passwordLama,
          "password_baru": passwordBaru,
          "mode":          "update",
        },
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {"status": "error", "message": "Koneksi gagal: $e"};
    }
  }

  // ── Set Password (akun Google) ─────────────────────────────────────────
  static Future<Map<String, dynamic>> setPassword({
    required String idAkun,
    required String passwordBaru,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$_base/auth/update_password.php"),
        body: {
          "id_akun":       idAkun,
          "password_baru": passwordBaru,
          "mode":          "set",
        },
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {"status": "error", "message": "Koneksi gagal: $e"};
    }
  }
}