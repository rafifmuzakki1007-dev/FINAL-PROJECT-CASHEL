import 'package:flutter/material.dart';
import 'package:cashel/data/service/session_service.dart';
import '../screens/detail_produk_screen.dart';
import '../screens/keranjang_page.dart';

/// Format angka integer ke "Rp4.000", "Rp15.000", dst.
/// Bisa menerima int atau String angka mentah dari API.
String formatRupiah(dynamic value) {
  final int amount = value is int ? value : int.tryParse(value.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  final str = amount.toString();
  final buffer = StringBuffer();
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) buffer.write('.');
    buffer.write(str[i]);
    count++;
  }
  return 'Rp${buffer.toString().split('').reversed.join()}';
}

class ProdukCard extends StatelessWidget {
  final String idProduk;
  final String title;
  final String price;
  final String imagePath;
  final String stok;
  final String description;
  final double scale;
  final VoidCallback? onAddTap;

  const ProdukCard({
    super.key,
    required this.idProduk,
    required this.title,
    required this.price,
    required this.imagePath,
    required this.stok,
    required this.description,
    required this.scale,
    this.onAddTap,
  });

  Future<void> _tambahKeKeranjang(BuildContext context) async {
    await KeranjangPage.tambahItem({
      'id_produk': idProduk,
      'title': title,
      'price': price,
      'imagePath': imagePath,
      'jumlah': 1,
      'varian': '-',
    }, SessionService.currentUserId ?? '');

    onAddTap?.call();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$title ditambahkan ke keranjang",
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF3498DB),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailProdukScreen(
              produk: {
                'id_produk': idProduk,
                'title': title,
                'price': price,
                'imagePath': imagePath,
                'stok': stok,
                'description': description,
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15 * scale),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140 * scale,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color.fromARGB(248, 192, 191, 191)
                        .withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(15 * scale)),
                child: Padding(
                  padding: EdgeInsets.all(12 * scale),
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 14 * scale,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatRupiah(price),
                        style: TextStyle(
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: const Color(0xFF181725)),
                      ),
                      InkWell(
                        onTap: () => _tambahKeKeranjang(context),
                        borderRadius: BorderRadius.circular(10 * scale),
                        child: Container(
                          padding: EdgeInsets.all(6 * scale),
                          decoration: BoxDecoration(
                              color: const Color(0xFF3498DB),
                              borderRadius:
                                  BorderRadius.circular(10 * scale)),
                          child: Icon(Icons.add,
                              color: Colors.white, size: 18 * scale),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}