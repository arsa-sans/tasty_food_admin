import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../viewmodels/order_viewmodel.dart';
import 'order_detail_view.dart';

class OrderListView extends StatefulWidget {
  const OrderListView({super.key});

  @override
  State<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _quickAcceptOrder(int orderId) async {
    final orderVm = context.read<OrderViewModel>();
    final success = await orderVm.updateOrderStatus(
      orderId,
      'dikonfirmasi',
      'Pesanan telah diterima oleh restoran dan sedang masuk antrean dapur.',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Pesanan berhasil dikonfirmasi!' : 'Gagal memperbarui status'),
          backgroundColor: success ? AppColors.success : AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderVm = context.watch<OrderViewModel>();
    final orders = orderVm.filteredOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 1. Search Bar & Status Pills Carousel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              children: [
                // Search Input Field
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => orderVm.setSearchQuery(val),
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Cari kode TF-..., nama pelanggan, no telp...',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                              onPressed: () {
                                _searchController.clear();
                                orderVm.setSearchQuery('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Status Tabs Horizontal Scroll
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: orderVm.statusTabs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final statusKey = orderVm.statusTabs[index];
                      final isSelected = orderVm.selectedStatus == statusKey;

                      String label = 'Semua';
                      if (statusKey == 'menunggu_konfirmasi') label = 'Menunggu Konfirmasi';
                      if (statusKey == 'dikonfirmasi') label = 'Dikonfirmasi';
                      if (statusKey == 'sedang_dimasak') label = 'Dimasak';
                      if (statusKey == 'dalam_pengiriman') label = 'Pengiriman';
                      if (statusKey == 'selesai') label = 'Selesai';
                      if (statusKey == 'dibatalkan') label = 'Dibatalkan';

                      return InkWell(
                        onTap: () => orderVm.setStatus(statusKey),
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
                            label,
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
              ],
            ),
          ),

          // 2. Orders Counter Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Tiket: ${orders.length} Pesanan',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'Urutan: Terbaru',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // 3. Orders List Body with Shimmer
          Expanded(
            child: orderVm.isLoading
                ? const OrderListShimmer()
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => orderVm.fetchOrders(),
                    child: orders.isEmpty
                        ? const EmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: 'Tidak Ada Pesanan',
                            message: 'Belum ada pesanan dengan kriteria filter ini.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                            itemCount: orders.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              final isPending = order.status == 'menunggu_konfirmasi';

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isPending ? const Color(0xFFFDBA74) : AppColors.border,
                                    width: isPending ? 1.5 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isPending
                                          ? AppColors.primary.withValues(alpha: 0.06)
                                          : Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    orderVm.selectOrder(order);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OrderDetailView(order: order),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header Row: Code with copy button + StatusBadge
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF1F5F9),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    order.orderCode,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 12,
                                                      color: AppColors.secondary,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                IconButton(
                                                  icon: const Icon(Icons.copy_rounded, size: 14, color: AppColors.textMuted),
                                                  visualDensity: VisualDensity.compact,
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  onPressed: () {
                                                    Clipboard.setData(ClipboardData(text: order.orderCode));
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Kode pesanan disalin'),
                                                        duration: Duration(seconds: 1),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            StatusBadge(status: order.status),
                                          ],
                                        ),
                                        const SizedBox(height: 10),

                                        // Customer Info Row
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 14,
                                              backgroundColor: AppColors.primaryLight,
                                              child: const Icon(Icons.person, size: 14, color: AppColors.primary),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              order.namaPelanggan,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              order.telepon,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // Delivery Address Snippet
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                order.alamatLengkap,
                                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Items Preview Container
                                        if (order.items.isNotEmpty) ...[
                                          const SizedBox(height: 10),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: const Color(0xFFE2E8F0)),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: order.items.take(2).map((it) {
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '${it.jumlah}x ${it.namaMenu}',
                                                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Text(
                                                        it.formattedSubtotal,
                                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],

                                        // Customer Note if any
                                        if (order.catatan != null && order.catatan!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFFBEB),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: const Color(0xFFFDE68A)),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.notes_rounded, size: 12, color: Color(0xFFB45309)),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'Catatan: "${order.catatan}"',
                                                    style: const TextStyle(fontSize: 11, color: Color(0xFFB45309), fontStyle: FontStyle.italic),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],

                                        const SizedBox(height: 10),
                                        const Divider(height: 1, color: AppColors.border),
                                        const SizedBox(height: 10),

                                        // Total Price & Actions
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    StatusBadge(
                                                      status: order.statusPembayaran,
                                                      type: BadgeType.paymentStatus,
                                                      showDot: false,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      order.createdAt != null
                                                          ? Formatters.formatTime(order.createdAt!)
                                                          : '',
                                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  order.formattedTotal,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 15,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                if (isPending) ...[
                                                  ElevatedButton(
                                                    onPressed: () => _quickAcceptOrder(order.id),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: AppColors.primary,
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                      elevation: 0,
                                                    ),
                                                    child: const Text(
                                                      'Terima Pesanan',
                                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                ],
                                                OutlinedButton(
                                                  onPressed: () {
                                                    orderVm.selectOrder(order);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => OrderDetailView(order: order),
                                                      ),
                                                    );
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    side: const BorderSide(color: AppColors.border),
                                                  ),
                                                  child: const Text(
                                                    'Rincian',
                                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
