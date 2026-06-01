import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'rincian_pesanan_screen.dart'; // untuk ItemPesanan

class HasilAkhirPembatalan extends StatelessWidget {
  final int idPesanan;
  final List<ItemPesanan> items;
  final String metodePembayaran;
  final String tanggalPesanan;
  final String alasanPembatalan;
  final String waktuPembatalan;

  const HasilAkhirPembatalan({
    super.key,
    required this.idPesanan,
    required this.items,
    required this.metodePembayaran,
    required this.tanggalPesanan,
    required this.alasanPembatalan,
    required this.waktuPembatalan,
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
        title: const Text('Rincian Pesanan',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins')),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Banner ──
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              color: const Color(0xFF3B95DE),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pembatalan Berhasil',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Poppins')),
                        const SizedBox(height: 4),
                        Text('pada $waktuPembatalan',
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'Poppins')),
                      ],
                    ),
                  ),
                  const Icon(Icons.assignment_turned_in_outlined,
                      color: Colors.white, size: 36),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Card Produk (semua item) ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
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
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins')),
                      ),
                      const SizedBox(width: 8),
                      const Text('CASHEL',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'Poppins')),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // List semua produk
                  ...items.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item.imagePath.startsWith('http')
                                  ? Image.network(item.imagePath,
                                      width: 65,
                                      height: 65,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => _imgFallback())
                                  : Image.asset(item.imagePath,
                                      width: 65,
                                      height: 65,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => _imgFallback()),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.namaProduk,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Poppins'),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text('x${item.jumlah}',
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontFamily: 'Poppins')),
                                ],
                              ),
                            ),
                            Text(_rp(item.harga * item.jumlah),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    fontFamily: 'Poppins')),
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

                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pesanan',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              fontFamily: 'Poppins')),
                      Text(_rp(totalBayar),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              color: Color(0xFF2980B9))),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Rincian Pembatalan ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rincian Pembatalan',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 12),
                  _infoRow('Alasan Pembatalan', alasanPembatalan),
                  const SizedBox(height: 8),
                  _infoRow('Diminta Oleh', 'Pembeli'),
                  const SizedBox(height: 8),
                  _infoRow('Waktu Pembatalan', waktuPembatalan),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Detail Pemesanan ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detail Pemesanan',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 12),
                  _infoRow('No. Pesanan', '#$idPesanan'),
                  const SizedBox(height: 8),
                  _infoRow('Metode Pembayaran', metodePembayaran),
                  const SizedBox(height: 8),
                  _infoRow('Waktu Pemesanan', tanggalPesanan),
                ],
              ),
            ),

            const SizedBox(height: 90),
          ],
        ),
      ),

      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Rincian Pembatalan',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Pop 2x: HasilAkhirPembatalan → RincianPembatalanBerhasil → kembali ke Riwayat
                  int popCount = 0;
                  Navigator.popUntil(context, (route) => popCount++ >= 2);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B95DE),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Kembali',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgFallback() => Container(
        width: 65,
        height: 65,
        color: Colors.grey[200],
        child: const Icon(Icons.image, color: Colors.grey),
      );

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontFamily: 'Poppins')),
        const SizedBox(width: 12),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins')),
        ),
      ],
    );
  }
}