import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../viewmodels/payment_method_viewmodel.dart';
import 'payment_method_form_view.dart';

class PaymentMethodListView extends StatefulWidget {
  const PaymentMethodListView({super.key});

  @override
  State<PaymentMethodListView> createState() => _PaymentMethodListViewState();
}

class _PaymentMethodListViewState extends State<PaymentMethodListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentMethodViewModel>().fetchPaymentMethods();
    });
  }

  void _confirmDelete(int id, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Metode Pembayaran'),
        content: Text('Apakah Anda yakin ingin menghapus metode "$nama"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<PaymentMethodViewModel>().deletePaymentMethod(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Metode pembayaran dihapus' : 'Gagal menghapus metode'),
                    backgroundColor: success ? AppColors.success : AppColors.danger,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payVm = context.watch<PaymentMethodViewModel>();
    final methods = payVm.filteredMethods;

    final filterTypes = [
      {'val': 'Semua', 'label': 'Semua Tipe'},
      {'val': 'cash', 'label': 'Tunai (COD)'},
      {'val': 'e_wallet', 'label': 'E-Wallet / QRIS'},
      {'val': 'bank', 'label': 'Transfer Bank'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PaymentMethodFormView()),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Metode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
      ),
      body: Column(
        children: [
          // 1. Filter Chips Carousel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filterTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = filterTypes[index];
                  final isSelected = payVm.selectedTipe == item['val'];

                  return InkWell(
                    onTap: () => payVm.setTipe(item['val']!),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.secondary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.secondary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        item['label']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // 2. Methods List with Shimmer
          Expanded(
            child: payVm.isLoading
                ? const PaymentMethodListShimmer()
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => payVm.fetchPaymentMethods(),
                    child: methods.isEmpty
                        ? const EmptyState(
                            icon: Icons.payments_outlined,
                            title: 'Metode Pembayaran Kosong',
                            message: 'Belum ada metode pembayaran yang terdaftar untuk tipe ini.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                            itemCount: methods.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final method = methods[index];

                              IconData methodIcon;
                              Color methodColor;
                              if (method.tipe == 'bank') {
                                methodIcon = Icons.account_balance_rounded;
                                methodColor = const Color(0xFF1D4ED8);
                              } else if (method.tipe == 'e_wallet') {
                                methodIcon = Icons.qr_code_scanner_rounded;
                                methodColor = const Color(0xFFC2410C);
                              } else {
                                methodIcon = Icons.payments_rounded;
                                methodColor = const Color(0xFF047857);
                              }

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: methodColor.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Icon(methodIcon, color: methodColor, size: 22),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    method.nama,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 14,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  StatusBadge(
                                                    status: method.tipe,
                                                    type: BadgeType.paymentType,
                                                    showDot: false,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textMuted),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            onSelected: (val) {
                                              if (val == 'edit') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => PaymentMethodFormView(method: method),
                                                  ),
                                                );
                                              } else if (val == 'delete') {
                                                _confirmDelete(method.id, method.nama);
                                              }
                                            },
                                            itemBuilder: (_) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit_rounded, size: 18, color: AppColors.info),
                                                    SizedBox(width: 8),
                                                    Text('Edit Metode'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                                                    SizedBox(width: 8),
                                                    Text('Hapus Metode'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      // Account Info
                                      if (method.nomorRekening != null && method.nomorRekening!.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: const Color(0xFFE2E8F0)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.credit_card_rounded, size: 16, color: AppColors.textMuted),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '${method.nomorRekening} (${method.atasNama ?? '-'})',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  Clipboard.setData(ClipboardData(text: method.nomorRekening!));
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Nomor disalin ke clipboard'),
                                                      duration: Duration(seconds: 1),
                                                    ),
                                                  );
                                                },
                                                child: const Icon(Icons.copy_rounded, size: 14, color: AppColors.textMuted),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: 10),
                                      const Divider(height: 1, color: AppColors.border),
                                      const SizedBox(height: 6),

                                      // Bottom active toggle
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: method.isAktif ? const Color(0xFF16A34A) : AppColors.textMuted,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                method.isAktif ? 'Aktif (Pelanggan dapat memilih)' : 'Nonaktif (Disembunyikan)',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: method.isAktif ? const Color(0xFF16A34A) : AppColors.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Switch.adaptive(
                                            value: method.isAktif,
                                            activeThumbColor: AppColors.primary,
                                            activeTrackColor: AppColors.primaryLight,
                                            inactiveThumbColor: Colors.grey,
                                            inactiveTrackColor: const Color(0xFFE2E8F0),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            onChanged: (_) => payVm.toggleActive(method),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
