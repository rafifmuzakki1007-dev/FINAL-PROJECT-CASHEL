import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/riwayat_pesanan_screen.dart';
import '../screens/rincian_pesanan_screen.dart'; // ItemPesanan

// ── Helper format Rupiah ─────────────────────────────────────────────────────
String _rp(int value) =>
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
        .format(value);

// ── List pesanan per tab ─────────────────────────────────────────────────────
class PesananList extends StatelessWidget {
  final List<RiwayatPesananItem> pesananList;
  final void Function(RiwayatPesananItem) onLihatDetail;

  const PesananList({
    super.key,
    required this.pesananList,
    required this.onLihatDetail,
  });

  @override
  Widget build(BuildContext context) {
    if (pesananList.isEmpty) {
      return const EmptyViewRiwayat();
    }
    return RefreshIndicator(
      color: const Color(0xFF3498DB),
      onRefresh: () async {},
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        itemCount: pesananList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => CardPesanan(
          pesanan: pesananList[i],
          onLihatDetail: () => onLihatDetail(pesananList[i]),
        ),
      ),
    );
  }
}

// ── Card satu pesanan ────────────────────────────────────────────────────────
class CardPesanan extends StatelessWidget {
  final RiwayatPesananItem pesanan;
  final VoidCallback onLihatDetail;

  const CardPesanan({
    super.key,
    required this.pesanan,
    required this.onLihatDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Badge status ──────────────────────────────
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 14, 0),
              child: StatusBadgeRiwayat(status: pesanan.status),
            ),
          ),

          // ── List item produk ──────────────────────────
          ...pesanan.items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Column(
              children: [
                ProdukRowRiwayat(item: item),
                if (idx < pesanan.items.length - 1)
                  const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF0F0F0),
                      indent: 16,
                      endIndent: 16),
              ],
            );
          }),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

          // ── Footer: total + tombol ─────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total ${pesanan.items.length} Produk:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _rp(pesanan.totalBayar),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    onPressed: onLihatDetail,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFF3498DB), width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color(0xFF3498DB),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Row satu produk dalam card ───────────────────────────────────────────────
class ProdukRowRiwayat extends StatelessWidget {
  final ItemPesanan item;
  const ProdukRowRiwayat({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          // Gambar — imagePath sudah di-prefix assets/images/ dari fromJson
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.imagePath.startsWith('http')
                  ? Image.network(
                      item.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported_outlined,
                          size: 26,
                          color: Colors.grey),
                    )
                  : Image.asset(
                      item.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported_outlined,
                          size: 26,
                          color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaProduk,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jumlah',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: 'Poppins'),
                    ),
                    Text(
                      'x${item.jumlah}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: 'Poppins'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _rp(item.harga * item.jumlah),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge status ─────────────────────────────────────────────────────────────
class StatusBadgeRiwayat extends StatelessWidget {
  final String status;
  const StatusBadgeRiwayat({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case 'selesai':
        bg = const Color(0xFFE8F8EF);
        text = const Color(0xFF27AE60);
        label = 'SELESAI';
        break;
      case 'dibatalkan':
        bg = const Color(0xFFFFECEC);
        text = const Color(0xFFE74C3C);
        label = 'DIBATALKAN';
        break;
      case 'tertunda':
      case 'diproses':
      default:
        bg = const Color(0xFFE3F0FF);
        text = const Color(0xFF3498DB);
        label = 'PROSES';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
          color: text,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class EmptyViewRiwayat extends StatelessWidget {
  const EmptyViewRiwayat({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada pesanan',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────
class ErrorViewRiwayat extends StatelessWidget {
  final String pesan;
  final VoidCallback onRetry;

  const ErrorViewRiwayat({
    super.key,
    required this.pesan,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            pesan,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF3498DB), size: 18),
            label: const Text(
              'Coba Lagi',
              style: TextStyle(
                color: Color(0xFF3498DB),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}