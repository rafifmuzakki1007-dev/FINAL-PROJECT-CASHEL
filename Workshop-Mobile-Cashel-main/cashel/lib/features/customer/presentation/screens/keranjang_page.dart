import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'detail_produk_screen.dart';
import 'checkout.dart';
import 'package:cashel/data/service/session_service.dart';

// ValueNotifier global — semua widget yang listen akan auto-rebuild saat data berubah
final ValueNotifier<List<Map<String, dynamic>>> keranjangNotifier =
    ValueNotifier([]);

class KeranjangPage extends StatefulWidget {
  final VoidCallback? onBack;
  const KeranjangPage({super.key, this.onBack});

  static List<Map<String, dynamic>> get listKeranjangGlobal =>
      keranjangNotifier.value;

  // KEY STORAGE PER AKUN 
  static String _storageKey(String userId) => 'keranjang_$userId';

  // LOAD keranjang saat login 
  static Future<void> loadKeranjang(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey(userId));
    if (raw != null) {
      try {
        final decoded = List<Map<String, dynamic>>.from(
          (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e)),
        );
        keranjangNotifier.value = decoded;
      } catch (_) {
        keranjangNotifier.value = [];
      }
    } else {
      keranjangNotifier.value = [];
    }
    _syncCounter();
  }

  // SIMPAN ke SharedPreferences
  static Future<void> _saveKeranjang(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey(userId),
      jsonEncode(keranjangNotifier.value),
    );
  }

  // SINKRONISASI counter global dari list
  static void _syncCounter() {
    final total = keranjangNotifier.value
        .fold<int>(0, (sum, e) => sum + (e['jumlah'] as int? ?? 0));
    DetailProdukScreen.totalItemDiKeranjangGlobal = total;
  }

  // TAMBAH ITEM

  static Future<void> tambahItem(
      Map<String, dynamic> item, String userId) async {
    if (userId.isEmpty) return; // jangan simpan jika belum login
    final list = List<Map<String, dynamic>>.from(keranjangNotifier.value);
    final index = list.indexWhere((e) => e['id_produk'] == item['id_produk']);
    if (index != -1) {
      list[index]['jumlah'] =
          (list[index]['jumlah'] as int) + (item['jumlah'] as int? ?? 1);
    } else {
      list.add({...item, 'selected': true});
    }
    keranjangNotifier.value = list;
    _syncCounter();
    await _saveKeranjang(userId);
  }

  // HAPUS ITEM
  static Future<void> hapusItem(int index, String userId) async {
    final list = List<Map<String, dynamic>>.from(keranjangNotifier.value);
    list.removeAt(index);
    keranjangNotifier.value = list;
    _syncCounter();
    await _saveKeranjang(userId);
  }

  // UPDATE JUMLAH
  static Future<void> updateJumlah(
      int index, int delta, String userId) async {
    final list = List<Map<String, dynamic>>.from(keranjangNotifier.value);
    list[index]['jumlah'] = (list[index]['jumlah'] as int) + delta;
    keranjangNotifier.value = list;
    _syncCounter();
    await _saveKeranjang(userId);
  }

  // UPDATE SELECTED (tidak perlu disimpan ke storage)
  static void updateSelected(int index, bool value) {
    final list = List<Map<String, dynamic>>.from(keranjangNotifier.value);
    list[index]['selected'] = value;
    keranjangNotifier.value = list;
  }

  static void selectAllItems(bool value) {
    final list = List<Map<String, dynamic>>.from(keranjangNotifier.value);
    for (var item in list) {
      item['selected'] = value;
    }
    keranjangNotifier.value = list;
  }

  // LOGOUT 

  static Future<void> clearAndLogout() async {
    keranjangNotifier.value = [];
    DetailProdukScreen.totalItemDiKeranjangGlobal = 0;
    await SessionService.logout();
  }

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
 
  String get _userId => SessionService.currentUserId ?? '';

  int get totalHarga {
    int total = 0;
    for (var item in keranjangNotifier.value) {
      if (item['selected'] == true) {
        String priceRaw = (item['price'] ?? '0').toString();
        String cleanPrice = priceRaw
            .replaceAll(RegExp(r'[^0-9]'), '')
            .trim();
        int price = int.tryParse(cleanPrice) ?? 0;
        total += price * (item['jumlah'] as int? ?? 1);
      }
    }
    return total;
  }

  String _formatRupiah(int value) {
    if (value == 0) return "Rp.0";
    String s = value.toString();
    String result = '';
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result = '.$result';
      result = s[i] + result;
      count++;
    }
    return "Rp.$result";
  }

  bool get isAllSelected =>
      keranjangNotifier.value.isNotEmpty &&
      keranjangNotifier.value.every((e) => e['selected'] == true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          "Keranjang",
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: keranjangNotifier,
        builder: (context, list, _) {
          return Column(
            children: [
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1)),
              Expanded(
                child: list.isEmpty
                    ? const Center(
                        child: Text(
                          "Keranjang Kosong",
                          style: TextStyle(
                              fontFamily: 'Poppins', color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        itemCount: list.length,
                        itemBuilder: (context, index) =>
                            _buildCartItem(index, list),
                      ),
              ),
              _buildBottomBar(list),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(List<Map<String, dynamic>> list) {
    final selectedCount = list.where((e) => e['selected'] == true).length;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x7FE6EAF3),
            blurRadius: 37,
            offset: Offset(0, -12),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => KeranjangPage.selectAllItems(!isAllSelected),
            child: Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                color: isAllSelected
                    ? const Color(0xFF3498DB)
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isAllSelected
                      ? const Color(0xFF3498DB)
                      : const Color(0xFF8A8A8A),
                  width: 2,
                ),
              ),
              child: isAllSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Semua",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF181725),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                    fontSize: 11, color: Colors.grey, fontFamily: 'Poppins'),
              ),
              Text(
                _formatRupiah(totalHarga),
                style: const TextStyle(
                  color: Color(0xFF181725),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.10,
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          ElevatedButton(
            onPressed: totalHarga == 0
                ? null
                : () {
                    final selectedItems =
                        list.where((e) => e['selected'] == true).toList();
                    if (selectedItems.isEmpty) return;
                    final first = selectedItems.first;
                    String rawPrice = (first['price'] ?? '0').toString();
                    int cleanPrice = int.tryParse(
                            rawPrice.replaceAll(RegExp(r'[^0-9]'), '')) ??
                        0;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          items: selectedItems,
                          idProduk: int.tryParse(
                                  first['id_produk']?.toString() ?? '0') ??
                              0,
                          namaProduk: first['title'] ?? 'Produk',
                          harga: cleanPrice,
                          imagePath: first['imagePath'] ??
                              'assets/images/pensil.png',
                          jumlah: first['jumlah'] as int,
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              disabledBackgroundColor: Colors.grey.shade300,
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17)),
              elevation: 0,
            ),
            child: Text(
              "Checkout ($selectedCount)",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index, List<Map<String, dynamic>> list) {
    var item = list[index];
    String namaProduk = item['title'] ?? item['name'] ?? 'Nama Produk';
    String hargaProduk = item['price'] ?? 'Rp.0';
    String gambarProduk = item['imagePath'] ?? item['image'] ?? '';
    String varianProduk = item['varian'] ?? '-';
    bool isSelected = item['selected'] == true;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => KeranjangPage.updateSelected(index, !isSelected),
              child: Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3498DB) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF3498DB)
                        : const Color(0xFF8A8A8A),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
            const SizedBox(width: 15),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailProdukScreen(
                    produk: {
                      'id_produk': item['id_produk']?.toString() ?? '0',
                      'title': namaProduk,
                      'price': hargaProduk,
                      'imagePath': gambarProduk,
                      'stok': item['stok']?.toString() ?? '0',
                      'description': item['description']?.toString() ?? '',
                    },
                  ),
                ),
              ),
              child: Container(
                width: 105,
                height: 100,
                decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(10)),
                child: gambarProduk.startsWith('http')
                    ? Image.network(gambarProduk, fit: BoxFit.contain)
                    : gambarProduk.isNotEmpty
                        ? Image.asset(gambarProduk, fit: BoxFit.contain)
                        : const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailProdukScreen(
                                produk: {
                                  'id_produk': item['id_produk']?.toString() ?? '0',
                                  'title': namaProduk,
                                  'price': hargaProduk,
                                  'imagePath': gambarProduk,
                                  'stok': item['stok']?.toString() ?? '0',
                                  'description': item['description']?.toString() ?? '',
                                },
                              ),
                            ),
                          ),
                          child: Text(
                            namaProduk,
                            style: const TextStyle(
                                color: Color(0xFF181725),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                height: 1.29),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => KeranjangPage.hapusItem(index, _userId),
                        child: const Icon(Icons.close,
                            color: Color(0xFFB3B3B3), size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBEBEB),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      varianProduk,
                      style: const TextStyle(
                          color: Color(0xFF878787),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(hargaProduk,
                          style: const TextStyle(
                              color: Color(0xFF181725),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              height: 1.93)),
                      Row(
                        children: [
                          _counterIcon(Icons.remove, () {
                            if ((item['jumlah'] as int) > 1) {
                              KeranjangPage.updateJumlah(index, -1, _userId);
                            }
                          }, isEnabled: (item['jumlah'] as int) > 1),
                          Container(
                            width: 39.69,
                            height: 39.69,
                            alignment: Alignment.center,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFFE2E2E2)),
                                borderRadius: BorderRadius.circular(17)),
                            child: Text(
                              "${item['jumlah']}",
                              style: const TextStyle(
                                  color: Color(0xFF181725),
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          _counterIcon(Icons.add, () {
                            KeranjangPage.updateJumlah(index, 1, _userId);
                          }, isEnabled: true, isBlue: true),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 30, thickness: 1, color: Color(0xFFF1F1F1)),
      ],
    );
  }

  Widget _counterIcon(IconData icon, VoidCallback onTap,
      {required bool isEnabled, bool isBlue = false}) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon,
            color: !isEnabled
                ? const Color(0xFFE2E2E2)
                : (isBlue
                    ? const Color(0xFF3498DB)
                    : const Color(0xFFB1B1B1)),
            size: 20),
      ),
    );
  }
}