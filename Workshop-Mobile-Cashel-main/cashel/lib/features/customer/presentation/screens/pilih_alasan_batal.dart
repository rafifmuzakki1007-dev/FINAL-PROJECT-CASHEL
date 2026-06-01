import 'package:flutter/material.dart';

class PilihAlasanBatalPage extends StatefulWidget {
  final Future<void> Function(String alasan)? onKonfirmasi;

  const PilihAlasanBatalPage({super.key, this.onKonfirmasi});

  static Future<void> show(
    BuildContext context, {
    Future<void> Function(String alasan)? onKonfirmasi,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PilihAlasanBatalPage(onKonfirmasi: onKonfirmasi),
    );
  }

  @override
  State<PilihAlasanBatalPage> createState() => _PilihAlasanBatalPageState();
}

class _PilihAlasanBatalPageState extends State<PilihAlasanBatalPage> {
  String? _selectedReason;
  bool _isLoading = false;

  final List<String> _alasanList = [
    "Ingin mengubah rincian & membuat pesanan baru",
    "Toko tidak membalas chat",
    "Tidak memerlukan barang ini",
    "Alasan lainnya",
  ];

  @override
  Widget build(BuildContext context) {
    final bool hasSelected = _selectedReason != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    "Pilih Alasan Pembatalan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF555555), size: 22),
                    splashRadius: 20,
                  ),
                ),
              ],
            ),
          ),

          // info banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: const Color(0xFFEAF4FF),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3498DB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Mohon pilih alasan pembatalan. Pesananmu akan langsung dibatalkan setelah alasan pembatalan diajukan.",
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      color: Color(0xFF2C3E50),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // daftar alasan 
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              children: _alasanList.map((alasan) {
                final selected = _selectedReason == alasan;
                return GestureDetector(
                  onTap: () => setState(() => _selectedReason = alasan),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        // Custom radio circle
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF3498DB)
                                  : const Color(0xFFCCCCCC),
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF3498DB),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            alasan,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // tombol konfirmasi
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (hasSelected && !_isLoading)
                    ? () async {
                        setState(() => _isLoading = true);
                        if (widget.onKonfirmasi != null) {
                          await widget.onKonfirmasi!(_selectedReason!);
                        }
                        
                        if (mounted) setState(() => _isLoading = false);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  disabledBackgroundColor: const Color(0xFFE8E8E8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        "Konfirmasi",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color:
                              hasSelected ? Colors.white : Colors.grey[400],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}