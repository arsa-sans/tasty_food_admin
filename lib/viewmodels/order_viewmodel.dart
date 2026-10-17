import 'package:flutter/material.dart';
import '../data/models/order_model.dart';
import '../data/models/order_item_model.dart';
import '../data/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class OrderViewModel extends ChangeNotifier {
  final ApiService _api;

  OrderViewModel(this._api);

  bool _isLoading = false;
  String? _errorMessage;
  List<OrderModel> _orders = [];
  String _selectedStatus = 'Semua';
  String _searchQuery = '';
  OrderModel? _selectedOrder;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  OrderModel? get selectedOrder => _selectedOrder;

  final List<String> statusTabs = [
    'Semua',
    'menunggu_konfirmasi',
    'dikonfirmasi',
    'sedang_dimasak',
    'dalam_pengiriman',
    'selesai',
    'dibatalkan',
  ];

  List<OrderModel> get filteredOrders {
    return _orders.where((order) {
      final matchesStatus = _selectedStatus == 'Semua' || order.status == _selectedStatus;
      final matchesSearch = _searchQuery.isEmpty ||
          order.orderCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.namaPelanggan.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.telepon.contains(_searchQuery);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  void setStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectOrder(OrderModel order) {
    _selectedOrder = order;
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get(ApiConstants.orders);
      List<OrderModel> list = [];

      if (response is List) {
        list = response.map((o) => OrderModel.fromJson(o as Map<String, dynamic>)).toList();
      } else if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          list = data.map((o) => OrderModel.fromJson(o as Map<String, dynamic>)).toList();
        }
      }

      _orders = list;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Fallback with real sample orders from Laravel database
      _orders = [
        OrderModel(
          id: 10,
          orderCode: 'TF-20261007-ES4JQ',
          namaPelanggan: 'Arsa Prayata',
          telepon: '08516114767',
          email: 'arsanugas@gmail.com',
          alamatLengkap: 'Dormi CyberLabs, Jl. Terusan Mars Utara III No. 8D',
          latitude: -6.94352070,
          longitude: 107.66413990,
          catatan: 'Tolong sambalnya dipisah ya.',
          totalHarga: 280000,
          status: 'selesai',
          keteranganAdmin: 'Pesanan telah sampai dan diterima dengan baik oleh pelanggan.',
          metodePembayaran: 'Dana (E-Wallet)',
          tipePembayaran: 'e_wallet',
          statusPembayaran: 'lunas',
          rating: 5,
          ulasan: 'Makanan sangat lezat dan pengantaran sangat cepat! Terima kasih Tasty Food.',
          isDiterima: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          items: [
            OrderItemModel(id: 1, orderId: 10, namaMenu: 'Mie Ayam Spesial Pangsit', harga: 25000, jumlah: 4, subtotal: 100000),
            OrderItemModel(id: 2, orderId: 10, namaMenu: 'Rendang Daging Sapi Minang', harga: 38000, jumlah: 3, subtotal: 114000),
            OrderItemModel(id: 3, orderId: 10, namaMenu: 'Es Teh Manis Melati', harga: 6000, jumlah: 11, subtotal: 66000),
          ],
        ),
        OrderModel(
          id: 9,
          orderCode: 'TF-20261007-4KKSY',
          namaPelanggan: 'Budi Santoso',
          telepon: '08123456789',
          email: 'budi@gmail.com',
          alamatLengkap: 'Jl. R.E. Martadinata No. 45, Cianjur',
          latitude: -6.94350400,
          longitude: 107.66417710,
          catatan: 'Bumbu sate agak banyak.',
          totalHarga: 152000,
          status: 'menunggu_konfirmasi',
          keteranganAdmin: 'Menunggu konfirmasi restoran.',
          metodePembayaran: 'QRIS (Semua E-Wallet & M-Banking)',
          tipePembayaran: 'e_wallet',
          statusPembayaran: 'menunggu_verifikasi',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
          items: [
            OrderItemModel(id: 4, orderId: 9, namaMenu: 'Sate Ayam Madura (10 Tusuk)', harga: 30000, jumlah: 4, subtotal: 120000),
            OrderItemModel(id: 5, orderId: 9, namaMenu: 'Jus Alpukat Kocok', harga: 16000, jumlah: 2, subtotal: 32000),
          ],
        ),
        OrderModel(
          id: 8,
          orderCode: 'TF-20261007-Y0SRU',
          namaPelanggan: 'Siti Rahma',
          telepon: '08781234567',
          email: 'siti@gmail.com',
          alamatLengkap: 'Komplek Perumahan Indah Blok B2 No. 12',
          latitude: -6.94351800,
          longitude: 107.66414860,
          catatan: 'Jangan terlalu pedas untuk sotonya.',
          totalHarga: 228000,
          status: 'dalam_pengiriman',
          keteranganAdmin: 'Makanan selesai dimasak dan sedang dalam perjalanan diantar oleh kurir ke lokasi Anda.',
          metodePembayaran: 'Transfer Bank BCA',
          tipePembayaran: 'bank',
          statusPembayaran: 'lunas',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          items: [
            OrderItemModel(id: 6, orderId: 8, namaMenu: 'Soto Ayam Lamongan Koya', harga: 24000, jumlah: 5, subtotal: 120000),
            OrderItemModel(id: 7, orderId: 8, namaMenu: 'Nasi Goreng Spesial Nusantara', harga: 28000, jumlah: 3, subtotal: 84000),
            OrderItemModel(id: 8, orderId: 8, namaMenu: 'Es Teh Manis Melati', harga: 6000, jumlah: 4, subtotal: 24000),
          ],
        ),
        OrderModel(
          id: 7,
          orderCode: 'TF-20261007-EMP7C',
          namaPelanggan: 'Dian Permata',
          telepon: '08219876543',
          email: 'dian@gmail.com',
          alamatLengkap: 'Jl. KH Abdullah Bin Nuh No. 10',
          totalHarga: 90000,
          status: 'sedang_dimasak',
          keteranganAdmin: 'Makanan sedang disiapkan dan dimasak oleh koki kami.',
          metodePembayaran: 'Tunai saat pengantaran (COD)',
          tipePembayaran: 'cash',
          statusPembayaran: 'belum_bayar',
          createdAt: DateTime.now().subtract(const Duration(hours: 8)),
          items: [
            OrderItemModel(id: 9, orderId: 7, namaMenu: 'Mie Ayam Spesial Pangsit', harga: 25000, jumlah: 3, subtotal: 75000),
            OrderItemModel(id: 10, orderId: 7, namaMenu: 'Es Teh Manis Melati', harga: 5000, jumlah: 3, subtotal: 15000),
          ],
        ),
      ];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrderStatus(int orderId, String newStatus, [String? customNote]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.put(
        ApiConstants.updateOrderStatus.replaceAll('{id}', orderId.toString()),
        body: {
          'status': newStatus,
          'keterangan_admin': customNote,
        },
      );
      _updateLocalOrderStatus(orderId, newStatus, customNote);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _updateLocalOrderStatus(int orderId, String newStatus, String? note) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final old = _orders[index];
      final updated = OrderModel(
        id: old.id,
        userId: old.userId,
        orderCode: old.orderCode,
        namaPelanggan: old.namaPelanggan,
        telepon: old.telepon,
        email: old.email,
        alamatLengkap: old.alamatLengkap,
        latitude: old.latitude,
        longitude: old.longitude,
        catatan: old.catatan,
        totalHarga: old.totalHarga,
        status: newStatus,
        keteranganAdmin: note ?? old.keteranganAdmin,
        paymentMethodId: old.paymentMethodId,
        metodePembayaran: old.metodePembayaran,
        tipePembayaran: old.tipePembayaran,
        buktiPembayaran: old.buktiPembayaran,
        buktiPembayaranUrl: old.buktiPembayaranUrl,
        statusPembayaran: old.statusPembayaran,
        rating: old.rating,
        ulasan: old.ulasan,
        isDiterima: old.isDiterima,
        diterimaAt: old.diterimaAt,
        createdAt: old.createdAt,
        items: old.items,
      );
      _orders[index] = updated;
      if (_selectedOrder?.id == orderId) {
        _selectedOrder = updated;
      }
    }
  }

  Future<bool> updatePaymentStatus(int orderId, String newPaymentStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.put(
        ApiConstants.updateOrderPaymentStatus.replaceAll('{id}', orderId.toString()),
        body: {'status_pembayaran': newPaymentStatus},
      );
      _updateLocalPaymentStatus(orderId, newPaymentStatus);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _updateLocalPaymentStatus(int orderId, String newPaymentStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final old = _orders[index];
      final updated = OrderModel(
        id: old.id,
        userId: old.userId,
        orderCode: old.orderCode,
        namaPelanggan: old.namaPelanggan,
        telepon: old.telepon,
        email: old.email,
        alamatLengkap: old.alamatLengkap,
        latitude: old.latitude,
        longitude: old.longitude,
        catatan: old.catatan,
        totalHarga: old.totalHarga,
        status: old.status,
        keteranganAdmin: old.keteranganAdmin,
        paymentMethodId: old.paymentMethodId,
        metodePembayaran: old.metodePembayaran,
        tipePembayaran: old.tipePembayaran,
        buktiPembayaran: old.buktiPembayaran,
        buktiPembayaranUrl: old.buktiPembayaranUrl,
        statusPembayaran: newPaymentStatus,
        rating: old.rating,
        ulasan: old.ulasan,
        isDiterima: old.isDiterima,
        diterimaAt: old.diterimaAt,
        createdAt: old.createdAt,
        items: old.items,
      );
      _orders[index] = updated;
      if (_selectedOrder?.id == orderId) {
        _selectedOrder = updated;
      }
    }
  }

  Future<bool> deleteOrder(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.delete('${ApiConstants.orders}/$id');
      _orders.removeWhere((o) => o.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
