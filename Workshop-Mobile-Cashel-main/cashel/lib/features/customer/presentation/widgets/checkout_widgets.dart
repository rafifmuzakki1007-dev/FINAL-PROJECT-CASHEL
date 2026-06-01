import 'package:flutter/material.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});
  @override
  Widget build(BuildContext context) => const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1));
}

class RincianRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  const RincianRow({super.key, required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isBold ? Colors.black : const Color(0xFF7C7C7C), fontFamily: 'Poppins')),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}

// ── Helper format rupiah ──
String formatRupiah(int value) {
  if (value == 0) return '0';
  String s = value.toString();
  String result = '';
  int count = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) result = '.$result';
    result = s[i] + result;
    count++;
  }
  return result;
}

// ── Section title ──
class CheckoutSectionTitle extends StatelessWidget {
  final String title;
  const CheckoutSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
            fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w500),
      );
}

// ── Satu baris item produk di dalam card ──
class CheckoutItemRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final String fallbackImage;
  final bool isLast;

  const CheckoutItemRow({
    super.key,
    required this.item,
    required this.fallbackImage,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final rawPrice = (item['price'] ?? item['harga'] ?? '0').toString();
    final harga = int.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final jumlah = (item['jumlah'] as int? ?? 1);
    final subtotalItem = harga * jumlah;
    final nama = (item['title'] ?? item['namaProduk'] ?? 'Produk').toString();
    final gambar = (item['imagePath'] ?? fallbackImage).toString();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    gambar,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.image_outlined, size: 32, color: Colors.grey),
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
                      nama,
                      style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF222222)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rp${formatRupiah(harga)}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                color: Color(0xFF888888))),
                        Text('x$jumlah',
                            style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                color: Color(0xFF888888))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Rp${formatRupiah(subtotalItem)}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF222222)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
              height: 1, thickness: 1, color: Color(0xFFF5F5F5),
              indent: 16, endIndent: 16),
      ],
    );
  }
}

// ── Card produk (header toko + list item + footer subtotal) ──
class CheckoutProductCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String fallbackImage;

  const CheckoutProductCard({
    super.key,
    required this.items,
    required this.fallbackImage,
  });

  int get _subtotal {
    int total = 0;
    for (final item in items) {
      final rawPrice = (item['price'] ?? item['harga'] ?? '0').toString();
      final harga = int.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      total += harga * (item['jumlah'] as int? ?? 1);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header toko
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2929),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text('Star+',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins')),
                ),
                const SizedBox(width: 8),
                const Text('CASHEL',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color(0xFF222222))),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 16, color: Color(0xFFAAAAAA)),
              ],
            ),
          ),
          // List item
          ...items.asMap().entries.map((e) => CheckoutItemRow(
                item: e.value,
                fallbackImage: fallbackImage,
                isLast: e.key == items.length - 1,
              )),
          // Footer subtotal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${items.length} produk',
                    style: const TextStyle(
                        fontSize: 12, fontFamily: 'Poppins', color: Color(0xFF888888))),
                Row(
                  children: [
                    const Text('Subtotal: ',
                        style: TextStyle(
                            fontSize: 12, fontFamily: 'Poppins', color: Color(0xFF888888))),
                    Text('Rp${formatRupiah(_subtotal)}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222222))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tile metode pembayaran ──
class PaymentTile extends StatelessWidget {
  final String title;
  final String assetPath;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentTile({
    super.key,
    required this.title,
    required this.assetPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF3498DB) : const Color(0xFFE2E2E2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Image.asset(assetPath,
                width: 26,
                height: 26,
                errorBuilder: (c, e, s) => const Icon(Icons.payment)),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 14, fontFamily: 'Poppins')),
            const Spacer(),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF3498DB) : const Color(0xFFE2E2E2),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card rincian pembayaran ──
class SummaryCard extends StatelessWidget {
  final int subtotal;
  final int total;

  const SummaryCard({super.key, required this.subtotal, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E2E2))),
      child: Column(
        children: [
          RincianRow(label: 'Subtotal Pesanan', value: 'Rp${formatRupiah(subtotal)}'),
          const SectionDivider(),
          RincianRow(label: 'Total Pembayaran', value: 'Rp${formatRupiah(total)}', isBold: true),
        ],
      ),
    );
  }
}

// ── Bottom bar checkout ──
class CheckoutBottomBar extends StatelessWidget {
  final int total;
  final bool isLoading;
  final VoidCallback onBuatPesanan;

  const CheckoutBottomBar({
    super.key,
    required this.total,
    required this.isLoading,
    required this.onBuatPesanan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 15, 25, 40),
      decoration: const BoxDecoration(
        color: Color(0xFFEAF3FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total',
                  style: TextStyle(fontSize: 11, fontFamily: 'Poppins')),
              Text('Rp${formatRupiah(total)}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins')),
            ],
          ),
          ElevatedButton(
            onPressed: isLoading ? null : onBuatPesanan,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17)),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Buat Pesanan',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}