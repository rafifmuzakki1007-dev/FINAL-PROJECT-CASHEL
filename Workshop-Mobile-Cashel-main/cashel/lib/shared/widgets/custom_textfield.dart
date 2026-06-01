import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;
  final Widget? suffixIcon; // 1. Tambahkan baris ini

  const CustomTextField({
    super.key,
    required this.hint,
    this.isPassword = false,
    this.controller,
    this.suffixIcon, // 2. Tambahkan baris ini
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword, // Ini yang mengontrol titik-titik password
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon, // 3. Pasang ikon di sini agar muncul di kanan
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}