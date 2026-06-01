class ProdukModel {
  final String idProduk;
  final String namaProduk;
  final String deskripsi;
  final String harga;
  final String stok;
  final String gambar;
  final String kategori;

  ProdukModel({
    required this.idProduk,
    required this.namaProduk,
    required this.deskripsi,
    required this.harga,
    required this.stok,
    required this.gambar,
    required this.kategori,
  });

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    return ProdukModel(
      idProduk: json['id_produk'].toString(),
      namaProduk: json['nama_produk'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      harga: json['harga'].toString(),
      stok: json['stok'].toString(),
      gambar: json['gambar'] ?? '',
      kategori: json['kategori'] ?? '',
    );
  }
}