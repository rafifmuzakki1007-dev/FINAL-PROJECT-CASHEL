import 'package:flutter/material.dart';

class OrderModel {
  final String id;
  final String namaCustomer;
  final String fotoCustomer; // <-- baru: foto profil dari tabel akun
  final String totalHarga;
  final String tanggal;
  final String produkDibeli;
  String status;
  Color statusColor;
  final String metodePembayaran;
  final String? buktiPembayaran;

  OrderModel({
    required this.id,
    required this.namaCustomer,
    required this.fotoCustomer,
    required this.totalHarga,
    required this.tanggal,
    required this.produkDibeli,
    required this.status,
    required this.statusColor,
    required this.metodePembayaran,
    this.buktiPembayaran,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id           : json['id_pesanan'].toString(),
      namaCustomer : json['nama_customer'] ?? 'User',
      fotoCustomer : json['foto_customer'] ?? '',   // kosong jika null
      totalHarga   : json['total_harga'].toString(),
      status       : json['status'] ?? 'tertunda',
      tanggal      : json['tgl_pesanan'] ?? '',
      produkDibeli  : json['daftar_produk'] ?? '-',
      statusColor   : _parseColor(json['status'] ?? ''),
      metodePembayaran : json['metode_pembayaran'] ?? 'tunai',
      buktiPembayaran  : json['bukti_pembayaran'],
    );
  }

  static Color _parseColor(String status) {
    switch (status.toLowerCase()) {
      case 'tertunda':   return Colors.orange;
      case 'proses':     return Colors.blue;
      case 'selesai':    return Colors.green;
      case 'dibatalkan': return Colors.red;
      default:           return Colors.grey;
    }
  }
}