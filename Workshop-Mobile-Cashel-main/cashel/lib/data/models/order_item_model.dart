class OrderItemModel {
  final String namaProduk;
  final String varian;
  final int jumlah;
  final int harga;

  OrderItemModel({
    required this.namaProduk,
    required this.varian,
    required this.jumlah,
    required this.harga,
  });

  // Fungsi ini agar error .fromJson di file lain hilang
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      namaProduk: json['nama_produk'] ?? '',
      varian: json['varian'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      harga: json['harga'] ?? 0,
    );
  }
}