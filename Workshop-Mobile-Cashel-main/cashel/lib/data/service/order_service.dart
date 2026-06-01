import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

class OrderService {
  // GANTI DENGAN IP LAPTOP KAMU
  static const String baseUrl = "http://192.168.18.154/api_cashel"; 

  Future<List<OrderModel>> fetchAllAdminOrders() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/transaction/get_admin_order.php"));
      
      if (response.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(response.body);
        List<dynamic> data = body['data'];
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception("Gagal ambil data");
      }
    } catch (e) {
      throw Exception("Koneksi Error: $e");
    }
  }
}