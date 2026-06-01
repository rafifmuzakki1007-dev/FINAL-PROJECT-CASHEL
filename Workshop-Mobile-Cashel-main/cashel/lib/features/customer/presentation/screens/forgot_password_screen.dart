import 'package:flutter/material.dart';
import '../../../../data/service/forgot_password_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 1;

  final _emailController       = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmController     = TextEditingController();

  bool    _isLoading   = false;
  bool    _obscureNew  = true;
  bool    _obscureConf = true;
  String? _errorMsg;

  // Disimpan dari response check_email
  String _idAkun = '';

  // Cek email
  Future<void> _checkEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMsg = 'Email tidak boleh kosong');
      return;
    }

    setState(() { _isLoading = true; _errorMsg = null; });

    final result = await ForgotPasswordService.checkEmail(email);

    setState(() => _isLoading = false);

    if (result['status'] == 'success') {
      setState(() {
        _idAkun  = result['id_akun'].toString(); // simpan id_akun dari response
        _step    = 2;
        _errorMsg = null;
      });
    } else {
      setState(() => _errorMsg = result['message'] ?? 'Email tidak ditemukan');
    }
  }

  // Reset password
  Future<void> _resetPassword() async {
    final newPw  = _newPasswordController.text;
    final confPw = _confirmController.text;

    if (newPw.isEmpty || confPw.isEmpty) {
      setState(() => _errorMsg = 'Semua kolom harus diisi');
      return;
    }
    if (newPw.length < 6) {
      setState(() => _errorMsg = 'Password minimal 6 karakter');
      return;
    }
    if (newPw != confPw) {
      setState(() => _errorMsg = 'Konfirmasi password tidak cocok');
      return;
    }

    setState(() { _isLoading = true; _errorMsg = null; });

    final result = await ForgotPasswordService.resetPassword(
      idAkun:      _idAkun,
      newPassword: newPw,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password berhasil diubah! Silakan login.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else {
      setState(() => _errorMsg = result['message'] ?? 'Gagal mengubah password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () {
            if (_step == 2) {
              setState(() { _step = 1; _errorMsg = null; });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/register.png',
                  height: 160, fit: BoxFit.contain),
              const SizedBox(height: 24),

              Text(
                _step == 1 ? 'Lupa Password?' : 'Buat Password Baru',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _step == 1
                    ? 'Masukkan email yang terdaftar.\nKami akan verifikasi akunmu.'
                    : 'Password baru harus berbeda\ndari password sebelumnya.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(height: 28),

              // Error banner
              if (_errorMsg != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE57373),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_errorMsg!,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      textAlign: TextAlign.center),
                ),


              if (_step == 1) ...[
                CustomTextField(hint: 'Email', controller: _emailController),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(text: 'Verifikasi Email', onPressed: _checkEmail),
              ],


              if (_step == 2) ...[
                CustomTextField(
                  hint: 'Password Baru',
                  controller: _newPasswordController,
                  isPassword: _obscureNew,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  hint: 'Konfirmasi Password Baru',
                  controller: _confirmController,
                  isPassword: _obscureConf,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConf ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscureConf = !_obscureConf),
                  ),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(text: 'Simpan Password Baru', onPressed: _resetPassword),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}