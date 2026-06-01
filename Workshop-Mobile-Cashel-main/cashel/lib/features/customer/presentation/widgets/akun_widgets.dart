import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cashel/data/service/session_service.dart';
import 'package:cashel/features/auth/presentation/screens/login_screen.dart';
import 'package:cashel/features/customer/presentation/screens/keranjang_page.dart'; 

class AkunProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? fotoUrl;     
  final bool isUploading;      
  final VoidCallback onEditName;
  final VoidCallback onEditPhoto;

  const AkunProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.onEditName,
    required this.onEditPhoto,
    this.fotoUrl,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          GestureDetector(
            onTap: onEditPhoto,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: isUploading
                        // load indicator upload foto
                        ? Container(
                            color: const Color(0xFFEEEEEE),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF3498DB),
                              ),
                            ),
                          )
                        : fotoUrl != null
                            // Foto dari server
                            ? Image.network(
                                fotoUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                loadingBuilder: (ctx, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    color: const Color(0xFFEEEEEE),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Color(0xFF3498DB),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (ctx, err, st) => Container(
                                  color: const Color(0xFFEEEEEE),
                                  child: const Icon(Icons.person,
                                      size: 55, color: Color(0xFFBDBDBD)),
                                ),
                              )
                            // Default avatar
                            : Image.asset(
                                'assets/images/profile_pic.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, st) => Container(
                                  color: const Color(0xFFEEEEEE),
                                  child: const Icon(Icons.person,
                                      size: 55, color: Color(0xFFBDBDBD)),
                                ),
                              ),
                  ),
                ),
                // icon camera
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFDDDDDD), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 14, color: Color(0xFF555555)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF181725),
                  fontSize: 22,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onEditName,
                child: const Icon(Icons.edit_outlined,
                    size: 20, color: Color(0xFF3498DB)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              color: Color(0xFF9B9B9B),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class AkunMenuItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const AkunMenuItem({
    super.key,
    required this.iconPath,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
        InkWell(
          onTap: onTap,
          splashColor: const Color(0xFFE8F4FD),
          highlightColor: const Color(0xFFF5F5F5),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(9),
                    child: Image.asset(
                      iconPath,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, st) => const Icon(
                          Icons.help_outline,
                          size: 22,
                          color: Color(0xFF181725)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                            color: Color(0xFF181725),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          )),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(subtitle!,
                            style: const TextStyle(
                              color: Color(0xFF9B9B9B),
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 13, color: Color(0xFFAAAAAA)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LogoutButton extends StatelessWidget {
  final String userId;
  const LogoutButton({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: const Text('Keluar',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold)),
                content: const Text('Apakah kamu yakin ingin keluar?',
                    style: TextStyle(fontFamily: 'Poppins')),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Batal',
                        style: TextStyle(
                            color: Colors.grey, fontFamily: 'Poppins')),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF01F0E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Keluar',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Poppins')),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await KeranjangPage.clearAndLogout(); // hapus session
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFFFFEBE9),
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF01F0E), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.logout_rounded, color: Color(0xFFF01F0E), size: 22),
                SizedBox(width: 12),
                Text('Keluar',
                    style: TextStyle(
                      color: Color(0xFFF01F0E),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}