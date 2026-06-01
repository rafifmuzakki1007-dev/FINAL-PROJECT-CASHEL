import 'package:flutter/material.dart';

class TampilanAwalWidget extends StatelessWidget {
  final Widget bodyContent;
  final double scale;
  final bool isScrolled;
  final Widget keranjangBadge;
  final VoidCallback onSearchTap;

  const TampilanAwalWidget({
    super.key,
    required this.bodyContent,
    required this.scale,
    required this.isScrolled,
    required this.keranjangBadge,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tidak pakai Scaffold & tidak ada BottomNavigationBar
    // Keduanya sudah diurus oleh MainNavigation
    return Column(
      children: [
        _buildFixedTopBar(),
        Expanded(child: bodyContent),
      ],
    );
  }

  Widget _buildFixedTopBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: isScrolled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ]
            : [],
      ),
      child: Stack(
        children: [
          // Background Image Header
          Container(
            height: 110 * scale,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/top_bar.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Search Bar & Keranjang
          Padding(
            padding: EdgeInsets.fromLTRB(
                20 * scale, 50 * scale, 20 * scale, 15 * scale),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onSearchTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 15 * scale, vertical: 12 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(15 * scale),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF181B19)),
                          SizedBox(width: 10 * scale),
                          Text(
                            "Cari",
                            style: TextStyle(
                              color: const Color(0xFF7C7C7C),
                              fontSize: 14 * scale,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15 * scale),
                keranjangBadge,
              ],
            ),
          ),
        ],
      ),
    );
  }
}