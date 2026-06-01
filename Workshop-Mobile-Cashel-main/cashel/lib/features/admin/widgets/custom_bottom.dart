import 'package:flutter/material.dart';
// Pastikan path import AppTextStyles Anda benar
import 'package:cashel_v2/core/constant/app_text_styles.dart'; 

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF3498DB),
      unselectedItemColor: Colors.grey,
      
      // Menerapkan AppTextStyles ke label navigasi
      selectedLabelStyle: AppTextStyles.infoPengguna.copyWith(
        fontSize: 12, // Menyesuaikan ukuran untuk navigasi
      ),
      unselectedLabelStyle: AppTextStyles.infoPengguna.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Colors.grey,
      ),

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Overview'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'List Order'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Stok'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Akun'),
      ],
    );
  }
}
