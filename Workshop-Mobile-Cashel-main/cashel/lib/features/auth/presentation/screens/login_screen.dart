import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../features/admin/screen/admin_main_screen.dart';
import '.././screens/register_page.dart';
import '../../../../data/service/login_service.dart';
import '../../../../data/service/session_service.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../../../../features/customer/presentation/screens/main_navigation.dart';
import '../../../../features/customer/presentation/screens/keranjang_page.dart';
import '../../../customer/presentation/screens/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool _isObscure = true;
  String? errorMessage;

  // login google
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;

      if (user != null) {
        try {
          final response = await http.post(
            Uri.parse("http://192.168.18.154/api_cashel/auth/google_login.php"),
            headers: {"Content-Type": "application/x-www-form-urlencoded"},
            body: {
              "nama":  user.displayName ?? "",
              "email": user.email ?? "",
              "uid":   user.uid,
            },
          );

          final responseBody = response.body.trim();

          if (responseBody.isNotEmpty && !responseBody.startsWith('<')) {
            final responseData = jsonDecode(responseBody);

            if (responseData['status'] == 'success') {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt(
                'id_akun',
                int.parse(responseData['data']['id_akun'].toString()),
              );

              final userData = UserData.fromJson(responseData['data']);
              await SessionService.saveUser(userData);
              await KeranjangPage.loadKeranjang(userData.idAkun);
            }
          }
        } catch (httpError) {
          debugPrint("HTTP error (diabaikan): $httpError");
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Login berhasil!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );

        final String userRole = SessionService.currentUser?.role ?? 'customer';

        if (userRole == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminMainScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google Sign-In gagal: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  // login manual
  void handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      LoginService authService = LoginService();
      UserModel response = await authService.login(
        emailController.text,
        passwordController.text,
      );

      if (!mounted) return;

      if (response.status == 'success') {
        final prefs = await SharedPreferences.getInstance();
        if (response.data?.idAkun != null) {
          await prefs.setInt(
            'id_akun',
            int.parse(response.data!.idAkun.toString()),
          );
        }

        if (response.data?.idAkun != null) {
          await KeranjangPage.loadKeranjang(response.data!.idAkun);
        }

        setState(() => isLoading = false);

        String userRole = response.data?.role ?? 'customer';

        if (userRole == 'admin') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminMainScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = response.message.isNotEmpty
              ? response.message
              : "Email atau Password salah!";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = "Terjadi kesalahan koneksi: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              if (errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE57373),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),

              const SizedBox(height: 40),
              Image.asset('assets/images/register.png',
                  height: 180, fit: BoxFit.contain),
              const SizedBox(height: 20),
              const Text("Login",
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),

              CustomTextField(hint: "Email", controller: emailController),
              const SizedBox(height: 15),
              CustomTextField(
                hint: "Password",
                controller: passwordController,
                isPassword: _isObscure,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _isObscure = !_isObscure),
                ),
              ),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () { // ← DIUBAH
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text("Lupa password?",
                      style: TextStyle(color: Colors.grey)),
                ),
              ),

              const SizedBox(height: 25),
              isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(text: "Masuk", onPressed: handleLogin),

              const SizedBox(height: 30),
              _buildDivider(),
              const SizedBox(height: 25),

              _buildSocialButton(
                text: "Google",
                iconAsset: 'assets/images/google-icon.png',
                borderColor: Colors.redAccent,
                textColor: Colors.redAccent,
                onTap: () async => await signInWithGoogle(),
              ),

              const SizedBox(height: 30),
              _buildRegisterRedirect(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text("Atau masuk menggunakan",
              style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ),
        const Expanded(child: Divider(thickness: 1.5)),
      ],
    );
  }

  Widget _buildSocialButton({
    required String text,
    required String iconAsset,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconAsset, height: 24),
            const SizedBox(width: 12),
            Text(text,
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Belum punya akun? "),
        InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RegisterPage()));
          },
          child: const Text("Mendaftar sekarang",
              style: TextStyle(
                  color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}