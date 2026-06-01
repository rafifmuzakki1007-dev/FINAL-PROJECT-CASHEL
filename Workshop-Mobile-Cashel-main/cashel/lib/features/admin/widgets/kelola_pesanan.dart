import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/order_model.dart';

class KelolaPesananWidget extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onSuccessRefresh; // Callback saat status berhasil diubah di DB

  const KelolaPesananWidget({
    super.key,
    required this.order,
    required this.onSuccessRefresh,
  });

  @override
  State<KelolaPesananWidget> createState() => _KelolaPesananWidgetState();
}

class _KelolaPesananWidgetState extends State<KelolaPesananWidget> {
  bool _isLoading = false;

  // Fungsi untuk menembak API Update Status ke PHP MySQL
  Future<void> _processUpdateStatus(String statusBaru) async {
    setState(() {
      _isLoading = true;
    });

    // Sesuaikan URL dengan IP lokal laptop/XAMPP kamu
    final String url = 'http://192.168.18.154/api_cashel/transaction/update_order_status.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_pesanan": widget.order.id,
          "status": statusBaru,
        }),
      );

      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);
        if (resBody['success'] == true) {
          // Tutup bottom sheet terlebih dahulu
          if (mounted) Navigator.pop(context);
          // Jalankan fungsi refresh di halaman detail utama
          widget.onSuccessRefresh();
        } else {
          _showSnackBar("Gagal: ${resBody['message']}");
        }
      } else {
        _showSnackBar("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Gagal menyambungkan ke database: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Format angka jadi format mata uang: 150000 -> "150.000"
  String _formatCurrency(dynamic amount) {
    final num value = (amount is num) ? amount : num.tryParse(amount.toString()) ?? 0;
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  static const String _baseUrl = 'http://192.168.18.154/api_cashel';

  // Tampilkan bukti pembayaran QRIS dalam dialog
  void _showBuktiPembayaran() {
    final String? buktiPath = widget.order.buktiPembayaran;
    final String? buktiUrl = (buktiPath != null && buktiPath.isNotEmpty)
        ? '$_baseUrl/$buktiPath'
        : null;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Bukti Pembayaran QRIS",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              (buktiUrl != null && buktiUrl.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        buktiUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Padding(
                            padding: EdgeInsets.all(30),
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => const Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(Icons.broken_image_outlined, size: 60, color: Colors.grey),
                              SizedBox(height: 8),
                              Text("Gagal memuat gambar", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.image_not_supported_outlined, size: 60, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Bukti pembayaran tidak tersedia", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Modal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Kelola Pesanan", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 28),
              ),
            ],
          ),
          const Divider(thickness: 1),
          _buildInfoRow("ID Pesanan", "#${widget.order.id}", isBold: true),
          _buildInfoRow(
            "Total Harga",
            "Rp ${_formatCurrency(widget.order.totalHarga)}",
            isBold: true,
          ),
          const SizedBox(height: 25),

          // Tombol Cek Bukti Pembayaran (hanya muncul jika metode pembayaran QRIS)
          if (widget.order.metodePembayaran.toLowerCase() == 'qris') ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showBuktiPembayaran,
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text(
                  "Cek Bukti Pembayaran",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  side: const BorderSide(color: Color(0xFF3498DB), width: 1.5),
                  foregroundColor: const Color(0xFF3498DB),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Tampilan Tombol secara Dinamis berdasarkan logika loading & status pesanan
          _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: CircularProgressIndicator(),
                  ),
                )
              : _buildDynamicButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Fungsi Pemisah Logika Tombol Sesuai Status Pesanan
  Widget _buildDynamicButtons() {
    String currentStatus = widget.order.status.toLowerCase();

    // ALUR 1: Jika status 'tertunda' -> Tampilkan tombol Tolak & Terima berdampingan
    if (currentStatus == 'tertunda') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _processUpdateStatus('dibatalkan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD31010),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Tolak", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _processUpdateStatus('proses'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Terima", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    } 
    
    // ALUR 2: Jika status 'proses' -> Tampilkan satu tombol 'Selesai' lebar penuh
    else if (currentStatus == 'proses') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _processUpdateStatus('selesai'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Warna hijau untuk penyelesaian orderan
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: const Text("Selesai", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    }

    // Alur Default jika pesanan sudah berstatus 'selesai' atau 'dibatalkan'
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "Pesanan telah diproses dan status tidak bisa diubah kembali.",
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }
}