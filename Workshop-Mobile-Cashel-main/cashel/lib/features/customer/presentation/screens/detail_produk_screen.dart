import 'package:flutter/material.dart';
import 'package:cashel/data/service/session_service.dart';
import 'keranjang_page.dart';
import 'checkout.dart';
import '../widgets/produk_card.dart' show formatRupiah;

class DetailProdukScreen extends StatefulWidget {
  final Map<String, String> produk;
  const DetailProdukScreen({super.key, required this.produk});

  static int totalItemDiKeranjangGlobal = 0;

  @override
  State<DetailProdukScreen> createState() => _DetailProdukScreenState();
}

class _DetailProdukScreenState extends State<DetailProdukScreen> {
  int jumlah = 1;
  double cartScale = 1.0; 

  Future<void> _tambahKeKeranjang() async {
    await KeranjangPage.tambahItem({
      'id_produk': widget.produk['id_produk'] ?? '0',
      'title': widget.produk['title'] ?? 'Nama Produk',
      'price': widget.produk['price'] ?? 'Rp. 0',
      'imagePath': widget.produk['imagePath'] ?? 'assets/images/pensil.png',
      'jumlah': jumlah,
      'varian': '-',
    }, SessionService.currentUserId ?? '');

    setState(() {
      cartScale = 1.4;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => cartScale = 1.0);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Berhasil menambahkan $jumlah item ke keranjang"),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF3498DB),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 380,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF2F3F2),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            widget.produk['imagePath'] ?? 'assets/images/pensil.png',
                            height: 280,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 24),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  AnimatedScale(
                                    scale: cartScale,
                                    duration: const Duration(milliseconds: 200),
                                    child: IconButton(
                                      icon: Image.asset(
                                        'assets/images/cart.png',
                                        width: 28,
                                        height: 28,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const KeranjangPage()),
                                        );
                                      },
                                    ),
                                  ),
                                  if (DetailProdukScreen.totalItemDiKeranjangGlobal > 0)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                        child: Text(
                                          "${DetailProdukScreen.totalItemDiKeranjangGlobal}",
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.produk['title'] ?? 'Nama Produk',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Color(0xFF181725),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Jumlah",
                                  style: TextStyle(color: Color(0xFF7C7C7C), fontFamily: 'Poppins', fontSize: 16),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildCounterIcon(Icons.remove, () {
                                      if (jumlah > 1) setState(() => jumlah--);
                                    }),
                                    const SizedBox(width: 15),
                                    Container(
                                      width: 45,
                                      height: 45,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: const Color(0xFFE2E2E2)),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "$jumlah",
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    _buildCounterIcon(Icons.add, () => setState(() => jumlah++), isBlue: true),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              formatRupiah(widget.produk['price'] ?? '0'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Color(0xFF181725),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(color: Color(0xFFE2E2E2), thickness: 1),
                        ),
                        const Text(
                          "Deskripsi",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.produk['description'] ?? 'Detail produk ATK CASHEL berkualitas tinggi.',
                          style: const TextStyle(color: Colors.black, height: 1.5, fontFamily: 'Poppins', fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 10, 25, 40),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF3498DB), width: 1.2),
                    ),
                    child: InkWell(
                      onTap: _tambahKeKeranjang,
                      borderRadius: BorderRadius.circular(10),
                      child: const Center(
                        child: Text(
                          "Tambah ke keranjang",
                          style: TextStyle(color: Color(0xFF3498DB), fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3498DB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        // ambil angka saja dari string harga
                        String rawPrice = widget.produk['price'] ?? '0';
                        int cleanPrice = int.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                        
                        
                        int idProduk = int.tryParse(widget.produk['id_produk'] ?? '0') ?? 0;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                              idProduk: idProduk, 
                              namaProduk: widget.produk['title'] ?? 'Nama Produk',
                              harga: cleanPrice,
                              imagePath: widget.produk['imagePath'] ?? 'assets/images/pensil.png',
                              jumlah: jumlah,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: const Center(
                        child: Text(
                          "Pesan Sekarang",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 14),
                        ),
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

  Widget _buildCounterIcon(IconData icon, VoidCallback onTap, {bool isBlue = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon, 
        color: isBlue ? const Color(0xFF3498DB) : const Color(0xFFB1B1B1), 
        size: 28
      ),
    );
  }
}