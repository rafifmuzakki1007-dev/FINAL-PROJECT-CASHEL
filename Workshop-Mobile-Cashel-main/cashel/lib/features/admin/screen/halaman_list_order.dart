import 'package:flutter/material.dart';
import '../../../data/models/order_model.dart';
import '../../../data/service/order_service.dart';
import '../../admin/widgets/list_order_card.dart';
import 'halaman_informasi_pengguna.dart';

class HalamanListOrder extends StatefulWidget {
  const HalamanListOrder({super.key});

  @override
  State<HalamanListOrder> createState() => _HalamanListOrderState();
}

class _HalamanListOrderState extends State<HalamanListOrder> {
  late Future<List<OrderModel>> futureOrders;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Prioritas urutan status: makin kecil angkanya, makin atas
  static const Map<String, int> _statusPriority = {
    'tertunda'   : 0,
    'proses'     : 1,
    'selesai'    : 2,
    'dibatalkan' : 3,
  };

  @override
  void initState() {
    super.initState();
    _refreshData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      futureOrders = OrderService().fetchAllAdminOrders();
    });
  }

  /// Urutkan: Tertunda → Proses → Selesai → Dibatalkan
  /// Status yang tidak dikenal diletakkan di akhir
  List<OrderModel> _sortAndFilter(List<OrderModel> orders) {
    // 1. Filter berdasarkan query pencarian
    final filtered = _searchQuery.isEmpty
        ? orders
        : orders.where((o) {
            return o.id.toString().contains(_searchQuery) ||
                   o.namaCustomer.toLowerCase().contains(_searchQuery);
          }).toList();

    // 2. Urutkan berdasarkan prioritas status
    filtered.sort((a, b) {
      final priorityA = _statusPriority[a.status.toLowerCase()] ?? 99;
      final priorityB = _statusPriority[b.status.toLowerCase()] ?? 99;
      if (priorityA != priorityB) return priorityA.compareTo(priorityB);
      // Jika status sama, urutkan dari terbaru (id terbesar di atas)
      return b.id.compareTo(a.id);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "List Order Admin",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar — fungsional
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari ID atau Nama Customer",
                prefixIcon: const Icon(Icons.search),
                // Tombol clear muncul saat ada teks
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // FutureBuilder
            Expanded(
              child: FutureBuilder<List<OrderModel>>(
                future: futureOrders,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Tidak ada pesanan."));
                  }

                  final orders = _sortAndFilter(snapshot.data!);

                  if (orders.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada hasil untuk "$_searchQuery"',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _refreshData(),
                    child: ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final data = orders[index];
                        return OrderCard(
                          order: data,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HalamanInformasiPengguna(order: data),
                              ),
                            );
                            _refreshData();
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}