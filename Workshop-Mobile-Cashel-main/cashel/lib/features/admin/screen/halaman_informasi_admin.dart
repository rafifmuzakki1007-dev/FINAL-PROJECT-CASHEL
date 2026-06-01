import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cashel/api/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import '../../../features/auth/presentation/screens/login_screen.dart';
import '../../../../data/service/session_service.dart';

class HalamanInformasiAdmin extends StatefulWidget {
  const HalamanInformasiAdmin({super.key});

  @override
  State<HalamanInformasiAdmin> createState() => _HalamanInformasiAdminState();
}

class _HalamanInformasiAdminState extends State<HalamanInformasiAdmin> {
  String idAkun = "";
  String emailAdmin = "";
  String serialAdmin = "#AD0000";
  String _fotoProfilTerpilih = "";
  bool _isLoading = true;
  bool _isUploadingFoto = false;
  bool _isGoogleAccount = false; // untuk tentukan mode ganti password

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSessionAdmin();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  Future<void> loadSessionAdmin() async {
    try {
      final userData = await SessionService.getUser();
      if (!mounted) return;

      if (userData != null) {
        setState(() {
          idAkun               = userData.idAkun;
          emailAdmin           = userData.email;
          _namaController.text = userData.nama;
          _noHpController.text = userData.noHp;
          _fotoProfilTerpilih  = userData.foto;
          // Akun Google biasanya password kosong atau tidak di-set manual
          _isGoogleAccount     = userData.password.isEmpty;

          if (idAkun.isNotEmpty) {
            int idAngka = int.tryParse(idAkun) ?? 0;
            serialAdmin = "#AD${idAngka.toString().padLeft(4, '0')}";
          }
          _isLoading = false;
        });
        fetchDataAdmin();
      } else {
        setState(() => _isLoading = false);
        prosesLogOut();
      }
    } catch (e) {
      debugPrint("Error loadSession: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchDataAdmin() async {
    if (idAkun.isEmpty) return;
    try {
      var url = Uri.parse("${ApiConfig.baseUrl}/auth/get_admin.php?id_akun=$idAkun");
      var response = await http.get(url).timeout(const Duration(seconds: 10));
      var data = json.decode(response.body);

      if (data['status'] == 'success' && mounted) {
        var admin = data['data'];
        setState(() {
          _namaController.text = admin['nama']    ?? _namaController.text;
          _noHpController.text = admin['no_hp']   ?? _noHpController.text;
          emailAdmin           = admin['email']    ?? emailAdmin;
          _fotoProfilTerpilih  = admin['foto']     ?? admin['foto_url'] ?? _fotoProfilTerpilih;
          _isGoogleAccount     = (admin['password'] == null || admin['password'].toString().isEmpty);
        });
      }
    } catch (e) {
      debugPrint("Error fetch: $e");
    }
  }

  // ─── Update Nama & No HP ──────────────────────────────────────────────────
  Future<void> simpanPerubahanProfil() async {
    try {
      var url = Uri.parse("${ApiConfig.baseUrl}/auth/update_profile.php");
      var response = await http.post(url, body: {
        "id_akun": idAkun,
        "nama":    _namaController.text,
        "no_hp":   _noHpController.text,
        "alamat":  "", // admin tidak pakai alamat, kirim kosong agar API tidak error
      }).timeout(const Duration(seconds: 10));

      var data = json.decode(response.body);
      if (data['status'] == 'success' && mounted) {
        final userData = await SessionService.getUser();
        if (userData != null) {
          await SessionService.saveUser(userData.copyWith(
            nama:  _namaController.text,
            noHp:  _noHpController.text,
          ));
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Data berhasil disimpan!"),
              backgroundColor: Colors.green,
            )
          );
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Gagal menyimpan"))
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan: $e"))
      );
    }
  }

  // ─── Ganti Password ───────────────────────────────────────────────────────
  Future<void> _gantiPassword() async {
    final passwordLamaCtrl  = TextEditingController();
    final passwordBaruCtrl  = TextEditingController();
    final passwordUlangCtrl = TextEditingController();
    bool obscureLama  = true;
    bool obscureBaru  = true;
    bool obscureUlang = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Ganti Password"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Password lama — hanya tampil jika bukan akun Google
                if (!_isGoogleAccount) ...[
                  TextField(
                    controller: passwordLamaCtrl,
                    obscureText: obscureLama,
                    decoration: InputDecoration(
                      labelText: "Password Lama",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscureLama ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setStateDialog(() => obscureLama = !obscureLama),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_isGoogleAccount)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Akun Google: langsung set password baru",
                            style: TextStyle(color: Colors.blue, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                TextField(
                  controller: passwordBaruCtrl,
                  obscureText: obscureBaru,
                  decoration: InputDecoration(
                    labelText: "Password Baru",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscureBaru ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setStateDialog(() => obscureBaru = !obscureBaru),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordUlangCtrl,
                  obscureText: obscureUlang,
                  decoration: InputDecoration(
                    labelText: "Ulangi Password Baru",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscureUlang ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setStateDialog(() => obscureUlang = !obscureUlang),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validasi
                if (passwordBaruCtrl.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password minimal 6 karakter"))
                  );
                  return;
                }
                if (passwordBaruCtrl.text != passwordUlangCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password baru tidak cocok"))
                  );
                  return;
                }
                if (!_isGoogleAccount && passwordLamaCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password lama wajib diisi"))
                  );
                  return;
                }

                Navigator.pop(context);
                await _prosesGantiPassword(
                  passwordLama: passwordLamaCtrl.text,
                  passwordBaru: passwordBaruCtrl.text,
                );
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _prosesGantiPassword({
    required String passwordLama,
    required String passwordBaru,
  }) async {
    try {
      var url = Uri.parse("${ApiConfig.baseUrl}/auth/update_password.php");
      var body = {
        "id_akun":       idAkun,
        "password_baru": passwordBaru,
        "mode":          _isGoogleAccount ? "set" : "update",
      };
      if (!_isGoogleAccount) body["password_lama"] = passwordLama;

      var response = await http.post(url, body: body)
          .timeout(const Duration(seconds: 10));
      var data = json.decode(response.body);

      if (!mounted) return;
      if (data['status'] == 'success') {
        // Update session: tandai password sudah di-set (bukan kosong lagi)
        final userData = await SessionService.getUser();
        if (userData != null) {
          await SessionService.saveUser(userData.copyWith(password: "set"));
          setState(() => _isGoogleAccount = false);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password berhasil diperbarui!"),
            backgroundColor: Colors.green,
          )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Gagal ganti password"))
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal ganti password: $e"))
      );
    }
  }

  // ─── Upload Foto ──────────────────────────────────────────────────────────
  Future<void> _ubahFotoProfil() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;

    if (!mounted) return;
    setState(() => _isUploadingFoto = true);

    try {
      Uint8List imageBytes = await image.readAsBytes();
      String ext = image.name.split('.').last.toLowerCase();

      var uri = Uri.parse("${ApiConfig.baseUrl}/auth/upload_foto.php");
      var request = http.MultipartRequest('POST', uri);
      request.fields['id_akun'] = idAkun;
      request.files.add(
        http.MultipartFile.fromBytes(
          'foto',
          imageBytes,
          filename: 'profil_$idAkun.$ext',
        ),
      );

      var streamedResponse = await request.send()
          .timeout(const Duration(seconds: 15));
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        if (result['status'] == 'success') {
          final String fotoBaruPath = result['foto'];
          setState(() {
            _fotoProfilTerpilih = fotoBaruPath;
            _isUploadingFoto    = false;
          });
          final userData = await SessionService.getUser();
          if (userData != null) {
            await SessionService.saveUser(userData.copyWith(foto: fotoBaruPath));
          }
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Foto profil berhasil diperbarui!"),
              backgroundColor: Colors.green,
            )
          );
        } else {
          setState(() => _isUploadingFoto = false);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? "Gagal upload foto"))
          );
        }
      } else {
        setState(() => _isUploadingFoto = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingFoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal upload foto: $e"))
      );
    }
  }

  // ─── Dialog Edit Field ────────────────────────────────────────────────────
  void _tampilkanDialogEdit(
      String judul, TextEditingController controller, {int maxLines = 1}) {
    TextEditingController tempController =
        TextEditingController(text: controller.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $judul"),
        content: TextField(
          controller: tempController,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: judul,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              controller.text = tempController.text;
              Navigator.pop(context);
              await simpanPerubahanProfil();
              if (mounted) setState(() {});
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ─── Dialog Konfirmasi Log Out ────────────────────────────────────────────
  Future<void> _showLogoutDialog() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, animation, _, __) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF5F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFE03131),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Yakin ingin keluar?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kamu akan keluar dari akun ini. Kamu perlu login kembali untuk mengakses aplikasi.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: const BorderSide(color: Colors.grey, width: 0.8),
                            foregroundColor: Colors.black87,
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            prosesLogOut();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: const Color(0xFFE03131),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Keluar',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> prosesLogOut() async {
    await SessionService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  String _buildFotoUrl() {
    if (_fotoProfilTerpilih.isEmpty) return "";
    return "${ApiConfig.baseUrl}/$_fotoProfilTerpilih?t=${DateTime.now().millisecondsSinceEpoch}";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Informasi Admin",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [

            // ── Foto Profil ───────────────────────────────────────────
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(70),
                      child: _isUploadingFoto
                          ? const Center(child: CircularProgressIndicator())
                          : _fotoProfilTerpilih.isNotEmpty
                              ? Image.network(
                                  _buildFotoUrl(),
                                  fit: BoxFit.cover,
                                  key: ValueKey(_fotoProfilTerpilih),
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    );
                                  },
                                  errorBuilder: (c, o, s) => const Icon(
                                    Icons.person, size: 70, color: Colors.grey,
                                  ),
                                )
                              : const Icon(Icons.person, size: 70, color: Colors.grey),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploadingFoto ? null : _ubahFotoProfil,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: _isUploadingFoto ? Colors.grey : Colors.blue,
                        child: const Icon(Icons.edit, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ── Serial Admin ──────────────────────────────────────────
            _buildCustomCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Serial Admin"),
                  Text(serialAdmin),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Bio ───────────────────────────────────────────────────
            _buildCustomCard(
              child: Column(
                children: [
                  // Nama — bisa diedit
                  GestureDetector(
                    onTap: () => _tampilkanDialogEdit("Nama", _namaController),
                    child: _buildBioRow("Nama", _namaController.text, true),
                  ),
                  const Divider(),
                  // Email — tidak bisa diedit
                  _buildBioRow("Email", emailAdmin, false),
                  const Divider(),
                  // No HP — bisa diedit
                  GestureDetector(
                    onTap: () => _tampilkanDialogEdit("No. HP", _noHpController),
                    child: _buildBioRow("No. HP", _noHpController.text, true),
                  ),
                  const Divider(),
                  // Password — buka dialog ganti password
                  GestureDetector(
                    onTap: _gantiPassword,
                    child: _buildBioRow(
                      "Password",
                      "••••••••",
                      true,
                      icon: Icons.lock_outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ── Log Out ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _showLogoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Log Out", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBioRow(String label, String value, bool isEditable,
      {IconData? icon}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                ],
                Text(label, style: const TextStyle(color: Colors.black87)),
              ],
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: isEditable ? Colors.black54 : Colors.black87,
                  ),
                ),
                if (isEditable) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ],
            ),
          ],
        ),
      );

  Widget _buildCustomCard({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
}