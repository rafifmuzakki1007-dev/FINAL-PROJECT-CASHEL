import 'package:flutter/material.dart';
// Import widget navigasi yang tadi kita bikin
import '../widgets/main_navigation_bar.dart'; 
// Import halaman-halaman kamu
import 'halaman_beranda.dart';

import 'halaman_list_order.dart';
import 'halaman_stok.dart';
import 'halaman_informasi_admin.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  // Daftar halaman yang akan tampil di bagian 'body'
  final List<Widget> _pages = [
    const HalamanBeranda(),
    
    const HalamanListOrder(),
    const HalamanStok(),
    const  HalamanInformasiAdmin(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ini bagian ajaibnya: body akan berubah sesuai index navigasi
      body: _pages[_currentIndex],
      
      // Panggil widget navigasi dari folder widgets
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update index supaya body berubah
          });
        },
      ),
    );
  }
}