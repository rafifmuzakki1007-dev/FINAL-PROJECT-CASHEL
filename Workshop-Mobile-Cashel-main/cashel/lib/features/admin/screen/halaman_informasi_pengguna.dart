import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/order_model.dart';
import '../widgets/kelola_pesanan.dart';

class HalamanInformasiPengguna extends StatefulWidget {
  final OrderModel order;

  const HalamanInformasiPengguna({super.key, required this.order});

  @override
  State<HalamanInformasiPengguna> createState() => _HalamanInformasiPenggunaState();
}

class _HalamanInformasiPenggunaState extends State<HalamanInformasiPengguna> {
  static const String _baseUrl = 'http://192.168.18.154/api_cashel';

  late OrderModel currentOrder;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    currentOrder = widget.order;
    // Fetch ulang data lengkap (termasuk metode_pembayaran & bukti_pembayaran)
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshOrderData());
  }

  Future<void> _refreshOrderData() async {
    setState(() => _isRefreshing = true);
    final url = '$_baseUrl/transaction/get_detail_pesanan.php?id=${currentOrder.id}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          setState(() => currentOrder = OrderModel.fromJson(body['data']));
        }
      }
    } catch (e) {
      debugPrint("Gagal refresh: $e");
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'tertunda':   return Colors.orange;
      case 'proses':     return Colors.blue;
      case 'selesai':    return Colors.green;
      case 'dibatalkan': return Colors.red;
      default:           return Colors.black54;
    }
  }

  String _formatTanggal(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                         'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${dt.day.toString().padLeft(2, '0')} ${bulan[dt.month]} ${dt.year}'
             ', ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  String _formatRupiah(String angka) {
    final str = angka.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  /// Foto akun: nilai DB sudah berupa path lengkap "uploads/foto_profil/profil_6_xxx.jpg"
  /// → cukup gabung dengan baseUrl
  String _buildFotoAkunUrl(String foto) {
    if (foto.isEmpty) return '';
    return '$_baseUrl/$foto';
  }

  /// Foto produk: nilai DB hanya nama file "pensil.png"
  /// → tambahkan subfolder uploads/produk/
  String _buildFotoProdukUrl(String namaFile) {
    if (namaFile.isEmpty) return '';
    return '$_baseUrl/uploads/produk/$namaFile';
  }

  /// Widget gambar network dengan loading & fallback
  Widget _networkImage(String url, {double size = 50}) {
    if (url.isEmpty) {
      return Container(
        width: size, height: size,
        color: Colors.grey[200],
        child: Icon(Icons.image, size: size * 0.4, color: Colors.grey),
      );
    }
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return Container(
          width: size, height: size,
          color: Colors.grey[200],
          child: const Center(
            child: SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (ctx, _, __) => Container(
        width: size, height: size,
        color: Colors.grey[200],
        child: Icon(Icons.image_not_supported, size: size * 0.4, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String fotoAkunUrl = _buildFotoAkunUrl(currentOrder.fotoCustomer);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Detail Pesanan",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrderData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Foto Profil Customer ──────────────────────────────────
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF2596FF),
                  backgroundImage: fotoAkunUrl.isNotEmpty
                      ? NetworkImage(fotoAkunUrl)
                      : null,
                  onBackgroundImageError: fotoAkunUrl.isNotEmpty
                      ? (_, __) {}
                      : null,
                  child: fotoAkunUrl.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // ── Card Info Utama ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    _buildRow("ID Order", "#${currentOrder.id}"),
                    const Divider(),
                    _buildRow("Customer", currentOrder.namaCustomer),
                    const Divider(),
                    _buildRow("Tanggal", _formatTanggal(currentOrder.tanggal)),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Status",
                              style: TextStyle(color: Colors.black54)),
                          Text(
                            currentOrder.status.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(currentOrder.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildDetailPembayaran(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100,
              child: Text(label, style: const TextStyle(color: Colors.black54))),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPembayaran(BuildContext context) {
    final List<String> items = currentOrder.produkDibeli.split('; ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Produk yang Dibeli",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final part        = items[index].split('|');
              final namaProduk  = part[0].trim();
              // Nilai DB: "pensil.png" → tambah prefix folder
              final namaFile    = part.length > 1 ? part[1].trim() : '';
              // Gambar produk ada di assets Flutter, bukan server
              final imgUrl      = namaFile.isNotEmpty ? 'assets/images/$namaFile' : '';

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imgUrl.isNotEmpty
                      ? Image.asset(
                          imgUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) => Container(
                            width: 50, height: 50,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 50, height: 50,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 20, color: Colors.grey),
                        ),
                ),
                title: Text(namaProduk,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text("Jumlah: 1"),
              );
            },
          ),

          const Divider(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Pesanan", style: TextStyle(fontSize: 14)),
              Text(
                _formatRupiah(currentOrder.totalHarga),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (currentOrder.status.toLowerCase() == 'tertunda' ||
              currentOrder.status.toLowerCase() == 'proses')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => KelolaPesananWidget(
                      order: currentOrder,
                      onSuccessRefresh: _refreshOrderData,
                    ),
                  );
                },
                child: const Text("KELOLA STATUS PESANAN",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}