import 'dart:convert';

class UserModel {
  final String status;
  final String message;
  final UserData? data;

  UserModel({required this.status, required this.message, this.data});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      status: json['status'],
      message: json['message'] ?? '',
      data: json['status'] == 'success' && json['data'] != null
          ? UserData.fromJson(json['data'])
          : null,
    );
  }
}

class UserData {
  final String idAkun;
  final String nama;
  final String email;
  final String noHp;
  final String password;
  final String role;
  final String alamat;
  final String foto;

  UserData({
    required this.idAkun,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.password,
    required this.role,
    required this.alamat,
    required this.foto,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      idAkun:   json['id_akun'].toString(),
      nama:     json['nama']     ?? '',
      email:    json['email']    ?? '',
      noHp:     json['no_hp']    ?? '',
      password: json['password'] ?? '',
      role:     json['role']     ?? 'customer',
      alamat:   json['alamat']   ?? '',
      foto:     json['foto']     ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id_akun':  idAkun,
    'nama':     nama,
    'email':    email,
    'no_hp':    noHp,
    'password': password,
    'role':     role,
    'alamat':   alamat,
    'foto':     foto,
  };

  // ← TAMBAHAN: copyWith untuk update sebagian field tanpa buat ulang semua
  UserData copyWith({
    String? idAkun,
    String? nama,
    String? email,
    String? noHp,
    String? password,
    String? role,
    String? alamat,
    String? foto,
  }) {
    return UserData(
      idAkun:   idAkun   ?? this.idAkun,
      nama:     nama     ?? this.nama,
      email:    email    ?? this.email,
      noHp:     noHp     ?? this.noHp,
      password: password ?? this.password,
      role:     role     ?? this.role,
      alamat:   alamat   ?? this.alamat,
      foto:     foto     ?? this.foto,
    );
  }
}