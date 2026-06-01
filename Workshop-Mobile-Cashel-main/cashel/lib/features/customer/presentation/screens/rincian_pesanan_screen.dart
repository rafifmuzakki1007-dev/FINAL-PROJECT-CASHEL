import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../widgets/rincian_pesanan_widgets.dart';
import 'pilih_alasan_batal.dart';
import 'rincian_pembatalan_berhasil.dart';
import 'main_navigation.dart';

// Model untuk satu item produk dalam pesanan
class ItemPesanan {
  final String namaProduk;
  final String imagePath;
  final int harga;
  final int jumlah;

  const ItemPesanan({
    required this.namaProduk,
    required this.imagePath,
    required this.harga,
    required this.jumlah,
  });
}

class RincianPesananScreen extends StatefulWidget {
  final int idPesanan;
  final String metodePembayaran;
  final List<ItemPesanan> items; // ← SEMUA produk dalam pesanan
  final int totalBayar;
  final int ongkir;
  final String? waktuPesanan; // dari riwayat, null jika pesanan baru

  // ── backward-compat: jika masih ada caller lama yg kirim 1 produk ──
  // Bisa dihapus setelah semua caller diperbarui.
  factory RincianPesananScreen.single({
    Key? key,
    required int idPesanan,
    required String metodePembayaran,
    required String namaProduk,
    required int harga,
    required String imagePath,
    required int jumlah,
    required int totalBayar,
    required int ongkir,
  }) {
    return RincianPesananScreen(
      key: key,
      idPesanan: idPesanan,
      metodePembayaran: metodePembayaran,
      totalBayar: totalBayar,
      ongkir: ongkir,
      items: [
        ItemPesanan(
          namaProduk: namaProduk,
          imagePath: imagePath,
          harga: harga,
          jumlah: jumlah,
        ),
      ],
    );
  }

  const RincianPesananScreen({
    super.key,
    required this.idPesanan,
    required this.metodePembayaran,
    required this.items,
    required this.totalBayar,
    required this.ongkir,
    this.waktuPesanan,
  });

  @override
  State<RincianPesananScreen> createState() => _RincianPesananScreenState();
}

class _RincianPesananScreenState extends State<RincianPesananScreen> {
  late String _waktuFormatted;
  String _statusPesanan = 'diproses';

  bool _isAdminKonfirmasi = false;
  String? _waktuSelesai;
  Timer? _pollingTimer;

  static const String _serverIp = "192.168.18.154";
  static const String _baseUrl = "http://$_serverIp/api_cashel/auth";

  @override
  void initState() {
    super.initState();
    _waktuFormatted = widget.waktuPesanan?.isNotEmpty == true
        ? widget.waktuPesanan!
        : DateFormat('dd-MM-yyyy HH.mm').format(DateTime.now());
    _startPollingStatusAdmin();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPollingStatusAdmin() {
    _cekStatusAdmin();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_statusPesanan != 'selesai') _cekStatusAdmin();
    });
  }

  Future<void> _cekStatusAdmin() async {
    try {
      final url = Uri.parse(
          '$_baseUrl/cek_status_pesanan.php?id_pesanan=${widget.idPesanan}');
      final response =
          await http.get(url).timeout(const Duration(seconds: 10));
      final result = jsonDecode(response.body);

      if (!mounted) return;
      if (result['status'] == 'success') {
        final bool adminSudahKonfirmasi =
            result['admin_konfirmasi'] == true ||
                result['admin_konfirmasi'] == 1;
        if (adminSudahKonfirmasi && !_isAdminKonfirmasi) {
          setState(() => _isAdminKonfirmasi = true);
        }
      }
    } catch (_) {}
  }

  void _selesaikanPesanan() {
    if (!_isAdminKonfirmasi) return;
    final String now = DateFormat('dd-MM-yyyy HH.mm').format(DateTime.now());
    setState(() {
      _statusPesanan = 'selesai';
      _waktuSelesai = now;
    });
    _pollingTimer?.cancel();
  }

  Future<void> _batalkanPesanan(String alasan) async {
    try {
      final url = Uri.parse('$_baseUrl/batalkan_pesanan.php');
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "id_pesanan": widget.idPesanan,
              "alasan": alasan,
              "diminta_oleh": "Pembeli",
            }),
          )
          .timeout(const Duration(seconds: 15));

      final result = jsonDecode(response.body);

      if (!mounted) return;

      if (result['status'] == 'success') {
        _pollingTimer?.cancel();
        // Pop sheet (PilihAlasanBatalPage) dulu
        Navigator.pop(context);
        // Lalu replace RincianPesananScreen agar user tidak bisa back ke halaman ini
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RincianPembatalanBerhasil(
              idPesanan: widget.idPesanan,
              items: widget.items,
              alasan: alasan,
              waktuBatal:
                  DateFormat('dd-MM-yyyy HH.mm').format(DateTime.now()),
              metodePembayaran: widget.metodePembayaran,
              tanggalPesanan: _waktuFormatted,
            ),
          ),
        );
      } else {
        // Tutup sheet sebelum tampilkan error
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message'] ?? 'Gagal membatalkan'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // Tutup sheet juga saat exception
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showBatalBottomSheet() {
    PilihAlasanBatalPage.show(context, onKonfirmasi: _batalkanPesanan);
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelesai = _statusPesanan == 'selesai';
    final String displayMetode =
        widget.metodePembayaran.toUpperCase() == 'COD'
            ? 'CASH'
            : widget.metodePembayaran.toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Rincian Pesanan",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Poppins')),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BannerStatusPesanan(
                    isSelesai: isSelesai,
                    metodePembayaran: displayMetode,
                    waktuSelesai: _waktuSelesai,
                  ),
                  const SizedBox(height: 8),

                  // Card produk — sekarang menampilkan SEMUA item
                  CardProdukPesanan(
                    items: widget.items,
                    totalBayar: widget.totalBayar,
                  ),
                  const SizedBox(height: 8),

                  CardDetailPemesanan(
                    metodePembayaran: displayMetode,
                    waktuPemesanan: _waktuFormatted,
                    noPesanan: widget.idPesanan,
                  ),
                ],
              ),
            ),
          ),

          BottomBarPesanan(
            isSelesai: isSelesai,
            isAdminKonfirmasi: _isAdminKonfirmasi,
            onBatalkan: _showBatalBottomSheet,
            onSelesai: _selesaikanPesanan,
            onBeliLagi: () => Navigator.pop(context), // ← Kembali ke riwayat
          ),
        ],
      ),
    );
  }
}