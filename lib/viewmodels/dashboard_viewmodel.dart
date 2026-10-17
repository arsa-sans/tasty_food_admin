import 'package:flutter/material.dart';
import '../data/models/dashboard_stats_model.dart';
import '../data/models/order_model.dart';
import '../data/models/galeri_model.dart';
import '../data/models/message_model.dart';
import '../data/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class DashboardViewModel extends ChangeNotifier {
  final ApiService _api;

  DashboardViewModel(this._api);

  bool _isLoading = false;
  String? _errorMessage;
  DashboardStatsModel _stats = DashboardStatsModel();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DashboardStatsModel get stats => _stats;

  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get(ApiConstants.dashboard);

      if (response is Map<String, dynamic>) {
        _stats = DashboardStatsModel.fromJson(response);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Fallback sample data matching Laravel DatabaseSeeder / db_tasty_food.sql
      // This allows immediate preview even when offline or before backend API is running
      _stats = DashboardStatsModel(
        totalBerita: 8,
        totalGaleri: 6,
        unreadMessagesCount: 3,
        totalMenu: 10,
        totalOrders: 10,
        unconfirmedOrdersCount: 2,
        latestOrders: [
          OrderModel(
            id: 10,
            orderCode: 'TF-20261007-ES4JQ',
            namaPelanggan: 'Arsa Prayata',
            telepon: '08516114767',
            alamatLengkap: 'Dormi CyberLabs, Jl Terusan Mars Utara',
            totalHarga: 280000,
            status: 'selesai',
            statusPembayaran: 'lunas',
            metodePembayaran: 'Dana',
            tipePembayaran: 'e_wallet',
            createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          ),
          OrderModel(
            id: 9,
            orderCode: 'TF-20261007-4KKSY',
            namaPelanggan: 'Budi Santoso',
            telepon: '08123456789',
            alamatLengkap: 'Jl. R.E. Martadinata No. 45, Cianjur',
            totalHarga: 152000,
            status: 'menunggu_konfirmasi',
            statusPembayaran: 'menunggu_verifikasi',
            metodePembayaran: 'QRIS',
            tipePembayaran: 'e_wallet',
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          ),
          OrderModel(
            id: 8,
            orderCode: 'TF-20261007-Y0SRU',
            namaPelanggan: 'Siti Rahma',
            telepon: '08781234567',
            alamatLengkap: 'Komplek Perumahan Indah Blok B2',
            totalHarga: 228000,
            status: 'dalam_pengiriman',
            statusPembayaran: 'lunas',
            metodePembayaran: 'Transfer BCA',
            tipePembayaran: 'bank',
            createdAt: DateTime.now().subtract(const Duration(hours: 7)),
          ),
        ],
        latestGaleri: [
          GaleriModel(id: 1, judul: 'Suasana Restoran Cozy', deskripsi: 'Interior bernuansa modern minimalis'),
          GaleriModel(id: 2, judul: 'Dapur Higienis & Bersih', deskripsi: 'Standar kebersihan bintang lima'),
        ],
        latestMessages: [
          MessageModel(
            id: 1,
            nama: 'Bunga Citra',
            email: 'bunga@gmail.com',
            subjek: 'Pemesanan Menu Katering Prasmanan',
            pesan: 'Halo Tasty Food, apakah restoran menyediakan paket katering nasi kotak dan prasmanan untuk acara syukuran kantor 50 porsi?',
            status: 'belum_dibaca',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          MessageModel(
            id: 2,
            nama: 'Ikmal Ramadhan',
            email: 'ikmal@gmail.com',
            subjek: 'Reservasi Meja Makan Keluarga',
            pesan: 'Halo admin, saya ingin reservasi meja untuk 8 orang di akhir pekan ini jam 19.00.',
            status: 'belum_dibaca',
            createdAt: DateTime.now().subtract(const Duration(hours: 4)),
          ),
        ],
      );
      _isLoading = false;
      notifyListeners();
    }
  }
}
