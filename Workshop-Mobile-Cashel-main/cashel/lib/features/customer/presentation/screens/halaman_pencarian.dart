import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/produk_card.dart';
import 'keranjang_page.dart';

class HalamanPencarian extends StatefulWidget {
  const HalamanPencarian({super.key});

  @override
  State<HalamanPencarian> createState() => _HalamanPencarianState();
}

class _HalamanPencarianState extends State<HalamanPencarian> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;
  List<String> _searchHistory = [];
  final List<String> _popularTags = [
    "Bolpoin",
    "Map",
    "Penghapus",
    "Buku tulis",
  ];

  @override
  void initState() {
    super.initState();
    _muatRiwayat();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _tambahKeKeranjang() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Berhasil ditambahkan",
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF3498DB),
      ),
    );
  }

  Future<void> _muatRiwayat() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('history_pencarian') ?? [];
    });
  }

  Future<void> _simpanRiwayat(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    if (_searchHistory.contains(query)) {
      _searchHistory.remove(query);
    }
    _searchHistory.insert(0, query);
    if (_searchHistory.length > 5) _searchHistory.removeLast();
    await prefs.setStringList('history_pencarian', _searchHistory);
    setState(() {});
  }

  Future<void> _hapusRiwayat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history_pencarian');
    setState(() => _searchHistory = []);
  }

  Future<void> _prosesCari(String query) async {
    if (query.trim().isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    _simpanRiwayat(query);

    try {
      final response = await http
          .get(Uri.parse(
              'http://192.168.18.154/api_cashel/product/get_product.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> allData = json.decode(response.body);
        setState(() {
          _searchResults = allData
              .where(
                (item) => item['nama_produk']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()),
              )
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Fetching Database: $e");
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) => _prosesCari(value),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() => _isSearching = false);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Cari",
                      hintStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _isSearching = false;
                                  _searchResults = [];
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isSearching ? _buildSearchResults() : _buildInitialState(),
    );
  }

  Widget _buildInitialState() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_searchHistory.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Riwayat Pencarian",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              GestureDetector(
                onTap: _hapusRiwayat,
                child: const Text(
                  "Hapus",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: _searchHistory
                .map(
                  (h) => ActionChip(
                    label: Text(
                      h,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () {
                      _searchController.text = h;
                      _prosesCari(h);
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 30),
        ],
        const Text(
          "Pencarian Populer",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: _popularTags
              .map(
                (t) => ActionChip(
                  label: Text(
                    t,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                    ),
                  ),
                  onPressed: () {
                    _searchController.text = t;
                    _prosesCari(t);
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3498DB)),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            const Text(
              "Produk tidak ditemukan",
              style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double scale = constraints.maxWidth / 414;
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _searchResults.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 15 * scale,
            crossAxisSpacing: 15 * scale,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            final item = _searchResults[index];
            return ProdukCard(
              idProduk: item['id_produk']?.toString() ?? '0', 
              title: item['nama_produk'] ?? "Produk",
              price: "Rp ${item['harga'] ?? '0'}",
              imagePath:
                  "assets/images/${item['gambar'] ?? 'placeholder.png'}",
              stok: (item['stok'] ?? 0).toString(),
              description: item['deskripsi'] ?? "",
              scale: scale,
              onAddTap: _tambahKeKeranjang,
            );
          },
        );
      },
    );
  }
}