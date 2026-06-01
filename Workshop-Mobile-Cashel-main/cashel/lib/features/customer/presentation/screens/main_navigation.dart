import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tampilan_awal_page.dart';
import 'keranjang_page.dart';
import 'riwayat_pesanan_screen.dart';
import 'akun.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  DateTime? _lastBackPressed; // untuk double-tap back keluar di Beranda

  final List<UniqueKey> _tabKeys = List.generate(4, (_) => UniqueKey());

  void _onItemTapped(int index) {
    setState(() {
      _tabKeys[index] = UniqueKey();
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
  
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false; // jangan keluar app
    }

  
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tekan sekali lagi untuk keluar',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: Color(0xFF3498DB),
          duration: Duration(seconds: 2),
        ),
      );
      return false; 
    }

    // Kalau double-tap - keluar app
    SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _onWillPop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            TampilanAwalPage(
              key: _tabKeys[0],
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              onKeranjangTap: () => _onItemTapped(1),
            ),
            KeranjangPage(key: _tabKeys[1], onBack: () => _onItemTapped(0)),
            RiwayatPesananScreen(
                key: _tabKeys[2], onBack: () => _onItemTapped(0)),
            AkunPage(key: _tabKeys[3]),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF3498DB),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontFamily: 'Poppins', fontSize: 12),
          items: [
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/beranda.png',
                  width: 24,
                  color: _selectedIndex == 0
                      ? const Color(0xFF3498DB)
                      : Colors.grey),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/cart-bottom.png',
                  width: 24,
                  color: _selectedIndex == 1
                      ? const Color(0xFF3498DB)
                      : Colors.grey),
              label: 'Keranjang',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/history.png',
                  width: 24,
                  color: _selectedIndex == 2
                      ? const Color(0xFF3498DB)
                      : Colors.grey),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/akun.png',
                  width: 24,
                  color: _selectedIndex == 3
                      ? const Color(0xFF3498DB)
                      : Colors.grey),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}