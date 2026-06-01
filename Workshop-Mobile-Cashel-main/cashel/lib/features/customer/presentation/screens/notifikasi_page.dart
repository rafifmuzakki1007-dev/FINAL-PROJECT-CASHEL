import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
 
    return LayoutBuilder(
      builder: (context, constraints) {
        final double scale = constraints.maxWidth / 414;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            centerTitle: true,
            title: Text(
              "Notifikasi",
              style: TextStyle(
                color: const Color(0xFF181725),
                fontFamily: 'Poppins',
                fontSize: 18 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: _buildEmptyNotification(scale),
        );
      },
    );
  }

  Widget _buildEmptyNotification(double scale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
     
          Icon(
            Icons.notifications_none_rounded,
            size: 80 * scale,
            color: Colors.grey[300],
          ),
          SizedBox(height: 20 * scale),
          Text(
            "Belum ada notifikasi",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16 * scale,
              color: const Color(0xFF7C7C7C),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8 * scale),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40 * scale),
            child: Text(
              "Notifikasi mengenai pesanan dan promo menarik akan muncul di sini.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14 * scale,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}