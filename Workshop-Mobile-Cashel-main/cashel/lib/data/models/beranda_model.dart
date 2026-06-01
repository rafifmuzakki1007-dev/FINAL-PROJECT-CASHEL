class BerandaData {
  final int newOrders;
  final int pendingOrders;
  final List<ChartData> activities;
  final List<OrderHistory> orderHistory;

  BerandaData({
    required this.newOrders,
    required this.pendingOrders,
    required this.activities,
    required this.orderHistory,
  });

  factory BerandaData.fromJson(Map<String, dynamic> json) {
    return BerandaData(
      newOrders: json['new_orders'] ?? 0,
      pendingOrders: json['pending_orders'] ?? 0,
      activities: (json['activities'] as List)
          .map((item) => ChartData.fromJson(item))
          .toList(),
      orderHistory: (json['order_history'] as List)
          .map((item) => OrderHistory.fromJson(item))
          .toList(),
    );
  }
}

class ChartData {
  final String month;
  final double value;

  ChartData({required this.month, required this.value});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      month: json['month'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
    );
  }
}

class OrderHistory {
  final String noOrder;
  final String pelanggan;
  final String tanggal;
  final int totalHarga;

  OrderHistory({
    required this.noOrder,
    required this.pelanggan,
    required this.tanggal,
    required this.totalHarga,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      noOrder: json['no_order'] ?? '',
      pelanggan: json['pelanggan'] ?? '',
      tanggal: json['tanggal'] ?? '',
      totalHarga: (json['total_harga'] ?? 0).toInt(),
    );
  }
}