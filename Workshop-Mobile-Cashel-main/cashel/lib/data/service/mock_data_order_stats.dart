import '../models/order_stats_model.dart';

class MockOrderService {
  // Fungsi untuk mengambil data ringkasan order
  static OrderStatsModel getSummary() {
    return OrderStatsModel(
      newOrders: 35,
      pendingOrders: 9,
    );
  }
}