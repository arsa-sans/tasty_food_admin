import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum BadgeType { orderStatus, paymentStatus, paymentType, booleanStatus }

class StatusBadge extends StatelessWidget {
  final String status;
  final BadgeType type;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.type = BadgeType.orderStatus,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    if (type == BadgeType.orderStatus) {
      switch (status) {
        case 'menunggu_konfirmasi':
          bg = const Color(0xFFFFF7ED); // Soft orange/amber
          fg = const Color(0xFFC2410C);
          label = 'Menunggu Konfirmasi';
          break;
        case 'dikonfirmasi':
          bg = const Color(0xFFEFF6FF); // Soft blue
          fg = const Color(0xFF1D4ED8);
          label = 'Dikonfirmasi';
          break;
        case 'sedang_dimasak':
          bg = const Color(0xFFFAF5FF); // Soft purple
          fg = const Color(0xFF7E22CE);
          label = 'Sedang Dimasak';
          break;
        case 'dalam_pengiriman':
          bg = const Color(0xFFEEF2FF); // Soft indigo
          fg = const Color(0xFF4338CA);
          label = 'Dalam Pengiriman';
          break;
        case 'selesai':
          bg = const Color(0xFFECFDF5); // Soft emerald
          fg = const Color(0xFF047857);
          label = 'Selesai';
          break;
        case 'dibatalkan':
          bg = const Color(0xFFFEF2F2); // Soft red
          fg = const Color(0xFFB91C1C);
          label = 'Dibatalkan';
          break;
        default:
          bg = AppColors.surfaceVariant;
          fg = AppColors.textSecondary;
          label = status;
      }
    } else if (type == BadgeType.paymentStatus) {
      switch (status) {
        case 'lunas':
          bg = const Color(0xFFECFDF5);
          fg = const Color(0xFF047857);
          label = 'Lunas';
          break;
        case 'menunggu_verifikasi':
          bg = const Color(0xFFFFFBEB);
          fg = const Color(0xFFB45309);
          label = 'Menunggu Verifikasi';
          break;
        case 'ditolak':
          bg = const Color(0xFFFEF2F2);
          fg = const Color(0xFFB91C1C);
          label = 'Ditolak';
          break;
        case 'belum_bayar':
        default:
          bg = const Color(0xFFF1F5F9);
          fg = const Color(0xFF64748B);
          label = 'Belum Bayar';
      }
    } else if (type == BadgeType.paymentType) {
      switch (status) {
        case 'cash':
          bg = const Color(0xFFECFDF5);
          fg = const Color(0xFF047857);
          label = 'Tunai (COD)';
          break;
        case 'e_wallet':
          bg = const Color(0xFFFFF7ED);
          fg = const Color(0xFFC2410C);
          label = 'E-Wallet / QRIS';
          break;
        case 'bank':
          bg = const Color(0xFFEFF6FF);
          fg = const Color(0xFF1D4ED8);
          label = 'Transfer Bank';
          break;
        default:
          bg = AppColors.surfaceVariant;
          fg = AppColors.textSecondary;
          label = status;
      }
    } else {
      final isTrue = status == '1' || status == 'true' || status == 'published' || status == 'aktif';
      bg = isTrue ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9);
      fg = isTrue ? const Color(0xFF047857) : const Color(0xFF64748B);
      label = isTrue ? 'Tersedia' : 'Habis / Nonaktif';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
