import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'pesanan_diterima.dart';
import 'rincian_pesanan_screen.dart'; // untuk ItemPesanan

class PembayaranQRISPage extends StatefulWidget {
  final int idPesanan;
  final List<ItemPesanan> items; // semua produk
  final int totalBayar;
  final int ongkir;

  const PembayaranQRISPage({
    super.key,
    required this.idPesanan,
    required this.items,
    required this.totalBayar,
    required this.ongkir,
  });

  @override
  State<PembayaranQRISPage> createState() => _PembayaranQRISPageState();
}

class _PembayaranQRISPageState extends State<PembayaranQRISPage> {
  File? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  final String qrisAssetPath = 'assets/images/qris.png';

  static const String _serverIp = "192.168.18.154";
  static const String _baseUrl = "http://$_serverIp/api_cashel/auth";

  // Simpan QR ke galeri
  Future<void> _downloadQR() async {
    try {
      final byteData = await rootBundle.load(qrisAssetPath);
      final Uint8List bytes = byteData.buffer.asUint8List();
      final result = await SaverGallery.saveImage(
        Uint8List.fromList(bytes),
        quality: 100,
        fileName: "QRIS_Cashel_${DateTime.now().millisecondsSinceEpoch}.png",
        androidRelativePath: "Pictures/Cashel",
        skipIfExists: false,
      );
      _showSnackBar(
        result.isSuccess
            ? 'QR Code berhasil disimpan ke Galeri!'
            : 'Gagal menyimpan: ${result.errorMessage}',
      );
    } catch (e) {
      _showSnackBar('Terjadi kesalahan saat menyimpan QR.');
    }
  }

  // Bagikan QR
  Future<void> _shareQR() async {
    try {
      final byteData = await rootBundle.load(qrisAssetPath);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/share_qris.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      await Share.shareXFiles([XFile(file.path)],
          text: 'Scan QRIS ini untuk pembayaran.');
    } catch (e) {
      _showSnackBar('Gagal membagikan QR Code.');
    }
  }

  // pilih gambar dari galeri
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  // upload bukti bayar
  Future<void> _konfirmasiPembayaran() async {
    if (_imageFile == null) return;
    setState(() => _isUploading = true);

    try {
      final url = Uri.parse('$_baseUrl/konfirmasi_pembayaran.php');

      final request = http.MultipartRequest('POST', url)
        ..fields['id_pesanan'] = widget.idPesanan.toString()
        ..files.add(
          await http.MultipartFile.fromPath(
            'bukti_pembayaran',
            _imageFile!.path,
          ),
        );

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await streamedResponse.stream.bytesToString();

      debugPrint("Upload status : ${streamedResponse.statusCode}");
      debugPrint("Upload body   : $responseBody");

      Map<String, dynamic> result;
      try {
        result = jsonDecode(responseBody);
      } catch (_) {
        throw "Respon server tidak valid: $responseBody";
      }

      if (result['status'] == 'success') {
        if (!mounted) return;
        _navigateToSuccess();
      } else {
        if (!mounted) return;
        _showSnackBar(result['message'] ?? 'Gagal upload bukti. Coba lagi.');
      }
    } catch (e) {
      debugPrint("Error upload: $e");
      if (!mounted) return;
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // navigasi ke halaman pesanan diterima
  void _navigateToSuccess() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PesananDiterimaPage(
          idPesanan: widget.idPesanan,
          metodePembayaran: 'QRIS',
          items: widget.items,
          totalBayar: widget.totalBayar,
          ongkir: widget.ongkir,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween = Tween(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOutQuart));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp${buffer.toString().split('').reversed.join()}';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: const Color(0xFF3498DB),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPaid = _imageFile != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pembayaran QRIS',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Card QR Code
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Image.asset(qrisAssetPath, width: 220, height: 220),
                  const SizedBox(height: 15),
                  const Text(
                    "Scan & Input Nominal Manual",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Total: ${_formatRupiah(widget.totalBayar)}",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF3498DB),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionButton(
                          Icons.file_download_outlined, "Simpan", _downloadQR),
                      const SizedBox(width: 40),
                      _actionButton(
                          Icons.share_outlined, "Bagikan", _shareQR),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Upload bukti
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Upload Bukti Pembayaran",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _isUploading ? null : _pickImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPaid ? Colors.green : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              size: 40, color: Colors.grey.shade400),
                          const Text(
                            "Ketuk untuk upload bukti",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: (isPaid && !_isUploading) ? _konfirmasiPembayaran : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3498DB),
            disabledBackgroundColor: Colors.grey.shade300,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isUploading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  isPaid ? 'Konfirmasi Pembayaran' : 'Unggah Bukti Dahulu',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: const Color(0xFF3498DB)),
          ),
          const SizedBox(height: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}