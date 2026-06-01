import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  // Di dalam file custom_button.dart
Widget build(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Warna background tombol
        foregroundColor: Colors.white, // INI AKAN MEMBUAT TEKS JADI PUTIH
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          // color: Colors.white, // Bisa juga paksa putih di sini
        ),
      ),
    ),
  );
}
}