import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Import Widgets
import '../widgets/order_stats_card.dart';
import '../widgets/admin_chart.dart';
import '../widgets/admin_table.dart';

// Import Models & Services (Hapus mock lama, gunakan BerandaData)
import '../../../data/models/beranda_model.dart';
import 'halaman_histori_pesanan.dart';

class HalamanBeranda extends StatefulWidget {
  const HalamanBeranda({super.key});

  @override
  State<HalamanBeranda> createState() => _HalamanBerandaState();
}

class _HalamanBerandaState extends State<HalamanBeranda> {
  late Future<BerandaData> futureBerandaData;

  // Sesuaikan URL dengan IP lokal komputer/server XAMPP milikmu
  final String apiUrl = 'http://192.168.18.154/api_cashel/transaction/get_beranda.php';

  Future<BerandaData> fetchBerandaData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return BerandaData.fromJson(json.decode(response.body));
      } else {
        throw Exception('Gagal memuat data dari database');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke backend: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Inisialisasi panggilan API saat halaman pertama kali dimuat
    futureBerandaData = fetchBerandaData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<BerandaData>(
        future: futureBerandaData,
        builder: (context, snapshot) {
          // 1. Kondisi Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          // 2. Kondisi Error (misal IP salah atau Apache mati)
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Terjadi Kesalahan:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          
          // 3. Kondisi Sukses Mendapatkan Data
          else if (snapshot.hasData) {
            final data = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  futureBerandaData = fetchBerandaData();
                });
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Halaman
                    const Text(
                      "Beranda",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Bagian Statistik Order (Baru & Tertunda)
                    Row(
                      children: [
                        Expanded(
                          child: OrderStatsCard(
                            title: "Pesanan Baru",
                            count: data.newOrders,
                            gradientColors: const [Color(0xFF4A68FF), Color(0xFF2144FA)],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OrderStatsCard(
                            title: "Pesanan Tertunda",
                            count: data.pendingOrders,
                            gradientColors: const [Color(0xFF3DA9FF), Color(0xFF158DFF)],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Bagian Grafik Aktivitas (Income)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Aktivitas",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 25),
                          
                          // Memanggil widget admin_chart.dart dengan melempar data aktivitas dari DB
                          SizedBox(
                            height: 250,
                            child: AdminChart(chartData: data.activities),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Histori Pemesanan",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanHistoriPesanan())), child: const Text("Lihat Semua")),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Memanggil widget admin_table.dart dengan melempar data histori dari DB
                    AdminTable(orders: data.orderHistory),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Tidak ada data tersedia'));
        },
      ),
    );
  }
}