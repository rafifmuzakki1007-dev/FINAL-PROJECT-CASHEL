import 'package:flutter/material.dart';
// Import model beranda terpisah milikmu
import '../../../data/models/beranda_model.dart'; 

class AdminTable extends StatelessWidget {
  // 1. Terima list data histori transaksi dari database melalui constructor
  final List<OrderHistory> orders;

  const AdminTable({super.key, required this.orders});

  // Helper: format angka ke format Rupiah (contoh: 150000 → 150.000)
  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          // Kita sesuaikan dengan 4 kolom: no order, pelanggan, tanggal, total harga
          columns: const [
            DataColumn(label: Text('No. Order')),
            DataColumn(label: Text('Pelanggan')),
            DataColumn(label: Text('Tanggal')),
            DataColumn(label: Text('Total Harga')),
          ],
          rows: orders.map((data) {
            return DataRow(cells: [
              DataCell(Text(data.noOrder)),
              DataCell(Text(data.pelanggan)),
              DataCell(Text(data.tanggal)),
              DataCell(
                Text(
                  // Format rupiah: Rp 150.000
                  'Rp ${_formatRupiah(data.totalHarga)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}