import 'package:flutter/material.dart';
import '../../../data/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  Color _getDynamicStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'tertunda':    return Colors.orange;
      case 'proses':      return Colors.blue;
      case 'selesai':     return Colors.green;
      case 'dibatalkan':  return Colors.red;
      default:            return Colors.grey;
    }
  }

  // Format angka ke Rupiah: 2500 → Rp 2.500
  String _formatRupiah(dynamic angka) {
    final str = angka.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  // Format tanggal: "2026-06-01 13:55:30" → "01 Jun 2026, 13:55"
  String _formatTanggal(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                         'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
      final tgl  = dt.day.toString().padLeft(2, '0');
      final bln  = bulan[dt.month];
      final thn  = dt.year;
      final jam  = dt.hour.toString().padLeft(2, '0');
      final mnt  = dt.minute.toString().padLeft(2, '0');
      return '$tgl $bln $thn, $jam:$mnt';
    } catch (_) {
      return raw; // Kalau format tidak dikenal, tampilkan apa adanya
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getDynamicStatusColor(order.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${order.id}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _statusBadge(order.status, statusColor),
              ],
            ),
            const Divider(height: 24),

            _infoRow("Pengguna", order.namaCustomer),
            _infoRow("Produk", order.produkDibeli),

            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 5),
                Text(
                  _formatTanggal(order.tanggal),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),

            const Divider(height: 20),
            _infoRow("Total Bayar", _formatRupiah(order.totalHarga)),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}