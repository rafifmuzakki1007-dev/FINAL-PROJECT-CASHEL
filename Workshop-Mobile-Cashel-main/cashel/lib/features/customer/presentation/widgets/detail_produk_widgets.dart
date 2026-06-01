import 'package:flutter/material.dart';

Widget buildCounterBtn(IconData icon, VoidCallback onTap, {Color color = Colors.grey}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(15),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E2E2)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, size: 20, color: color),
    ),
  );
}

Widget buildBottomBtn({required String label, required bool isOutline, required VoidCallback onTap}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isOutline ? Colors.white : const Color(0xFF3498DB),
          borderRadius: BorderRadius.circular(12),
          border: isOutline ? Border.all(color: const Color(0xFF3498DB), width: 2) : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isOutline ? const Color(0xFF3498DB) : Colors.white,
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}