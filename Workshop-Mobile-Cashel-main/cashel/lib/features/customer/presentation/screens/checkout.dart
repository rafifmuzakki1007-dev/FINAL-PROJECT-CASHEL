import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/checkout_widgets.dart';
import 'pembayaran_qris_page.dart';
import 'pesanan_diterima.dart';
import 'rincian_pesanan_screen.dart'; // untuk ItemPesanan

class CheckoutPage extends StatefulWidget {
  // Multi-item (dari keranjang)
  final List<Map<String, dynamic>>? items;

  // Single-item fallback (tetap kompatibel dengan pemanggil lama)
  final int idProduk;
  final String namaProduk;
  final int harga;
  final String imagePath;
  final int jumlah;

  const CheckoutPage({
    super.key,
    this.items,
    required this.idProduk,
    required this.namaProduk,
    required this.harga,
    required this.imagePath,
    required this.jumlah,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _paymentMethod = 'Tunai';
  bool _isLoading = false;

  // Ambil list efektif: pakai items jika ada, fallback ke single item
  List<Map<String, dynamic>> get _effectiveItems {
    if (widget.items != null && widget.items!.isNotEmpty) return widget.items!;
    return [
      {
        'id_produk': widget.idProduk,
        'title': widget.namaProduk,
        'harga': widget.harga,
        'imagePath': widget.imagePath,
        'jumlah': widget.jumlah,
      }
    ];
  }

  int get _subtotalProduk {
    int total = 0;
    for (final item in _effectiveItems) {
      final rawPrice = (item['price'] ?? item['harga'] ?? '0').toString();
      final cleanPrice =
          int.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final jumlah = (item['jumlah'] as int? ?? 1);
      total += cleanPrice * jumlah;
    }
    return total;
  }

  int get _totalBayar => _subtotalProduk;

  // Convert _effectiveItems ke List<ItemPesanan> untuk dikirim ke halaman berikutnya
  List<ItemPesanan> get _itemPesananList {
    return _effectiveItems.map((item) {
      final rawPrice = (item['price'] ?? item['harga'] ?? '0').toString();
      final harga =
          int.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return ItemPesanan(
        namaProduk: (item['title'] ?? item['namaProduk'] ?? 'Produk').toString(),
        imagePath: (item['imagePath'] ?? widget.imagePath).toString(),
        harga: harga,
        jumlah: item['jumlah'] as int? ?? 1,
      );
    }).toList();
  }

  static const String _serverIp = "192.168.18.154";
  static const String _baseUrl = "http://$_serverIp/api_cashel/auth";

  Future<void> _buatPesananKeDatabase() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? rawId = prefs.get('id_akun')?.toString();

      if (rawId == null || rawId.isEmpty) {
        throw "Sesi login tidak ditemukan. Silakan login kembali.";
      }

      final int idUserLogin = int.parse(rawId);

      debugPrint("=== DEBUG CHECKOUT ===");
      debugPrint("id_akun           : $idUserLogin");
      debugPrint("metode_pembayaran : $_paymentMethod");
      debugPrint("total_harga       : $_totalBayar");
      debugPrint("items count       : ${_effectiveItems.length}");
      debugPrint("======================");

      final url = Uri.parse('$_baseUrl/checkout.php');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_akun": idUserLogin,
          "total_harga": _totalBayar,
          "metode_pembayaran": _paymentMethod,
          "items": _effectiveItems.map((item) {
            final rawPrice =
                (item['price'] ?? item['harga'] ?? '0').toString();
            final harga =
                int.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            final jumlah = (item['jumlah'] as int? ?? 1);
            return {
              "id_produk":
                  int.tryParse(item['id_produk']?.toString() ?? '0') ?? 0,
              "jumlah": jumlah,
              "harga": harga,
              "sub_total": harga * jumlah,
            };
          }).toList(),
        }),
      ).timeout(const Duration(seconds: 15));

      debugPrint("Response status : ${response.statusCode}");
      debugPrint("Response body   : ${response.body}");

      Map<String, dynamic> result;
      try {
        result = jsonDecode(response.body);
      } catch (_) {
        throw "Respon server tidak valid.\nRaw: ${response.body}";
      }

      if (result['status'] == 'success') {
        final int idPesanan = int.tryParse(
              (result['id_pesanan'] ??
                      result['idPesanan'] ??
                      result['data']?['id_pesanan'] ??
                      0)
                  .toString(),
            ) ??
            0;
        _navigasiKeHalamanBerikutnya(idPesanan);
      } else {
        throw result['message'] ?? "Gagal menyimpan pesanan. Coba lagi.";
      }
    } on http.ClientException catch (e) {
      _showError("Tidak bisa terhubung ke server.\nDetail: $e");
    } catch (e) {
      _showError("$e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _navigasiKeHalamanBerikutnya(int idPesanan) {
    if (!mounted) return;

    // Konversi semua item ke ItemPesanan
    final allItems = _itemPesananList;

    if (_paymentMethod == 'QRIS') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PembayaranQRISPage(
            idPesanan: idPesanan,
            items: allItems, // ← semua item
            totalBayar: _totalBayar,
            ongkir: 0,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PesananDiterimaPage(
            idPesanan: idPesanan,
            metodePembayaran: _paymentMethod,
            items: allItems, // ← SEMUA item dikirim
            totalBayar: _totalBayar,
            ongkir: 0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Color(0xFF181725)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout',
            style: TextStyle(
                color: Color(0xFF181725),
                fontSize: 24,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3498DB)))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        CheckoutProductCard(
                          items: _effectiveItems,
                          fallbackImage: widget.imagePath,
                        ),
                        const SizedBox(height: 25),
                        const CheckoutSectionTitle('Metode Pembayaran'),
                        const SizedBox(height: 12),
                        PaymentTile(
                          title: 'Tunai',
                          assetPath: 'assets/images/cash.png',
                          isSelected: _paymentMethod == 'Tunai',
                          onTap: () =>
                              setState(() => _paymentMethod = 'Tunai'),
                        ),
                        PaymentTile(
                          title: 'QRIS',
                          assetPath: 'assets/images/qris_bayar.png',
                          isSelected: _paymentMethod == 'QRIS',
                          onTap: () =>
                              setState(() => _paymentMethod = 'QRIS'),
                        ),
                        const SizedBox(height: 25),
                        const CheckoutSectionTitle('Rincian Pembayaran'),
                        const SizedBox(height: 12),
                        SummaryCard(
                          subtotal: _subtotalProduk,
                          total: _totalBayar,
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                CheckoutBottomBar(
                  total: _totalBayar,
                  isLoading: _isLoading,
                  onBuatPesanan: _buatPesananKeDatabase,
                ),
              ],
            ),
    );
  }
}