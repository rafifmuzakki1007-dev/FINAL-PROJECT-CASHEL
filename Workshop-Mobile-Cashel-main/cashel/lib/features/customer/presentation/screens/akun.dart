import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:cashel/api/api_config.dart';           // ← pakai ApiConfig
import 'package:cashel/data/models/user_model.dart';
import 'package:cashel/data/service/session_service.dart';
import 'package:cashel/data/service/akun_service.dart';
import 'package:cashel/features/customer/presentation/widgets/akun_widgets.dart';

class AkunPage extends StatefulWidget {
  const AkunPage({super.key});

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  UserData? _user;
  bool _isLoading = true;
  bool _uploadingFoto = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await SessionService.getUser();
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  bool get _isGoogleUser =>
      _user?.password == null || _user!.password.isEmpty;

  // FIX: pakai copyWith agar tidak perlu tulis semua field manual
  Future<void> _updateSession(UserData updated) async {
    await SessionService.saveUser(updated);
    if (mounted) setState(() => _user = updated);
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
      backgroundColor: error ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Upload Foto ────────────────────────────────────────────────────────────
  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 800,
      );
      if (picked == null) return;

      if (mounted) Navigator.pop(context); // tutup bottom sheet
      setState(() => _uploadingFoto = true);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiConfig.baseUrl}/auth/upload_foto.php"),
      );
      request.fields['id_akun'] = _user!.idAkun;
      // FIX: field name 'foto' sesuai PHP $_FILES['foto']
      request.files.add(
        await http.MultipartFile.fromPath('foto', picked.path),
      );

      final streamedRes = await request.send()
          .timeout(const Duration(seconds: 15));
      final res = await http.Response.fromStream(streamedRes);
      final data = jsonDecode(res.body);

      if (data['status'] == 'success') {
        // FIX: pakai copyWith
        await _updateSession(_user!.copyWith(foto: data['foto']));
        if (mounted) _snack('Foto profil berhasil diperbarui');
      } else {
        if (mounted) _snack(data['message'] ?? 'Gagal upload foto', error: true);
      }
    } catch (e) {
      if (mounted) _snack('Koneksi gagal: $e', error: true);
    } finally {
      if (mounted) setState(() => _uploadingFoto = false);
    }
  }

  // ── Hubungi Toko ──────────────────────────────────────────────────────────
  Future<void> _hubungiToko() async {
    const String nomorWA = '6281252477384';
    const String pesan = 'Halo, saya ingin menghubungi El-Fath melalui aplikasi CASHEL.';
    final Uri url = Uri.parse(
      'https://wa.me/$nomorWA?text=${Uri.encodeComponent(pesan)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) _snack('WhatsApp tidak ditemukan di perangkat ini.', error: true);
    }
  }

  // ── Bottom Sheet Pilih Foto ───────────────────────────────────────────────
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text('Ubah Foto Profil',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              tileColor: const Color(0xFFF7F7F7),
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xFF3498DB)),
              title: const Text('Pilih dari Galeri',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
              onTap: () => _pickAndUploadPhoto(ImageSource.gallery),
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              tileColor: const Color(0xFFF7F7F7),
              leading: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFF3498DB)),
              title: const Text('Ambil dari Kamera',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
              onTap: () => _pickAndUploadPhoto(ImageSource.camera),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Bottom Sheet Edit Field Generik ───────────────────────────────────────
  void _showEditDialog({
    required String title,
    required String currentValue,
    required String hint,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    required Future<void> Function(String value) onSave,
  }) {
    final ctrl = TextEditingController(text: currentValue);
    final focusNode = FocusNode();
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (ctx.mounted) focusNode.requestFocus();
        });
        return StatefulBuilder(
          builder: (ctx, setS) => Padding(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  focusNode: focusNode,
                  autofocus: false,
                  obscureText: obscure,
                  keyboardType: keyboard,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(fontFamily: 'Poppins'),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF3498DB), width: 1.5)),
                  ),
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal',
                          style: TextStyle(
                              color: Colors.grey, fontFamily: 'Poppins')),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: loading
                          ? null
                          : () async {
                              if (ctrl.text.trim().isEmpty) return;
                              setS(() => loading = true);
                              await onSave(ctrl.text.trim());
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                      child: loading
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Simpan',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: 'Poppins')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Bottom Sheet Ganti Password ───────────────────────────────────────────
  void _showEditPasswordDialog() {
    final ctrlLama = TextEditingController();
    final ctrlBaru = TextEditingController();
    final focusLama = FocusNode();
    final focusBaru = FocusNode();
    bool loading = false;
    bool obsLama = true;
    bool obsBaru = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (ctx.mounted) {
            _isGoogleUser ? focusBaru.requestFocus() : focusLama.requestFocus();
          }
        });
        return StatefulBuilder(
          builder: (ctx, setS) => Padding(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isGoogleUser ? 'Buat Password' : 'Ganti Password',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                if (_isGoogleUser) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'Akun Google kamu belum punya password. Buat password untuk bisa login manual.',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF9B9B9B)),
                  ),
                ],
                const SizedBox(height: 16),
                if (!_isGoogleUser) ...[
                  _passwordField(
                      ctrl: ctrlLama,
                      focusNode: focusLama,
                      hint: 'Password lama',
                      obscure: obsLama,
                      onToggle: () => setS(() => obsLama = !obsLama)),
                  const SizedBox(height: 12),
                ],
                _passwordField(
                    ctrl: ctrlBaru,
                    focusNode: focusBaru,
                    hint: _isGoogleUser ? 'Buat password baru' : 'Password baru',
                    obscure: obsBaru,
                    onToggle: () => setS(() => obsBaru = !obsBaru)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal',
                          style: TextStyle(
                              color: Colors.grey, fontFamily: 'Poppins')),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: loading
                          ? null
                          : () async {
                              if (!_isGoogleUser && ctrlLama.text.isEmpty) {
                                _snack('Password lama wajib diisi', error: true);
                                return;
                              }
                              if (ctrlBaru.text.isEmpty) {
                                _snack('Password baru wajib diisi', error: true);
                                return;
                              }
                              if (ctrlBaru.text.length < 6) {
                                _snack('Password minimal 6 karakter', error: true);
                                return;
                              }
                              setS(() => loading = true);

                              Map<String, dynamic> res;
                              if (_isGoogleUser) {
                                res = await AkunService.setPassword(
                                  idAkun: _user!.idAkun,
                                  passwordBaru: ctrlBaru.text,
                                );
                              } else {
                                res = await AkunService.updatePassword(
                                  idAkun: _user!.idAkun,
                                  passwordLama: ctrlLama.text,
                                  passwordBaru: ctrlBaru.text,
                                );
                              }

                              if (ctx.mounted) Navigator.pop(ctx);
                              if (res['status'] == 'success') {
                                // FIX: pakai copyWith
                                if (_isGoogleUser) {
                                  await _updateSession(
                                    _user!.copyWith(password: 'set'),
                                  );
                                }
                                if (mounted) _snack('Password berhasil diperbarui');
                              } else {
                                if (mounted) _snack(res['message'] ?? 'Gagal', error: true);
                              }
                            },
                      child: loading
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Simpan',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: 'Poppins')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _passwordField({
    required TextEditingController ctrl,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    FocusNode? focusNode,
  }) {
    return TextField(
      controller: ctrl,
      focusNode: focusNode,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Poppins'),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF3498DB), width: 1.5)),
        suffixIcon: IconButton(
          icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey),
          onPressed: onToggle,
        ),
      ),
      style: const TextStyle(fontFamily: 'Poppins'),
    );
  }

  // ── Edit Nama ─────────────────────────────────────────────────────────────
  void _showEditNameDialog() {
    if (_user == null) return;
    _showEditDialog(
      title: 'Ubah Nama',
      currentValue: _user!.nama,
      hint: 'Nama Lengkap',
      onSave: (val) async {
        final res = await AkunService.updateNama(
            idAkun: _user!.idAkun, nama: val);
        if (res['status'] == 'success') {
          // FIX: pakai copyWith
          await _updateSession(_user!.copyWith(nama: val));
          _snack('Nama berhasil diperbarui');
        } else {
          _snack(res['message'] ?? 'Gagal', error: true);
        }
      },
    );
  }

  // ── Edit Email ────────────────────────────────────────────────────────────
  void _showEditEmailDialog() {
    if (_user == null) return;
    _showEditDialog(
      title: 'Ubah Email',
      currentValue: _user!.email,
      hint: 'Email baru',
      keyboard: TextInputType.emailAddress,
      onSave: (val) async {
        final res = await AkunService.updateEmail(
            idAkun: _user!.idAkun, email: val);
        if (res['status'] == 'success') {
          await _updateSession(_user!.copyWith(email: val));
          _snack('Email berhasil diperbarui');
        } else {
          _snack(res['message'] ?? 'Gagal', error: true);
        }
      },
    );
  }

  // ── Edit No HP ────────────────────────────────────────────────────────────
  void _showEditNoHpDialog() {
    if (_user == null) return;
    _showEditDialog(
      title: 'Ubah No. Handphone',
      currentValue: _user!.noHp,
      hint: 'Nomor HP baru',
      keyboard: TextInputType.phone,
      onSave: (val) async {
        final res = await AkunService.updateNoHp(
            idAkun: _user!.idAkun, noHp: val);
        if (res['status'] == 'success') {
          await _updateSession(_user!.copyWith(noHp: val));
          _snack('No. Handphone berhasil diperbarui');
        } else {
          _snack(res['message'] ?? 'Gagal', error: true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()));
    }

    if (_user == null) {
      return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
              child: Text('Silakan login terlebih dahulu',
                  style: TextStyle(fontFamily: 'Poppins'))));
    }

    // FIX: pakai ApiConfig.baseUrl, bukan hardcode IP
    final String? fotoUrl = _user!.foto.isNotEmpty
        ? '${ApiConfig.baseUrl}/${_user!.foto}?t=${DateTime.now().millisecondsSinceEpoch}'
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AkunProfileHeader(
              name:        _user!.nama,
              email:       _user!.email,
              fotoUrl:     fotoUrl,
              isUploading: _uploadingFoto,
              onEditName:  _showEditNameDialog,
              onEditPhoto: _showPhotoOptions,
            ),

            AkunMenuItem(
              iconPath: 'assets/images/hub_toko.png',
              title: 'Hubungi Toko',
              onTap: _hubungiToko,
            ),
            AkunMenuItem(
              iconPath: 'assets/images/email.png',
              title: 'Email',
              subtitle: _user!.email,
              onTap: _showEditEmailDialog,
            ),
            AkunMenuItem(
              iconPath: 'assets/images/telp.png',
              title: 'No. Handphone',
              subtitle: _user!.noHp.isEmpty ? '-' : _user!.noHp,
              onTap: _showEditNoHpDialog,
            ),
            AkunMenuItem(
              iconPath: 'assets/images/pass.png',
              title: 'Password',
              subtitle: _isGoogleUser ? 'Belum diatur' : '••••••••',
              onTap: _showEditPasswordDialog,
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            const Spacer(),
            LogoutButton(userId: _user!.idAkun),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}