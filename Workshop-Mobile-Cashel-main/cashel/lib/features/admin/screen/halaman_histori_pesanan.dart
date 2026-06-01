import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/beranda_model.dart';

class HalamanHistoriPesanan extends StatefulWidget {
  const HalamanHistoriPesanan({super.key});

  @override
  State<HalamanHistoriPesanan> createState() => _HalamanHistoriPesananState();
}

class _HalamanHistoriPesananState extends State<HalamanHistoriPesanan> {
  late Future<List<OrderHistory>> futureHistori;
  final TextEditingController _searchController = TextEditingController();
  List<OrderHistory> _allData = [];
  List<OrderHistory> _filteredData = [];

  // Sesuaikan URL dengan IP lokal komputer/server XAMPP milikmu
  final String apiUrl =
      'http://192.168.18.154/api_cashel/transaction/get_histori_pesanan.php';

  Future<List<OrderHistory>> fetchHistori() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((item) => OrderHistory.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat data histori');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke backend: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    futureHistori = fetchHistori();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredData = _allData.where((order) {
        return order.noOrder.toLowerCase().contains(query) ||
            order.pelanggan.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _refresh() {
    setState(() {
      futureHistori = fetchHistori();
      _searchController.clear();
    });
  }

  String _formatRupiah(int harga) {
    final str = harga.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Histori Pemesanan',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF3B5BDB)),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<OrderHistory>>(
        future: futureHistori,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      'Terjadi Kesalahan:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Sukses
          if (snapshot.hasData) {
            if (_allData.isEmpty || _searchController.text.isEmpty) {
              _allData = snapshot.data!;
              if (_searchController.text.isEmpty) {
                _filteredData = List.from(_allData);
              }
            }

            return RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Cari No. Order atau Pelanggan',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  // Info jumlah data
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          'Menampilkan ${_filteredData.length} dari ${_allData.length} data',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Tabel
                  Expanded(
                    child: _filteredData.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada data.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Table(
                                  columnWidths: const {
                                    0: IntrinsicColumnWidth(),
                                    1: FlexColumnWidth(2.5),
                                    2: IntrinsicColumnWidth(),
                                    3: IntrinsicColumnWidth(),
                                  },
                                  children: [
                                    // Header
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        border: Border(
                                          bottom: BorderSide(color: Colors.grey.shade200),
                                        ),
                                      ),
                                      children: const [
                                        _TableHeader('No.'),
                                        _TableHeader('Pelanggan'),
                                        _TableHeader('Tanggal'),
                                        _TableHeader('Total'),
                                      ],
                                    ),

                                    // Baris data
                                    ..._filteredData.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final order = entry.value;
                                      final isLast = index == _filteredData.length - 1;

                                      return TableRow(
                                        decoration: BoxDecoration(
                                          color: index.isEven
                                              ? Colors.white
                                              : const Color(0xFFF8F9FC),
                                          border: isLast
                                              ? null
                                              : Border(
                                                  bottom: BorderSide(
                                                    color: Colors.grey.shade100,
                                                  ),
                                                ),
                                        ),
                                        children: [
                                          _TableCell(
                                            order.noOrder,
                                            isBold: true,
                                            color: const Color(0xFF3B5BDB),
                                          ),
                                          _TableCell(order.pelanggan),
                                          _TableCell(
                                            order.tanggal,
                                            isSmall: true,
                                          ),
                                          _TableCell(
                                            _formatRupiah(order.totalHarga),
                                            isSmall: true,
                                            isBold: true,
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Tidak ada data tersedia'));
        },
      ),
    );
  }
}

// Widget helper: header kolom tabel
class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

// Widget helper: sel isi tabel
class _TableCell extends StatelessWidget {
  final String text;
  final bool isBold;
  final bool isSmall;
  final Color? color;

  const _TableCell(
    this.text, {
    this.isBold = false,
    this.isSmall = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isSmall ? 12 : 13,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          color: color ?? (isSmall ? Colors.grey.shade600 : Colors.black87),
        ),
      ),
    );
  }
}