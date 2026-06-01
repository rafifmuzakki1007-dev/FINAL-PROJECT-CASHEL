import 'package:flutter/material.dart';
import 'package:cashel/api/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import '../../../data/models/produk_model.dart';

class EditDetailProduk extends StatefulWidget {
  final ProdukModel? produk;
  const EditDetailProduk({super.key, this.produk});

  @override
  State<EditDetailProduk> createState() => _EditDetailProdukState();
}

class _EditDetailProdukState extends State<EditDetailProduk> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _stokController;
  late TextEditingController _descController;

  bool _isEditMode = false;

  String _gambarTerpilih = "default.png";
  Uint8List? _bytesGambarWeb;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.produk != null;

    _namaController = TextEditingController(
      text: _isEditMode ? widget.produk!.namaProduk : "",
    );
    _hargaController = TextEditingController(
      text: _isEditMode ? widget.produk!.harga.toString() : "",
    );
    _stokController = TextEditingController(
      text: _isEditMode ? widget.produk!.stok.toString() : "",
    );
    _descController = TextEditingController(
      text: _isEditMode ? widget.produk!.deskripsi : "",
    );

    _gambarTerpilih = _isEditMode ? widget.produk!.gambar : "default.png";
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      String url = _isEditMode
          ? "${ApiConfig.baseUrl}/api_stok/update_produk.php"
          : "${ApiConfig.baseUrl}/api_stok/tambah_produk.php";

      try {
        // Pakai MultipartRequest agar bisa upload file gambar sekaligus
        var request = http.MultipartRequest('POST', Uri.parse(url));

        request.fields['nama_produk'] = _namaController.text;
        request.fields['harga']       = _hargaController.text;
        request.fields['stok']        = _stokController.text;
        request.fields['deskripsi']   = _descController.text;
        request.fields['kategori']    = 'Alat Tulis';

        if (_isEditMode) {
          request.fields['id_produk'] = widget.produk!.idProduk.toString();
        }

        // Jika user memilih gambar baru → upload file-nya ke server
        if (_bytesGambarWeb != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'gambar',
              _bytesGambarWeb!,
              filename: _gambarTerpilih,
            ),
          );
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final dataRespon = json.decode(response.body);
          if (dataRespon['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(dataRespon['message'] ?? "Berhasil disimpan!")),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Gagal Simpan: ${dataRespon['message']}")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Server Error: Status ${response.statusCode}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan koneksi: $e")),
        );
      }
    }
  }

  // Fungsi hapus produk (hanya di edit mode)
  Future<void> _deleteProduk() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Produk", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Yakin ingin menghapus '${widget.produk!.namaProduk}' secara permanen?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api_stok/delete_produk.php"),
        body: {"id_produk": widget.produk!.idProduk.toString()},
      );
      if (response.statusCode == 200) {
        final dataRespon = json.decode(response.body);
        if (dataRespon['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Produk berhasil dihapus!"), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal: ${dataRespon['message']}")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kesalahan koneksi: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isEditMode ? "Edit Produk" : "Tambah Produk Baru",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        // Tombol hapus hanya muncul di mode edit
        actions: _isEditMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: "Hapus Produk",
                  onPressed: _deleteProduk,
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // AREA GAMBAR PRODUK DINAMIS (WEB COMPATIBLE)
              Center(
                child: Stack(
                  children: [
                    // Bingkai Foto Utama
                    Container(
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: _bytesGambarWeb != null
                            // 1. Baru pilih gambar → tampilkan dari memory
                            ? Image.memory(_bytesGambarWeb!, fit: BoxFit.cover)
                            : (_isEditMode && _gambarTerpilih.isNotEmpty && _gambarTerpilih != "default.png"
                                // 2. Edit mode → ambil dari server
                                ? Image.network(
                                    '${ApiConfig.baseUrl}/api_stok/uploads/$_gambarTerpilih',
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Image.asset(
                                      'assets/images/$_gambarTerpilih',
                                      fit: BoxFit.cover,
                                      errorBuilder: (c2, e2, s2) => const Center(
                                        child: Icon(Icons.image, size: 40, color: Colors.grey),
                                      ),
                                    ),
                                  )
                                // 3. Tambah baru belum pilih foto
                                : const Center(
                                    child: Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: Colors.pink,
                                    ),
                                  )),
                      ),
                    ),
                    // Tombol Bulat Ikon Pensil di Pojok Kanan Bawah
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();

                          // Membuka Galeri Foto HP/PC
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 70,
                          );

                          if (image != null) {
                            String namaBawaan = image.name;

                            // 🔥 PERBAIKAN UTAMA: Potong awalan 'scaled_' secara otomatis jika terdeteksi dari browser
                            String namaFileGambar = namaBawaan.startsWith('scaled_')
                                ? namaBawaan.replaceFirst('scaled_', '')
                                : namaBawaan;

                            // Membaca data bytes gambar dari galeri khusus untuk Web
                            final Uint8List dataBytes = await image.readAsBytes();

                            setState(() {
                              _gambarTerpilih = namaFileGambar; // Menyimpan nama bersih (misal: 'pensil.png')
                              _bytesGambarWeb = dataBytes;     // Menampilkan biner gambar ke kotak UI
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Gambar terpilih: $namaFileGambar"),
                              ),
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF2196F3), // Biru figma
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Field Input Nama
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: "Nama Produk",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Harus diisi" : null,
              ),
              const SizedBox(height: 15),

              // Field Input Harga
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Harga (Rp)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Harus diisi" : null,
              ),
              const SizedBox(height: 15),

              // Field Input Stok
              TextFormField(
                controller: _stokController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Jumlah Stok",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Harus diisi" : null,
              ),
              const SizedBox(height: 15),

              // Field Deskripsi
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Deskripsi Produk",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3), // Warna Biru Figma
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26), // Capsule style
                    ),
                    elevation: 0,
                  ),
                  onPressed: _saveData,
                  child: const Text(
                    "SIMPAN PRODUK",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}