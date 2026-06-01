import 'package:flutter/material.dart';

class DetailPesananScreen extends StatelessWidget {
  const DetailPesananScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Latar belakang abu-abu muda agar kartu putih terlihat bersih
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pesanan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KARTU STATUS (Warna Biru Khas Chasel)
            _buildStatusHeader(),
            const SizedBox(height: 20),

            // 2. BAGIAN ALAMAT
            _buildSectionTitle("Alamat Pengiriman"),
            _buildAddressCard(),
            const SizedBox(height: 20),

            // 3. BAGIAN PRODUK (Menggunakan gambar pensil kamu)
            _buildSectionTitle("Produk Dipesan"),
            _buildProductCard(),
            const SizedBox(height: 20),

            // 4. RINCIAN PEMBAYARAN
            _buildSectionTitle("Rincian Pembayaran"),
            _buildPaymentDetailCard(),
            const SizedBox(height: 80), // Jarak ekstra agar tidak tertutup tombol bawah
          ],
        ),
      ),
      
      // 5. TOMBOL AKSI DI BAWAH (Fixed Bottom)
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B95DE), // Biru Chasel
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sedang Dikirim",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                "No. Resi: CHSL-99210034",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Icon(Icons.local_shipping_rounded, color: Colors.white, size: 32),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on_outlined, color: Color(0xFF3B95DE), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Jefri Nichol", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("0812-3456-7890", style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  "Jl. Merdeka No. 123, Kel. Gambir, Kec. Gambir, Kota Jakarta Pusat, 10110",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // Gambar Pensil Staedtler
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/pensil.png', // Link gambar pensil kamu
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pensil Staedtler 2B",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text("Varian: Hitam", style: TextStyle(color: Colors.grey, fontSize: 12)),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("1x", style: TextStyle(color: Colors.grey)),
                    Text(
                      "Rp. 4.000",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          _paymentRow("Subtotal Produk", "Rp. 4.000"),
          _paymentRow("Biaya Pengiriman", "Rp. 10.000"),
          _paymentRow("Diskon Promosi", "-Rp. 2.000", isDiscount: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(thickness: 1),
          ),
          _paymentRow("Total Pembayaran", "Rp. 12.000", isTotal: true),
        ],
      ),
    );
  }

  Widget _paymentRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.black : Colors.grey.shade600,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isDiscount ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Tambahkan logika pelacakan di sini
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B95DE),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text(
          "Lacak Pesanan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}