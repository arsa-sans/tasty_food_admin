import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/animated_pressable.dart';
import '../../core/widgets/app_cached_image.dart';
import '../../core/widgets/circular_target_gauge.dart';
import '../../core/widgets/pulsing_badge.dart';
import '../../core/widgets/staggered_entrance.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../data/models/order_model.dart';
import '../orders/order_detail_view.dart';
import '../orders/order_list_view.dart';
import '../menu/menu_list_view.dart';
import '../menu/menu_form_view.dart';
import '../messages/message_detail_view.dart';
import '../messages/message_list_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _isStoreOpen = true;
  String _selectedQueueFilter = 'semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().fetchDashboardStats();
      context.read<MenuViewModel>().fetchMenus();
    });
  }

  void _toggleStoreStatus() {
    setState(() {
      _isStoreOpen = !_isStoreOpen;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isStoreOpen
              ? 'Toko sekarang BUKA dan siap menerima pesanan'
              : 'Toko dijeda sementara (Pesanan baru dinonaktifkan)',
        ),
        backgroundColor: _isStoreOpen ? AppColors.success : AppColors.secondary,
        duration: const Duration(seconds: 2),
      ),
    );
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
          content: Text(success ? 'Pesanan berhasil dikonfirmasi ke dapur!' : 'Gagal memperbarui status'),
          backgroundColor: success ? AppColors.success : AppColors.danger,
        ),
      );
      context.read<DashboardViewModel>().fetchDashboardStats();
    }
  }

  void _quickCookOrder(int orderId) async {
    final orderVm = context.read<OrderViewModel>();
    final success = await orderVm.updateOrderStatus(
      orderId,
      'sedang_dimasak',
      'Pesanan sedang dimasak oleh tim koki restoran.',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Pesanan masuk proses memasak di dapur!' : 'Gagal memperbarui status'),
          backgroundColor: success ? const Color(0xFF7E22CE) : AppColors.danger,
        ),
      );
      context.read<DashboardViewModel>().fetchDashboardStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashVm = context.watch<DashboardViewModel>();
    final menuVm = context.watch<MenuViewModel>();
    final stats = dashVm.stats;

    if (dashVm.isLoading) {
      return const DashboardShimmer();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await dashVm.fetchDashboardStats();
        await menuVm.fetchMenus();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Restaurant Operational Status Bar & Interactive Toggle
            StaggeredEntrance(
              index: 0,
              child: _buildOperationalStatusBar(),
            ),
            const SizedBox(height: 12),

            // 2. Live Incoming Orders Ticker Pill
            if (stats.unconfirmedOrdersCount > 0) ...[
              StaggeredEntrance(
                index: 1,
                child: _buildIncomingTickerPill(stats.unconfirmedOrdersCount),
              ),
              const SizedBox(height: 12),
            ],

            // 3. Floating Customer Inquiries Alert Banner
            if (stats.unreadMessagesCount > 0) ...[
              StaggeredEntrance(
                index: 2,
                child: _buildInquiriesAlertBanner(stats.unreadMessagesCount, stats.latestMessages),
              ),
              const SizedBox(height: 14),
            ],

            // 4. Daily Performance & Revenue Hero Card (Stitch Circular Target Gauge)
            StaggeredEntrance(
              index: 3,
              child: _buildRevenuePerformanceHero(stats),
            ),
            const SizedBox(height: 22),

            // 5. Live Kitchen Order Queue Slider (Horizontal Kanban Tickets)
            StaggeredEntrance(
              index: 4,
              child: _buildKitchenLiveQueueSection(stats.latestOrders),
            ),
            const SizedBox(height: 24),

            // 6. Food Menu Quick Inventory & Stock Manager
            StaggeredEntrance(
              index: 5,
              child: _buildQuickInventorySection(menuVm),
            ),
            const SizedBox(height: 24),

            // 7. Recent Customer Inquiries List
            StaggeredEntrance(
              index: 6,
              child: _buildRecentCustomerInquiries(stats),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // SECTION 1: Operational Status Bar with Interactive Store Switcher
  Widget _buildOperationalStatusBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Outlet info
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Outlet Utama Cianjur',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Tasty Food Bistro',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Interactive Store Status Toggle Pill
              AnimatedPressable(
                onTap: _toggleStoreStatus,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isStoreOpen
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isStoreOpen
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isStoreOpen)
                        const PulsingDot(color: Color(0xFF047857), size: 7)
                      else
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        _isStoreOpen ? 'Toko Buka' : 'Toko Jeda',
                        style: TextStyle(
                          color: _isStoreOpen ? const Color(0xFF047857) : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isStoreOpen ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                        color: _isStoreOpen ? const Color(0xFF047857) : AppColors.textMuted,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Operational hours & Cloud Sync strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 14, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Jam Ops: 09:00 - 22:00 WIB',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.wifi_tethering_rounded, size: 14, color: AppColors.success),
                    SizedBox(width: 6),
                    Text(
                      'Cloud Sync Aktif',
                      style: TextStyle(fontSize: 11, color: AppColors.successDark, fontWeight: FontWeight.w700),
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

  // SECTION 2: Live Incoming Orders Ticker Pill
  Widget _buildIncomingTickerPill(int unconfirmedCount) {
    return AnimatedPressable(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrderListView()),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFDBA74)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: PulsingDot(color: Colors.white, size: 6),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$unconfirmedCount pesanan baru masuk dapur!',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFC2410C),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFDBA74)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Buka Antrean',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SECTION 3: Floating Customer Inquiries Alert Banner
  Widget _buildInquiriesAlertBanner(int unreadCount, List<dynamic> latestMessages) {
    String messageSnippet = 'Ada pertanyaan baru dari pelanggan';
    if (latestMessages.isNotEmpty) {
      final msg = latestMessages.first;
      messageSnippet = '${msg.nama}: "${msg.subjek}"';
    }

    return AnimatedPressable(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MessageListView()),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECACA)),
          boxShadow: [
            BoxShadow(
              color: AppColors.danger.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: AppColors.dangerLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_chat_unread_rounded, color: AppColors.danger, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$unreadCount Pesan Belum Dibaca',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Penting',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    messageSnippet,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  // SECTION 4: Daily Revenue Target Gauge & Performance Hero Card
  Widget _buildRevenuePerformanceHero(dynamic stats) {
    final dailyOrders = stats.totalOrders as int;
    const targetOrders = 50;
    final progress = targetOrders > 0 ? (dailyOrders / targetOrders).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFFFFBF7),
            Color(0xFFFFF7ED),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDBA74).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'KINERJA OPERASIONAL HARI INI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Ringkasan Pesanan & Dapur',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              AnimatedPressable(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Laporan harian berhasil diekspor ke PDF'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.picture_as_pdf_rounded, size: 14, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        'Unduh PDF',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gauge & KPI Split
          Row(
            children: [
              // Circular Target Gauge
              CircularTargetGauge(
                percentage: progress,
                size: 96,
                strokeWidth: 9,
                progressColor: AppColors.primary,
                centerLabel: '$percentage%',
                centerSublabel: 'Target',
              ),
              const SizedBox(width: 16),

              // KPI Stats Tiles
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Tiket', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text(
                                  '$dailyOrders Pesanan',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Menu Aktif', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text(
                                  '${stats.totalMenu} Hidangan',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.successDark),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.trending_up_rounded, size: 14, color: AppColors.success),
                              SizedBox(width: 4),
                              Text('Pertumbuhan', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                          Text(
                            '+14.8% vs Kemarin',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // SECTION 5: Live Kitchen Order Queue Slider (Horizontal Kanban Tickets)
  Widget _buildKitchenLiveQueueSection(List<OrderModel> orders) {
    List<OrderModel> filteredOrders = orders;
    if (_selectedQueueFilter == 'menunggu') {
      filteredOrders = orders.where((o) => o.status == 'menunggu_konfirmasi').toList();
    } else if (_selectedQueueFilter == 'dimasak') {
      filteredOrders = orders.where((o) => o.status == 'sedang_dimasak' || o.status == 'dikonfirmasi').toList();
    } else if (_selectedQueueFilter == 'selesai') {
      filteredOrders = orders.where((o) => o.status == 'selesai').toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const PulsingDot(color: AppColors.primary, size: 7),
                const SizedBox(width: 8),
                const Text(
                  'Kitchen Live Queue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${orders.length} Tiket',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderListView()),
                );
              },
              child: const Row(
                children: [
                  Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Filter Pills Carousel
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _queueFilterPill('semua', 'Semua (${orders.length})'),
              const SizedBox(width: 8),
              _queueFilterPill('menunggu', 'Menunggu Konfirmasi (${orders.where((o) => o.status == 'menunggu_konfirmasi').length})'),
              const SizedBox(width: 8),
              _queueFilterPill('dimasak', 'Sedang Dimasak (${orders.where((o) => o.status == 'sedang_dimasak' || o.status == 'dikonfirmasi').length})'),
              const SizedBox(width: 8),
              _queueFilterPill('selesai', 'Selesai (${orders.where((o) => o.status == 'selesai').length})'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Swipeable Tickets Slider
        if (filteredOrders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                'Tidak ada tiket pesanan pada antrean ini.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          )
        else
          SizedBox(
            height: 295,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filteredOrders.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return _buildQueueTicketCard(order);
              },
            ),
          ),
      ],
    );
  }

  Widget _queueFilterPill(String key, String label) {
    final isSelected = _selectedQueueFilter == key;
    return AnimatedPressable(
      onTap: () {
        setState(() {
          _selectedQueueFilter = key;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.secondary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildQueueTicketCard(OrderModel order) {
    final isPending = order.status == 'menunggu_konfirmasi';
    final isCooking = order.status == 'dikonfirmasi' || order.status == 'sedang_dimasak';
    final timeStr = order.createdAt != null
        ? Formatters.formatTime(order.createdAt!)
        : 'Hari ini';

    return Container(
      width: 290,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPending ? const Color(0xFFFDBA74) : AppColors.border,
          width: isPending ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPending
                ? AppColors.primary.withValues(alpha: 0.08)
                : const Color(0xFF1E293B).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Ticket Header
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
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 13, color: AppColors.textMuted),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: order.orderCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kode disalin'), duration: Duration(seconds: 1)),
                      );
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    timeStr,
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 6),
                  StatusBadge(status: order.status),
                ],
              ),
            ],
          ),

          // Customer info snippet
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  order.namaPelanggan.isNotEmpty ? order.namaPelanggan[0].toUpperCase() : 'P',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.namaPelanggan,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Items preview container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: order.items.isEmpty
                  ? [
                      const Text(
                        '1x Menu Pesanan Utama',
                        style: TextStyle(fontSize: 11, color: AppColors.textPrimary),
                      ),
                    ]
                  : order.items.take(2).map((it) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.5),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${it.jumlah}x',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                it.namaMenu,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
            ),
          ),

          // Customer Note if any
          if (order.catatan != null && order.catatan!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_note_rounded, size: 14, color: Color(0xFFB45309)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Catatan: "${order.catatan}"',
                      style: const TextStyle(fontSize: 10, color: Color(0xFFB45309), fontStyle: FontStyle.italic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Total Price & Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.tipePembayaran == 'cash' ? 'Tunai (COD)' : 'QRIS / Bank',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              Text(
                order.formattedTotal,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),

          // Action Button Row
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: AnimatedPressable(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OrderDetailView(order: order)),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Rincian', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: AnimatedPressable(
                    onTap: () => _quickAcceptOrder(order.id),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.soup_kitchen_rounded, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Terima & Masak', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          else if (isCooking)
            AnimatedPressable(
              onTap: () => _quickCookOrder(order.id),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF047857)),
                    SizedBox(width: 4),
                    Text('Tandai Siap Saji', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF047857))),
                  ],
                ),
              ),
            )
          else
            AnimatedPressable(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OrderDetailView(order: order)),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Lihat Detail Tiket', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
            ),
        ],
      ),
    );
  }

  // SECTION 6: Food Menu Quick Inventory & Stock Manager (Direct interactive toggle)
  Widget _buildQuickInventorySection(MenuViewModel menuVm) {
    final topMenus = menuVm.menus.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Stok & Ketersediaan Menu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Kelola stok langsung saat jam sibuk dapur',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  tooltip: 'Tambah Menu',
                  icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MenuFormView()),
                    );
                  },
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MenuListView()),
                    );
                  },
                  child: const Text(
                    'Katalog Penuh',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (topMenus.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text('Belum ada menu yang terdaftar', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
          )
        else
          Column(
            children: topMenus.map((menu) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    AppCachedImage(
                      imageUrl: menu.imageUrl ?? '',
                      width: 48,
                      height: 48,
                      borderRadius: BorderRadius.circular(10),
                      fallbackIcon: Icons.fastfood_rounded,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            menu.nama,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                menu.formattedHarga,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: menu.isTersedia ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  menu.isTersedia ? 'Tersedia' : 'Habis',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: menu.isTersedia ? const Color(0xFF16A34A) : AppColors.danger,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: menu.isTersedia,
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primaryLight,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: const Color(0xFFE2E8F0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (_) {
                        menuVm.toggleAvailability(menu);
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // SECTION 7: Recent Customer Inquiries
  Widget _buildRecentCustomerInquiries(dynamic stats) {
    final messages = stats.latestMessages as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pertanyaan Pelanggan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MessageListView()),
                );
              },
              child: const Text('Buka Pesan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (messages.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text('Belum ada pesan pelanggan baru', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
          )
        else
          Column(
            children: messages.take(3).map<Widget>((msg) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: msg.isUnread ? const Color(0xFFFECACA) : AppColors.border),
                ),
                child: AnimatedPressable(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MessageDetailView(message: msg)),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: msg.isUnread ? AppColors.dangerLight : const Color(0xFFF1F5F9),
                          child: Icon(
                            Icons.mail_rounded,
                            size: 16,
                            color: msg.isUnread ? AppColors.danger : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      msg.nama,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: msg.isUnread ? FontWeight.w800 : FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (msg.isUnread)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.dangerLight,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('Baru', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.danger)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                msg.subjek,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
