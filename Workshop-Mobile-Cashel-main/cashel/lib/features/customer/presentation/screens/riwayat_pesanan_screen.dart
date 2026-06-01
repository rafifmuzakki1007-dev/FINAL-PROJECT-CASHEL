import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'rincian_pesanan_screen.dart';
import 'rincian_pembatalan_berhasil.dart';
import '../widgets/riwayat_pesanan_widgets.dart';
import 'package:cashel/data/service/session_service.dart';

// ── Helper format Rupiah ─────────────────────────────────────────────────────
String _rp(int value) =>
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
        .format(value);

// ── Model ────────────────────────────────────────────────────────────────────
class RiwayatPesananItem {
  final int idPesanan;
  final String status;
  final String metodePembayaran;
  final int totalBayar;
  final int ongkir;
  final String waktuPesanan;
  final String alasanBatal;
  final String waktuBatal;
  final List<ItemPesanan> items;

  const RiwayatPesananItem({
    required this.idPesanan,
    required this.status,
    required this.metodePembayaran,
    required this.totalBayar,
    required this.ongkir,
    required this.waktuPesanan,
    this.alasanBatal = '-',
    this.waktuBatal = '-',
    required this.items,
  });

  factory RiwayatPesananItem.fromJson(Map<String, dynamic> json) {
    final List<dynamic> produkList = json['items'] ?? [];
    return RiwayatPesananItem(
      idPesanan: int.tryParse(json['id_pesanan'].toString()) ?? 0,
      status: json['status']?.toString().toLowerCase() ?? 'diproses',
      metodePembayaran: json['metode_pembayaran']?.toString() ?? '-',
      totalBayar: int.tryParse(json['total_bayar'].toString()) ?? 0,
      ongkir: int.tryParse(json['ongkir']?.toString() ?? '0') ?? 0,
      waktuPesanan: json['waktu_pesanan']?.toString() ?? '',
      alasanBatal: json['alasan_batal']?.toString() ?? '-',
      waktuBatal: json['waktu_batal']?.toString() ?? '-',
      items: produkList.map((p) {
        final raw = p['image_path']?.toString() ?? '';
        final imgPath = raw.startsWith('assets/') || raw.startsWith('http')
            ? raw
            : 'assets/images/$raw';
        return ItemPesanan(
          namaProduk: p['nama_produk']?.toString() ?? '',
          imagePath: imgPath,
          harga: int.tryParse(p['harga'].toString()) ?? 0,
          jumlah: int.tryParse(p['jumlah'].toString()) ?? 1,
        );
      }).toList(),
    );
  }
}

// ── Screen ───────────────────────────────────────────────────────────────────
class RiwayatPesananScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const RiwayatPesananScreen({super.key, this.onBack});

  @override
  State<RiwayatPesananScreen> createState() => _RiwayatPesananScreenState();
}

class _RiwayatPesananScreenState extends State<RiwayatPesananScreen>
    with SingleTickerProviderStateMixin {
  static const String _serverIp = "192.168.18.154";
  static const String _baseUrl = "http://$_serverIp/api_cashel/auth";

  late TabController _tabController;
  List<RiwayatPesananItem> _semuaPesanan = [];
  bool _isLoading = true;
  String? _errorMsg;
  Timer? _pollingTimer;
  String _idAkun = ''; 

  final List<String> _tabs = ['Semua', 'Proses', 'Selesai', 'Dibatalkan'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadUserThenFetch(); // ← GANTI dari _fetchRiwayat()
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchRiwayat(silent: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  // ← TAMBAH method ini
  Future<void> _loadUserThenFetch() async {
    final user = await SessionService.getUser();
    if (!mounted) return;
    if (user == null) {
      setState(() {
        _errorMsg = 'Sesi tidak ditemukan, silakan login ulang';
        _isLoading = false;
      });
      return;
    }
    _idAkun = user.idAkun;
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat({bool silent = false}) async {
    if (_idAkun.isEmpty) return; // ← TAMBAH guard
    if (!silent && mounted) setState(() => _isLoading = true);
    try {
      // ← TAMBAH id_user ke URL
      final url = Uri.parse(
        '$_baseUrl/get_riwayat_pesanan.php?id_user=$_idAkun',
      );
      final response =
          await http.get(url).timeout(const Duration(seconds: 15));
      final result = jsonDecode(response.body);

      if (!mounted) return;
      if (result['status'] == 'success') {
        final List<dynamic> data = result['data'] ?? [];
        setState(() {
          _semuaPesanan =
              data.map((e) => RiwayatPesananItem.fromJson(e)).toList();
          _isLoading = false;
          _errorMsg = null;
        });
      } else {
        setState(() {
          _errorMsg = result['message'] ?? 'Gagal memuat riwayat';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = 'Tidak dapat terhubung ke server';
        _isLoading = false;
      });
    }
  }

  List<RiwayatPesananItem> _filtered(String tab) {
    if (tab == 'Semua') return _semuaPesanan;
    if (tab == 'Proses') {
      return _semuaPesanan
          .where((p) => p.status == 'diproses' || p.status == 'tertunda')
          .toList();
    }
    final map = {'Selesai': 'selesai', 'Dibatalkan': 'dibatalkan'};
    return _semuaPesanan.where((p) => p.status == map[tab]).toList();
  }

  void _lihatDetail(RiwayatPesananItem pesanan) {
    if (pesanan.status == 'dibatalkan') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RincianPembatalanBerhasil(
            idPesanan: pesanan.idPesanan,
            items: pesanan.items,
            alasan: pesanan.alasanBatal,
            waktuBatal: pesanan.waktuBatal,
            metodePembayaran: pesanan.metodePembayaran,
            tanggalPesanan: pesanan.waktuPesanan,
          ),
        ),
      ).then((_) => _fetchRiwayat(silent: true));
      return;
    }

    final String metode = pesanan.metodePembayaran.toUpperCase() == 'COD'
        ? 'CASH'
        : pesanan.metodePembayaran.toUpperCase();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RincianPesananScreen(
          idPesanan: pesanan.idPesanan,
          metodePembayaran: metode,
          items: pesanan.items,
          totalBayar: pesanan.totalBayar,
          ongkir: pesanan.ongkir,
          waktuPesanan: pesanan.waktuPesanan,
        ),
      ),
    ).then((_) => _fetchRiwayat(silent: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            }
          },
        ),
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded,
                color: Color(0xFF3498DB), size: 24),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF3498DB),
            unselectedLabelColor: const Color(0xFF888888),
            indicatorColor: const Color(0xFF3498DB),
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 13,
            ),
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF3498DB), strokeWidth: 2.5))
          : _errorMsg != null
              ? ErrorViewRiwayat(pesan: _errorMsg!, onRetry: _fetchRiwayat)
              : TabBarView(
                  controller: _tabController,
                  children: _tabs
                      .map((tab) => PesananList(
                            pesananList: _filtered(tab),
                            onLihatDetail: _lihatDetail,
                          ))
                      .toList(),
                ),
    );
  }
}