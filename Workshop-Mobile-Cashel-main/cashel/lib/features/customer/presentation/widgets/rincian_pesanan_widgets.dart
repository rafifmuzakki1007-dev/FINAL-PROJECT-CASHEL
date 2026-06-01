import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/rincian_pesanan_screen.dart';

// ── Helper ──────────────────────────────────────────────────────────────────
String _rp(int value) =>
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
        .format(value);

// ==========================================
// WIDGET: Banner Status Pesanan
// ==========================================
class BannerStatusPesanan extends StatelessWidget {
  final bool isSelesai;
  final String metodePembayaran;
  final String? waktuSelesai;

  const BannerStatusPesanan({
    super.key,
    required this.isSelesai,
    required this.metodePembayaran,
    this.waktuSelesai,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        isSelesai ? const Color(0xFF27AE60) : const Color(0xFF2980B9);
    final IconData statusIcon =
        isSelesai ? Icons.check_circle_rounded : Icons.access_time_rounded;
    final String title =
        isSelesai ? "Pesanan Selesai" : "Sedang Diproses";
    final String subtitle = isSelesai
        ? "Pesanan selesai pada $waktuSelesai"
        : (metodePembayaran == 'QRIS'
            ? "Silakan datang ke toko untuk mengambil barang"
            : "Silakan datang ke toko untuk melakukan pembayaran");

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor, bgColor.withOpacity(0.82)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        letterSpacing: 0.2)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                        fontFamily: 'Poppins')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// WIDGET: Card Produk Pesanan (multi-item)
// ==========================================
class CardProdukPesanan extends StatelessWidget {
  final List<ItemPesanan> items;
  final int totalBayar;

  const CardProdukPesanan({
    super.key,
    required this.items,
    required this.totalBayar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header toko ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C),
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text('Star+',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins')),
                ),
                const SizedBox(width: 8),
                const Text('CASHEL',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: Color(0xFF1A1A2E))),
                const Spacer(),
                Text('${items.length} item',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontFamily: 'Poppins')),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

          // ── List item ──────────────────────────────
          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _ItemRow(item: item),
                if (idx < items.length - 1)
                  const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF7F7F7),
                      indent: 16,
                      endIndent: 16),
              ],
            );
          }),

          // ── Footer total ───────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD6EAFF)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pesanan',
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
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final ItemPesanan item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final subtotal = item.harga * item.jumlah;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gambar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Icon(
                    Icons.image_not_supported_outlined,
                    size: 24,
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
                Text(item.namaProduk,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Text(_rp(item.harga),
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontFamily: 'Poppins')),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Qty + subtotal
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('x${item.jumlah}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color(0xFF555555))),
              ),
              const SizedBox(height: 5),
              Text(_rp(subtotal),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: Color(0xFF1A1A2E))),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// WIDGET: Detail Pemesanan
// ==========================================
class CardDetailPemesanan extends StatelessWidget {
  final String metodePembayaran;
  final String waktuPemesanan;
  final int noPesanan;

  const CardDetailPemesanan({
    super.key,
    required this.metodePembayaran,
    required this.waktuPemesanan,
    required this.noPesanan,
  });

  @override
  Widget build(BuildContext context) {
    final String noFormatted = "#${noPesanan.toString().padLeft(6, '0')}";
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text("Detail Pemesanan",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: Color(0xFF1A1A2E))),
            ],
          ),
          const SizedBox(height: 14),
          _DetailTile(
            icon: Icons.tag_rounded,
            label: "No. Pesanan",
            value: noFormatted,
            valueColor: const Color(0xFF2980B9),
            valueBold: true,
          ),
          const _DividerLine(),
          _DetailTile(
            icon: Icons.payment_rounded,
            label: "Metode Pembayaran",
            value: metodePembayaran,
          ),
          const _DividerLine(),
          _DetailTile(
            icon: Icons.schedule_rounded,
            label: "Waktu Pemesanan",
            value: waktuPemesanan,
          ),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 20, thickness: 1, color: Color(0xFFF5F5F5));
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF3498DB)),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontFamily: 'Poppins')),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight:
                    valueBold ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'Poppins',
                color: valueColor ?? const Color(0xFF1A1A2E))),
      ],
    );
  }
}

// ==========================================
// WIDGET: Bottom Bar Tombol Pesanan
// ==========================================
class BottomBarPesanan extends StatelessWidget {
  final bool isSelesai;
  final bool isAdminKonfirmasi;
  final VoidCallback onBatalkan;
  final VoidCallback onSelesai;
  final VoidCallback onBeliLagi;

  const BottomBarPesanan({
    super.key,
    required this.isSelesai,
    required this.isAdminKonfirmasi,
    required this.onBatalkan,
    required this.onSelesai,
    required this.onBeliLagi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -4))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: isSelesai
          ? SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onBeliLagi,
                icon: const Icon(Icons.shopping_bag_outlined,
                    size: 18, color: Color(0xFF3498DB)),
                label: const Text("Beli Lagi",
                    style: TextStyle(
                        color: Color(0xFF3498DB),
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAF4FD),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          : Row(
              children: [
                // Batalkan
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: onBatalkan,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDDDDDD)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Batalkan",
                          style: TextStyle(
                              color: Color(0xFF555555),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              fontFamily: 'Poppins')),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Pesanan Selesai
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isAdminKonfirmasi ? onSelesai : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        disabledBackgroundColor: const Color(0xFFE8E8E8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isAdminKonfirmasi
                                ? Icons.check_circle_outline_rounded
                                : Icons.lock_clock_outlined,
                            size: 16,
                            color: isAdminKonfirmasi
                                ? Colors.white
                                : Colors.grey[400],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Pesanan Selesai",
                            style: TextStyle(
                                color: isAdminKonfirmasi
                                    ? Colors.white
                                    : Colors.grey[400],
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}