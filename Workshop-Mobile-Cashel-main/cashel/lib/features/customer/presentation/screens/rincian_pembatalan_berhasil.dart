import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../customer/presentation/screens/main_navigation.dart';
import 'hasil_akhir_pembatalan.dart';
import 'rincian_pesanan_screen.dart'; // untuk ItemPesanan

class RincianPembatalanBerhasil extends StatelessWidget {
  final int idPesanan;
  final List<ItemPesanan> items;
  final String alasan;
  final String waktuBatal;
  final String metodePembayaran;
  final String tanggalPesanan;
  final String namaToko;
  final bool isStarPlus;

  const RincianPembatalanBerhasil({
    super.key,
    required this.idPesanan,
    required this.items,
    required this.alasan,
    required this.waktuBatal,
    required this.metodePembayaran,
    required this.tanggalPesanan,
    this.namaToko = 'CASHEL',
    this.isStarPlus = true,
  });

  String _rp(int v) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
          .format(v);

  @override
  Widget build(BuildContext context) {
    final int totalBayar =
        items.fold(0, (sum, i) => sum + i.harga * i.jumlah);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Rincian Pembatalan",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'Poppins'),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Color(0xFFE0E0E0)),

                  // ── Banner Pembatalan Berhasil ──
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Pembatalan Berhasil",
                              style: TextStyle(
                                color: Color(0xFF29ABE2),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "pada $waktuBatal",
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        Image.asset(
                          'assets/images/return.png',
                          width: 52,
                          height: 52,
                          errorBuilder: (_, __, ___) => Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFF29ABE2), width: 2),
                            ),
                            child: const Icon(Icons.check,
                                color: Color(0xFF29ABE2), size: 28),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Card Produk (semua item) ──
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header toko
                        Row(
                          children: [
                            if (isStarPlus) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE53935),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('Star+',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins')),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              namaToko.isNotEmpty ? namaToko : 'CASHEL',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // List semua produk
                        ...items.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          final subtotal = item.harga * item.jumlah;
                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item.imagePath.startsWith('http')
                                        ? Image.network(item.imagePath,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) =>
                                                _imgFallback())
                                        : Image.asset(item.imagePath,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) =>
                                                _imgFallback()),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.namaProduk,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              fontFamily: 'Poppins'),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Jumlah",
                                                style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 12,
                                                    fontFamily: 'Poppins')),
                                            Text("x${item.jumlah}",
                                                style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 12,
                                                    fontFamily: 'Poppins')),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            _rp(subtotal),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                fontFamily: 'Poppins'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (idx < items.length - 1)
                                const Divider(
                                    height: 20,
                                    thickness: 0.5,
                                    color: Color(0xFFF0F0F0)),
                            ],
                          );
                        }),

                        // Total
                        const Divider(
                            height: 20,
                            thickness: 0.5,
                            color: Color(0xFFE0E0E0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Pesanan",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    fontFamily: 'Poppins')),
                            Text(_rp(totalBayar),
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Poppins',
                                    color: Color(0xFF2980B9))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Info pembatalan ──
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Column(
                      children: [
                        _buildInfoRow("Diminta oleh", "Pembeli"),
                        _buildDivider(),
                        _buildInfoRow("Diminta pada", waktuBatal),
                        _buildDivider(),
                        _buildInfoRow("Alasan", alasan),
                        _buildDivider(),
                        _buildInfoRow("Metode pembayaran", metodePembayaran),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(
              height: 1, thickness: 0.5, color: Color(0xFFE0E0E0)),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HasilAkhirPembatalan(
                        idPesanan: idPesanan,
                        items: items,
                        metodePembayaran: metodePembayaran,
                        tanggalPesanan: tanggalPesanan,
                        alasanPembatalan: alasan,
                        waktuPembatalan: waktuBatal,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Color(0xFFBDBDBD)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  "Rincian Pesanan",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgFallback() => Container(
        color: Colors.grey[200],
        width: 60,
        height: 60,
        child: const Icon(Icons.image, color: Colors.grey),
      );

  Widget _buildDivider() =>
      const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0F0F0));

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontFamily: 'Poppins')),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }
}