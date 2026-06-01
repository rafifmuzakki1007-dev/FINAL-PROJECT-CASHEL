import 'package:flutter/material.dart';import '../../../../data/service/session_service.dart';
import '../../../customer/presentation/screens/keranjang_page.dart';
import '../../../customer/presentation/screens/main_navigation.dart';
import '../../../admin/screen/admin_main_screen.dart';
import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import 'login_screen.dart';
import 'register_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0; // 0=splash, 1=welcome, 2=intro, 3=getstarted

  // Animasi splash
  late AnimationController _splashAnim;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _textSlide;
  late Animation<double> _textFade;

  // Data onboarding (index 0=welcome, 1=intro, 2=getstarted)
  final List<Map<String, String>> _onboarding = [
    {
      "image": "assets/images/logo-cashel.png",
      "title": "CASHEL",
      "desc":
          "Aplikasi bisnis penjualan Alat Tulis Kantor (ATK) yang bisa dipesan lewat online!",
      "showElFath": "true",
    },
    {
      "image": "assets/images/introduction-page.png",
      "title": "Mudah dalam pembelian,\ndengan CASHEL",
      "desc":
          "Pembelian bisa dilakukan secara online agar lebih mudah dan efisien.",
      "showElFath": "false",
    },
    {
      "image": "assets/images/get-started-page.png",
      "title": "Mudah dalam pembelian,\ndengan CASHEL",
      "desc": "Beli alat tulis sesuai kebutuhan kapan saja dan di mana saja.",
      "showElFath": "false",
    },
  ];

  @override
  void initState() {
    super.initState();

    _splashAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashAnim,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashAnim,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashAnim,
        curve: const Interval(0.5, 0.9, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<double>(begin: 25.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _splashAnim,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _splashAnim.forward();

    // Setelah 3 detik, cek login lalu smooth transition ke onboarding
    Future.delayed(const Duration(seconds: 3), _cekStatusLogin);
  }

  @override
  void dispose() {
    _splashAnim.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _cekStatusLogin() async {
    final isLoggedIn = await SessionService.restoreSession();
    if (!mounted) return;

    if (isLoggedIn && SessionService.currentUserId != null) {
      final user = SessionService.currentUser;
      final role = user?.role ?? 'customer';

      if (role != 'admin') {
        await KeranjangPage.loadKeranjang(SessionService.currentUserId!);
      }

      if (!mounted) return;

      final Widget destination =
          role == 'admin' ? const AdminMainScreen() : const MainNavigation();

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => destination,
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      // Smooth slide ke welcome page
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  void _goNext() {
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _goPrev() {
    if (_currentPage > 1) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _pageController,
        physics: _currentPage == 0
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemCount: 4, // 0:splash, 1:welcome, 2:intro, 3:getstarted
        itemBuilder: (context, index) {
          if (index == 0) return _buildSplash();
          return _buildOnboarding(index);
        },
      ),
    );
  }

  // ── SPLASH ──────────────────────────────────────────────────────
  Widget _buildSplash() {
    return Container(
      color: Colors.white,
      child: AnimatedBuilder(
        animation: _splashAnim,
        builder: (context, _) => Column(
          children: [
            const Spacer(flex: 2),
            // Logo
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Image.asset(
                  'assets/images/logo-cashel.png',
                  width: 180,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Spacer(flex: 2),
            // Teks EL-FATH slide up
            Transform.translate(
              offset: Offset(0, _textSlide.value),
              child: Opacity(
                opacity: _textFade.value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Column(
                    children: [
                      // Divider aksen biru
                      Container(
                        width: 36,
                        height: 2.5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3498DB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Text(
                        'EL-FATH',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Poppins',
                          color: Color(0xFF2C2C2C),
                          letterSpacing: 5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'PHOTOCOPY DAN PENJILIDAN',
                        style: TextStyle(
                          fontSize: 9,
                          fontFamily: 'Poppins',
                          color: Colors.grey[500],
                          letterSpacing: 2.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ONBOARDING PAGES ────────────────────────────────────────────
  Widget _buildOnboarding(int index) {
    final item = _onboarding[index - 1];
    final isLast = index == 3;
    final isWelcome = index == 1;
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: SizedBox.expand(
        child: Column(
          children: [
          // ── Gambar / Logo ──────────────────────────────────────────
          if (isWelcome) ...[
            // Welcome: logo di tengah dengan banyak ruang atas
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Image.asset(
                item['image']!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image, size: 80, color: Colors.grey),
              ),
            ),
            const Spacer(flex: 1),
          ] else ...[
            SizedBox(
              height: size.height * 0.50,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Image.asset(
                  item['image']!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image, size: 80, color: Colors.grey),
                ),
              ),
            ),
          ],

          // ── Konten tengah ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Judul — hanya non-welcome
                if (!isWelcome) ...[
                  Text(
                    item['title']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Color(0xFF1A1A1A),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Deskripsi
                Text(
                  item['desc']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
                ),

                // EL-FATH branding — welcome page saja
                if (isWelcome) ...[
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      const Text(
                        'EL-FATH',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Poppins',
                          letterSpacing: 4,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PHOTOCOPY DAN PENJILIDAN',
                        style: TextStyle(
                          fontSize: 9,
                          fontFamily: 'Poppins',
                          color: Colors.grey[500],
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Spacer mendorong baris bawah ke paling bawah ──────────
          const Spacer(),

          // ── Baris bawah: indicator + tombol sejajar ────────────────
          if (isLast) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Masuk',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => RegisterPage())),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF3498DB)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Mendaftar',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: Color(0xFF3498DB))),
                    ),
                  ),
                  TextButton(
                    onPressed: _goPrev,
                    child: const Text('Kembali',
                        style: TextStyle(
                            color: Colors.grey, fontFamily: 'Poppins')),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Indicator dots (kiri) + Selanjutnya (kanan) dalam 1 Row
            SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Dots selalu di tengah
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final active = _currentPage - 1 == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF3498DB)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  // Selanjutnya di kanan
                  Positioned(
                    right: 16,
                    child: TextButton(
                      onPressed: _goNext,
                      child: const Text(
                        'Selanjutnya',
                        style: TextStyle(
                            color: Color(0xFF3498DB),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
        ),
      ),
    );
  }
    }