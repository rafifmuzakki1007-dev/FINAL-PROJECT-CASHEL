import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/produk_card.dart';
import '../widgets/grosir_card.dart';import '../widgets/tampilan_awal_widgets.dart';
import 'halaman_grosir.dart';
import 'semua_produk.dart';
import 'halaman_pencarian.dart';
import 'keranjang_page.dart';
import 'detail_produk_screen.dart';


class TampilanAwalPage extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final VoidCallback? onKeranjangTap;

  const TampilanAwalPage({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.onKeranjangTap,
  });

  @override
  State<TampilanAwalPage> createState() => _TampilanAwalPageState();
}

class _TampilanAwalPageState extends State<TampilanAwalPage> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _grosirScrollController = ScrollController();
  int _currentPage = 0;
  Timer? _timer;
  Timer? _grosirTimer;
  bool _isScrolled = false;

  Future<List<dynamic>>? _futureGrosir;
  Future<List<dynamic>>? _futureProduk;

  final List<String> _bannerImages = [
    "assets/images/hero_banner.png",
    "assets/images/hero_banner2.png",
    "assets/images/hero_banner3.png",
    "assets/images/hero_banner4.png",
  ];

  @override
  void initState() {
    super.initState();
    _muatUlangData();

    _scrollController.addListener(() {
      if (_scrollController.offset > 10 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 10 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });

    // auto-scroll grosir tiap 3.5 detik
    _grosirTimer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (!_grosirScrollController.hasClients) return;
      final max = _grosirScrollController.position.maxScrollExtent;
      final current = _grosirScrollController.offset;
      final next = current + 195.0;
      if (next >= max) {
        _grosirScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _grosirScrollController.animateTo(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    // Auto-scroll banner tiap 5 detik
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _grosirTimer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    _grosirScrollController.dispose();
    super.dispose();
  }

  void _muatUlangData() {
    _futureGrosir = ambilDataGrosir();
    _futureProduk = ambilProduk();
  }

  void _tambahKeKeranjang() {
    // badge update otomatis via keranjangNotifier di produk_card
  }

  Future<List<dynamic>> ambilDataGrosir() async {
    const String url =
        'http://192.168.18.154/api_cashel/product/get_product.php?kategori=grosir';
    try {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200 ? json.decode(response.body) : [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> ambilProduk() async {
    const String url =
        'http://192.168.18.154/api_cashel/product/get_product.php?kategori=satuan';
    try {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200 ? json.decode(response.body) : [];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double scale = constraints.maxWidth / 414;

        return TampilanAwalWidget(
          scale: scale,
          isScrolled: _isScrolled,
          onSearchTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HalamanPencarian()),
          ),
          keranjangBadge: _buildKeranjangBadge(),
          bodyContent: _buildBody(scale),
        );
      },
    );
  }

  Widget _buildKeranjangBadge() {
    return GestureDetector(
      onTap: () => widget.onKeranjangTap?.call(),
      child: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: keranjangNotifier,
        builder: (context, list, child) {
          final jumlah = list.fold<int>(
              0, (sum, item) => sum + (item['jumlah'] as int? ?? 0));
          return Stack(
            children: [
              Image.asset(
                'assets/images/cart.png',
                width: 28,
                height: 28,
                color: Colors.white,
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
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(double scale) {
    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.only(top: 10 * scale),
      children: [
        _buildBanner(scale),
        _buildSectionTitle(context, "Grosir", scale),
        _buildGrosirList(scale),
        _buildSectionTitle(context, "Produk", scale),
        _buildProductGrid(scale),
      ],
    );
  }

  Widget _buildBanner(double scale) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 20 * scale,
        vertical: 10 * scale,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 115 * scale,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _bannerImages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(15 * scale),
                child: Image.asset(_bannerImages[index], fit: BoxFit.cover),
              ),
            ),
          ),
          SizedBox(height: 8 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _bannerImages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4 * scale),
                width: _currentPage == index ? 20 * scale : 8 * scale,
                height: 8 * scale,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xFF3498DB)
                      : const Color(0xFFCCCCCC),
                  borderRadius: BorderRadius.circular(4 * scale),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrosirList(double scale) {
    return SizedBox(
      height: 100 * scale,
      child: FutureBuilder<List<dynamic>>(
        future: _futureGrosir,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          return ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white.withOpacity(0.0),
                ],
                stops: const [0.0, 0.75, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: ListView.builder(
              controller: _grosirScrollController,
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return GrosirCard(
                  title: item['nama_produk'] ?? "Grosir",
                  imagePath:
                      "assets/images/${item['gambar'] ?? 'placeholder.png'}",
                  scale: scale,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailProdukScreen(
                        produk: {
                          'id_produk': item['id_produk']?.toString() ?? '0',
                          'title': item['nama_produk'] ?? 'Produk',
                        'price': '${item['harga'] ?? '0'}',
                          'imagePath': 'assets/images/${item['gambar'] ?? 'placeholder.png'}',
                          'stok': (item['stok'] ?? 0).toString(),
                          'description': item['deskripsi'] ?? '',
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(double scale) {
    return FutureBuilder<List<dynamic>>(
      future: _futureProduk,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, double scale) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        20 * scale,
        20 * scale,
        10 * scale,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          TextButton(
            onPressed: () {
              if (title == "Grosir")
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HalamanGrosir(),
                  ),
                );
              else if (title == "Produk")
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SemuaProdukPage(),
                  ),
                );
            },
            child: const Text(
              "Lihat semua",
              style:
                  TextStyle(fontFamily: 'Poppins', color: Color(0xFF3498DB)),
            ),
          ),
        ],
      ),
    );
  }
}