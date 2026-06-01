import 'package:flutter/material.dart';

// Kodingan OrderStatsCard milikmu sudah oke, biarkan tetap seperti ini.


class OrderStatsCard extends StatelessWidget {
  final String title;
  final int count;
  final List<Color> gradientColors;

  const OrderStatsCard({
    super.key,
    required this.title,
    required this.count,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // ... Seluruh kode build kamu ke bawah sudah aman ...
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // Menambahkan sedikit shadow agar lebih mirip desain
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            // Format 09 seperti permintaanmu
            count < 10 ? '0$count' : count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}