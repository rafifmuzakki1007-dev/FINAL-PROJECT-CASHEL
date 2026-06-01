import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'hasil_akhir_pembatalan.dart';
import 'rincian_pesanan_screen.dart'; // untuk ItemPesanan

class HalamanBatalScreen extends StatefulWidget {
  final int idPesanan;
  final String namaProduk;
  final int harga;
  final int jumlah;
  final String imagePath;
  final String metodePembayaran;
  final String tanggalPesanan;

  const HalamanBatalScreen({
    super.key,
    required this.idPesanan,
    required this.namaProduk,
    required this.harga,
    required this.jumlah,
    required this.imagePath,
    required this.metodePembayaran,
    required this.tanggalPesanan,
  });

  @override
  State<HalamanBatalScreen> createState() => _HalamanBatalScreenState();
}

class _HalamanBatalScreenState extends State<HalamanBatalScreen> {

  static const String _baseUrl = "http://192.168.18.154/api_cashel/auth";

  final List<String> _alasanList = [
    'Salah pesan produk',
    'Ingin mengubah jumlah pesanan',
    'Ingin mengubah metode pembayaran',
    'Harga terlalu mahal',
    'Produk tidak dibutuhkan lagi',
    'Lainnya',
  ];

  String? _alasanDipilih;
  final TextEditingController _catatanController = TextEditingController();
  bool _isLoading = false;

  int get _totalHarga => widget.harga * widget.jumlah;

  Future<void> _batalkanPesanan() async {
    if (_alasanDipilih == null) {
      _showSnackbar('Pilih alasan pembatalan terlebih dahulu', Colors.red);
      return;
    }

    final alasanFinal = (_alasanDipilih == 'Lainnya' &&
            _catatanController.text.trim().isNotEmpty)
        ? _catatanController.text.trim()
        : _alasanDipilih!;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$_baseUrl/batalkan_pesanan.php');

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "id_pesanan": widget.idPesanan,
              "alasan": alasanFinal,
              "diminta_oleh": "Pembeli",
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw 'Server error: HTTP ${response.statusCode}\nBody: ${response.body}';
      }

      final rawBody = response.body.trim();
      if (rawBody.isEmpty) {
        throw 'Server mengembalikan response kosong. Cek PHP error log.';
      }

      Map<String, dynamic> result;
      try {
        result = jsonDecode(rawBody);
      } catch (e) {
        throw 'Response bukan JSON valid.\nRaw: $rawBody';
      }

      if (result['status'] == 'success') {
        if (!mounted) return;

        final waktuBatal = result['tgl_batal'] != null
            ? result['tgl_batal'].toString()
            : DateTime.now()
                .toString()
                .substring(0, 16)
                .replaceAll('T', ' ');

        // Konversi single item - List<ItemPesanan> sesuai konstruktor HasilAkhirPembatalan
        final items = [
          ItemPesanan(
            namaProduk: widget.namaProduk,
            imagePath:  widget.imagePath,
            harga:      widget.harga,
            jumlah:     widget.jumlah,
          ),
        ];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HasilAkhirPembatalan(
              idPesanan:        widget.idPesanan,
              items:            items,           
              metodePembayaran: widget.metodePembayaran,
              tanggalPesanan:   widget.tanggalPesanan,
              alasanPembatalan: alasanFinal,
              waktuPembatalan:  waktuBatal,
            ),
          ),
        );
      } else {
        throw result['message'] ?? 'Gagal membatalkan pesanan';
      }
    } on http.ClientException catch (e) {
      _showSnackbar(
          'Tidak bisa terhubung ke server.\nPastikan URL API sudah benar.\nDetail: $e',
          Colors.red);
    } catch (e) {
      _showSnackbar('$e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Batalkan Pesanan',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Produk 
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E2E2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(3)),
                        child: const Text('Star+',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      const Text('CASHEL',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          widget.imagePath,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.namaProduk,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            Text('x${widget.jumlah}',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 6),
                            Text('Rp${widget.harga}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pesanan',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Text('Rp$_totalHarga',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            //Form alasan batal
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E2E2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alasan Pembatalan',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _alasanDipilih,
                    hint: const Text('Pilih alasan',
                        style: TextStyle(fontSize: 13)),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _alasanList
                        .map((a) => DropdownMenuItem(
                            value: a,
                            child: Text(a,
                                style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (val) => setState(() => _alasanDipilih = val),
                  ),
                  if (_alasanDipilih == 'Lainnya') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _catatanController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tulis alasan lengkap...',
                        hintStyle: const TextStyle(fontSize: 13),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tombol batalkan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _batalkanPesanan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Batalkan Pesanan',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
              ),
            ),

            const SizedBox(height: 12),

            // Tombol kembali
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Kembali',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}