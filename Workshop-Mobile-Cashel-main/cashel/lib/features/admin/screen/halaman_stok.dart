import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../api/api_config.dart';
import '../../../data/models/produk_model.dart';
import 'package:cashel/features/admin/screen/edit_detail_produk.dart';

class HalamanStok extends StatefulWidget {
  const HalamanStok({super.key});

  @override
  State<HalamanStok> createState() => _HalamanStokState();
}

class _HalamanStokState extends State<HalamanStok> {
  List<ProdukModel> listProduk = [];
  bool isLoading = true;

  // URL API utama milikmu
  final String apiUrl = "${ApiConfig.baseUrl}/api_stok/get_produk.php";
  final String baseImageUrl = "${ApiConfig.baseUrl}/api_stok/uploads/"; 
  
  // 🔥 URL BARU UNTUK PROSES DELETE
  final String deleteUrl = "${ApiConfig.baseUrl}/api_stok/delete_produk.php"; 

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  // Fungsi mengambil list data dari server
  Future<void> fetchProduk() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> dataJson = json.decode(response.body);
        setState(() {
          listProduk = dataJson.map((json) => ProdukModel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Gagal memuat data");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Koneksi API Gagal! $e")),
      );
    }
  }

  // 🔥 FUNGSI BARU: Mengirim perintah hapus ke backend PHP
  Future<void> _deleteProduk(String idProduk) async {
    try {
      final response = await http.post(
        Uri.parse(deleteUrl),
        body: {"id_produk": idProduk},
      );

      if (response.statusCode == 200) {
        final dataRespon = json.decode(response.body);
        if (dataRespon['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(dataRespon['message'] ?? "Produk berhasil dihapus!"),
              backgroundColor: Colors.green,
            ),
          );
          fetchProduk(); // Memuat ulang list stok agar produk yang dihapus langsung hilang dari layar
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal: ${dataRespon['message']}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan koneksi hapus: $e")),
      );
    }
  }

  // FUNGSI: Memunculkan jendela dialog konfirmasi (Pop-up) sebelum menghapus
  void _konfirmasiHapus(ProdukModel produk) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, animation, _, __) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ikon lingkaran merah
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF5F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFE03131),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hapus Produk?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Produk "${produk.namaProduk}" dan semua riwayat pesanan terkait akan dihapus permanen.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: const BorderSide(color: Colors.grey, width: 0.8),
                            foregroundColor: Colors.black87,
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _deleteProduk(produk.idProduk.toString());
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: const Color(0xFFE03131),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Hapus',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Stok",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2196F3),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditDetailProduk(produk: null),
            ),
          ).then((_) => fetchProduk());
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : listProduk.isEmpty
              ? const Center(child: Text("Belum ada produk di database."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: listProduk.length,
                    itemBuilder: (context, index) {
                      final produk = listProduk[index];
                      return GestureDetector(
                        // SINKRONISASI AKSI KLIK BIASA: Mengarah ke halaman Edit/Detail
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditDetailProduk(produk: produk),
                            ),
                          ).then((_) => fetchProduk());
                        },
                        
                        // 🔥 SINKRONISASI AKSI TEKAN LAMA: Memunculkan Dialog Konfirmasi Hapus Produk
                        onLongPress: () {
                          _konfirmasiHapus(produk);
                        },

                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(14),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14),
                                    ),
                                    child: Image.network(
                                      '$baseImageUrl${produk.gambar}',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/${produk.gambar}',
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) {
                                            return const Center(
                                              child: Icon(
                                                Icons.image,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      produk.namaProduk,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Rp ${produk.harga}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Stok: ${produk.stok}",
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}