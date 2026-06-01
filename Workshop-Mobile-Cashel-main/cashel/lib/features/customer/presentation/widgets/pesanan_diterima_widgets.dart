import 'package:flutter/material.dart';

class PesananDiterimaContent extends StatelessWidget {
  const PesananDiterimaContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Pesanan Anda telah \nditerima!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF181725),
            fontSize: 24,
            fontFamily: 'Poppins', // Konsisten dengan desain Cashel
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Barang Anda telah dipesan dan \nsedang dalam proses.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF7C7C7C),
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.text,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 67,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF3498DB) : Colors.transparent, // Biru Cashel
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary ? Colors.white : const Color(0xFF181725),
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}