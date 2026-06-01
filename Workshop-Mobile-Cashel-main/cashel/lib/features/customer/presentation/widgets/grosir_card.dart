import 'package:flutter/material.dart';

class GrosirCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final double scale;
  final VoidCallback? onTap;

  const GrosirCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.scale,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 180 * scale,
      margin: EdgeInsets.only(right: 15 * scale),
      padding: EdgeInsets.symmetric(horizontal: 12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFDEECFB),
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: 50 * scale, height: 50 * scale),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF181725),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}