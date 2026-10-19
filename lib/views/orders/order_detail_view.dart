import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/order_model.dart';
import '../../viewmodels/order_viewmodel.dart';

class OrderDetailView extends StatefulWidget {
  final OrderModel order;

  const OrderDetailView({super.key, required this.order});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  late OrderModel _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  void _showUpdateStatusModal() {
    String selectedStatus = _currentOrder.status;
    final noteController = TextEditingController(text: _currentOrder.keteranganAdmin ?? '');

    final statuses = [
      {'val': 'menunggu_konfirmasi', 'label': 'Menunggu Konfirmasi'},
      {'val': 'dikonfirmasi', 'label': 'Pesanan Dikonfirmasi'},
      {'val': 'sedang_dimasak', 'label': 'Sedang Dimasak'},
      {'val': 'dalam_pengiriman', 'label': 'Dalam Pengiriman (Kurir)'},
      {'val': 'selesai', 'label': 'Telah Sampai / Selesai'},
      {'val': 'dibatalkan', 'label': 'Pesanan Dibatalkan'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Perbarui Status Pesanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(labelText: 'Pilih Status'),
                items: statuses.map((s) {
                  return DropdownMenuItem(
                    value: s['val'],
                    child: Text(s['label']!),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() {
                      selectedStatus = val;
                      if (val == 'dikonfirmasi') {
                        noteController.text = 'Pesanan telah dikonfirmasi dan masuk antrean dapur.';
                      } else if (val == 'sedang_dimasak') {
                        noteController.text = 'Makanan sedang disiapkan dan dimasak oleh koki.';
                      } else if (val == 'dalam_pengiriman') {
                        noteController.text = 'Makanan dalam perjalanan diantar oleh kurir ke lokasi Anda.';
                      } else if (val == 'selesai') {
                        noteController.text = 'Pesanan telah sampai dan diterima dengan baik. Selamat menikmati!';
                      } else if (val == 'dibatalkan') {
                        noteController.text = 'Pesanan dibatalkan.';
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Keterangan Tambahan untuk Pelanggan',
                  hintText: 'Tulis pesan atau info pengantaran...',
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Simpan Perubahan',
                icon: Icons.check_circle_outline,
                onPressed: () async {
                  final orderVm = context.read<OrderViewModel>();
                  Navigator.pop(ctx);
                  final success = await orderVm.updateOrderStatus(
                    _currentOrder.id,
                    selectedStatus,
                    noteController.text.trim(),
                  );
                  if (success && mounted) {
                    setState(() {
                      _currentOrder = orderVm.selectedOrder ?? _currentOrder;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Status pesanan berhasil diperbarui!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdatePaymentModal() {
    String selectedPaymentStatus = _currentOrder.statusPembayaran;

    final statuses = [
      {'val': 'belum_bayar', 'label': 'Belum Bayar'},
      {'val': 'menunggu_verifikasi', 'label': 'Menunggu Verifikasi'},
      {'val': 'lunas', 'label': 'Lunas'},
      {'val': 'ditolak', 'label': 'Bukti Ditolak'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Perbarui Status Pembayaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              RadioGroup<String>(
                groupValue: selectedPaymentStatus,
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() => selectedPaymentStatus = val);
                  }
                },
                child: Column(
                  children: statuses.map((s) {
                    return RadioListTile<String>(
                      title: Text(s['label']!),
                      value: s['val']!,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Simpan Status Pembayaran',
                onPressed: () async {
                  final orderVm = context.read<OrderViewModel>();
                  Navigator.pop(ctx);
                  final success = await orderVm.updatePaymentStatus(
                    _currentOrder.id,
                    selectedPaymentStatus,
                  );
                  if (success && mounted) {
                    setState(() {
                      _currentOrder = orderVm.selectedOrder ?? _currentOrder;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Status pembayaran berhasil diperbarui!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pesanan?'),
        content: Text('Apakah Anda yakin ingin menghapus pesanan ${_currentOrder.orderCode}? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<OrderViewModel>().deleteOrder(_currentOrder.id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pesanan berhasil dihapus'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentOrder.orderCode),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            tooltip: 'Hapus Pesanan',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status Pesanan Saat Ini',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        StatusBadge(status: _currentOrder.status),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status Pembayaran',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        StatusBadge(
                          status: _currentOrder.statusPembayaran,
                          type: BadgeType.paymentStatus,
                        ),
                      ],
                    ),
                    if (_currentOrder.keteranganAdmin != null) ...[
                      const Divider(height: 20),
                      Text(
                        'Keterangan: ${_currentOrder.keteranganAdmin}',
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Quick Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showUpdateStatusModal,
                    icon: const Icon(Icons.sync_alt_rounded, size: 18),
                    label: const Text('Ubah Status'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showUpdatePaymentModal,
                    icon: const Icon(Icons.price_check_rounded, size: 18),
                    label: const Text('Status Bayar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Customer Info Card
            const Text(
              'Informasi Pelanggan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(Icons.person, 'Nama Pelanggan', _currentOrder.namaPelanggan),
                    const Divider(height: 16),
                    _infoRow(Icons.phone, 'Nomor Telepon', _currentOrder.telepon),
                    if (_currentOrder.email != null) ...[
                      const Divider(height: 16),
                      _infoRow(Icons.email, 'Email', _currentOrder.email!),
                    ],
                    const Divider(height: 16),
                    _infoRow(Icons.location_on, 'Alamat Antar', _currentOrder.alamatLengkap),
                    if (_currentOrder.catatan != null && _currentOrder.catatan!.isNotEmpty) ...[
                      const Divider(height: 16),
                      _infoRow(Icons.note, 'Catatan Khusus', _currentOrder.catatan!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Ordered Menu Items Card
            const Text(
              'Daftar Menu Pesanan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_currentOrder.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Data rincian item tidak tersedia'),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _currentOrder.items.length,
                        separatorBuilder: (_, __) => const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final item = _currentOrder.items[index];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.namaMenu,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                    Text(
                                      '${Formatters.formatRupiah(item.harga)} x ${item.jumlah}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                Formatters.formatRupiah(item.subtotal),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          );
                        },
                      ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Akhir',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          _currentOrder.formattedTotal,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Details Card
            const Text(
              'Detail Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(
                      Icons.payment,
                      'Metode Pembayaran',
                      _currentOrder.metodePembayaran ?? 'Tunai (COD)',
                    ),
                    if (_currentOrder.buktiPembayaranUrl != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Bukti Pembayaran Pelanggan:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: _currentOrder.buktiPembayaranUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: 180,
                            color: AppColors.surfaceVariant,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 100,
                            color: AppColors.surfaceVariant,
                            child: const Center(
                              child: Text('Bukti pembayaran tidak dapat dimuat'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
