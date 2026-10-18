import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../orders/order_detail_view.dart';
import '../orders/order_list_view.dart';
import '../menu/menu_form_view.dart';
import '../berita/berita_form_view.dart';
import '../payment_methods/payment_method_list_view.dart';
import '../../data/models/dashboard_stats_model.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashVm = context.watch<DashboardViewModel>();
    final stats = dashVm.stats;

    if (dashVm.isLoading) {
      return const DashboardShimmer();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => dashVm.fetchDashboardStats(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Merchant Identity & Operational Header
            _buildMerchantHeader(),
            const SizedBox(height: 16),

            // 2. Live Store Status Banner
            // _buildStoreStatusBar(),
            // const SizedBox(height: 20),

            // 3. Operational KPI Cards
            _buildSectionTitle('Ringkasan Operasional Hari Ini'),
            const SizedBox(height: 12),
            _buildKpiGrid(stats),
            const SizedBox(height: 24),

            // 4. Quick Actions
            _buildSectionTitle('Aksi Cepat Merchant'),
            const SizedBox(height: 12),
            _buildQuickActions(),
            const SizedBox(height: 24),

            // 5. Recent Orders Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Pesanan Terbaru'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrderListView()),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildRecentOrders(stats),
            const SizedBox(height: 24),

            // 6. Recent Messages Section
            _buildSectionTitle('Pertanyaan Pelanggan Terbaru'),
            const SizedBox(height: 12),
            _buildRecentMessages(stats),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildMerchantHeader() {
    final now = DateTime.now();
    final formattedDate = Formatters.formatDate(now);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Selamat Datang, Admin!',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$formattedDate • Tasty Food Merchant',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(DashboardStatsModel stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = Responsive.value(
          context,
          mobile: 2,
          tablet: 3,
          desktop: 4,
        );

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: Responsive.value(context, mobile: 1.25, tablet: 1.35, desktop: 1.4),
          children: [
            StatCard(
              title: 'Total Pesanan',
              value: stats.totalOrders.toString(),
              icon: Icons.receipt_long_rounded,
              color: AppColors.info,
              subtitle: 'Semua riwayat',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderListView()),
                );
              },
            ),
            StatCard(
              title: 'Perlu Konfirmasi',
              value: stats.unconfirmedOrdersCount.toString(),
              icon: Icons.pending_actions_rounded,
              color: AppColors.warning,
              subtitle: stats.unconfirmedOrdersCount > 0 ? 'Segera proses' : 'Semua aman',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderListView()),
                );
              },
            ),
            StatCard(
              title: 'Menu Makanan',
              value: stats.totalMenu.toString(),
              icon: Icons.restaurant_menu_rounded,
              color: AppColors.primary,
              subtitle: 'Katalog aktif',
            ),
            StatCard(
              title: 'Pesan Masuk',
              value: stats.unreadMessagesCount.toString(),
              icon: Icons.mail_rounded,
              color: AppColors.danger,
              subtitle: stats.unreadMessagesCount > 0 ? 'Belum dibaca' : 'Tidak ada baru',
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: _quickActionButton(
                icon: Icons.add_rounded,
                label: 'Tambah Menu',
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MenuFormView()),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _quickActionButton(
                icon: Icons.receipt_long_rounded,
                label: 'Cek Pesanan',
                color: AppColors.info,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderListView()),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _quickActionButton(
                icon: Icons.payments_rounded,
                label: 'Metode Bayar',
                color: AppColors.success,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentMethodListView()),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _quickActionButton(
                icon: Icons.edit_note_rounded,
                label: 'Tulis Berita',
                color: AppColors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BeritaFormView()),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(DashboardStatsModel stats) {
    if (stats.latestOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'Belum ada pesanan terbaru masuk hari ini.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: stats.latestOrders.map<Widget>((order) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          child: InkWell(
            onTap: () {
              context.read<OrderViewModel>().selectOrder(order);
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
                  // Top ticket bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      StatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Customer name & total
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          order.namaPelanggan.isNotEmpty
                              ? order.namaPelanggan[0].toUpperCase()
                              : 'P',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.namaPelanggan,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.alamatLengkap,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                          ),
                          Text(
                            order.formattedTotal,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 10),

                  // Footer info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            order.createdAt != null
                                ? Formatters.formatTime(order.createdAt!)
                                : 'Hari ini',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          const SizedBox(width: 12),
                          StatusBadge(
                            status: order.tipePembayaran ?? 'cash',
                            type: BadgeType.paymentType,
                            showDot: false,
                          ),
                        ],
                      ),
                      const Row(
                        children: [
                          Text(
                            'Detail',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentMessages(DashboardStatsModel stats) {
    if (stats.latestMessages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'Belum ada pesan pertanyaan dari pelanggan.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: stats.latestMessages.map<Widget>((msg) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: msg.isUnread ? AppColors.dangerLight : const Color(0xFFF1F5F9),
              child: Icon(
                Icons.mail_rounded,
                color: msg.isUnread ? AppColors.danger : AppColors.textSecondary,
                size: 18,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    msg.nama,
                    style: TextStyle(
                      fontWeight: msg.isUnread ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (msg.isUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Baru',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.dangerDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  msg.subjek,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  msg.pesan,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

