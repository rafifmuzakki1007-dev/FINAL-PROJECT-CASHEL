import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/produk_card.dart';
import 'keranjang_page.dart';

class HalamanGrosir extends StatefulWidget {
  const HalamanGrosir({super.key});

  @override
  State<HalamanGrosir> createState() => _HalamanGrosirState();
}

class _HalamanGrosirState extends State<HalamanGrosir> {
  Future<List<dynamic>>? _futureGrosir;

  @override
  void initState() {
    super.initState();
    _futureGrosir = ambilDataGrosir();
  }

  void _tambahKeKeranjang() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Berhasil ditambahkan ke keranjang",
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF3498DB),
      ),
    );
  }

  Future<List<dynamic>> ambilDataGrosir() async {
    final String t = DateTime.now().millisecondsSinceEpoch.toString();
    final String url =
        'http://192.168.18.154/api_cashel/product/get_product.php?kategori=grosir&t=$t';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Kesalahan koneksi Grosir: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double scale = constraints.maxWidth / 414;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Produk Grosir",
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Center(
                  child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: keranjangNotifier,
                    builder: (context, list, child) {
                      final jumlah = list.fold<int>(
                          0, (sum, item) => sum + (item['jumlah'] as int? ?? 0));
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const KeranjangPage()),
                        ),
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/images/cart.png',
                              width: 28 * scale,
                              height: 28 * scale,
                              color: const Color(0xFF181B19),
                            ),
                            if (jumlah > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '$jumlah',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          body: FutureBuilder<List<dynamic>>(
            future: _futureGrosir,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return GridView.builder(
                  key: const PageStorageKey<String>('scroll_grosir'),
                  padding: EdgeInsets.all(20 * scale),
                  itemCount: snapshot.data!.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15 * scale,
                    crossAxisSpacing: 15 * scale,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    return ProdukCard(
                      idProduk: item['id_produk']?.toString() ?? '0', 
                      title: item['nama_produk'] ?? "Produk",
                      price: "${item['harga'] ?? '0'}",
                      imagePath:
                          "assets/images/${item['gambar'] ?? 'placeholder.png'}",
                      stok: (item['stok'] ?? 0).toString(),
                      description: item['deskripsi'] ?? "",
                      scale: scale,
                      onAddTap: _tambahKeKeranjang,
                    );
                  },
                );
              }
              return const Center(
                child: Text(
                  "Data Grosir Tidak Ditemukan",
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}