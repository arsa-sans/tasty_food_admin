import 'order_item_model.dart';
import '../../core/utils/formatters.dart';

class OrderModel {
  final int id;
  final int? userId;
  final String orderCode;
  final String namaPelanggan;
  final String telepon;
  final String? email;
  final String alamatLengkap;
  final double? latitude;
  final double? longitude;
  final String? catatan;
  final double totalHarga;
  final String status;
  final String? keteranganAdmin;
  final int? paymentMethodId;
  final String? metodePembayaran;
  final String? tipePembayaran;
  final String? buktiPembayaran;
  final String? buktiPembayaranUrl;
  final String statusPembayaran;
  final int? rating;
  final String? ulasan;
  final bool isDiterima;
  final DateTime? diterimaAt;
  final DateTime? createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    this.userId,
    required this.orderCode,
    required this.namaPelanggan,
    required this.telepon,
    this.email,
    required this.alamatLengkap,
    this.latitude,
    this.longitude,
    this.catatan,
    required this.totalHarga,
    required this.status,
    this.keteranganAdmin,
    this.paymentMethodId,
    this.metodePembayaran,
    this.tipePembayaran,
    this.buktiPembayaran,
    this.buktiPembayaranUrl,
    required this.statusPembayaran,
    this.rating,
    this.ulasan,
    this.isDiterima = false,
    this.diterimaAt,
    this.createdAt,
    this.items = const [],
  });

  String get statusLabel {
    switch (status) {
      case 'menunggu_konfirmasi':
        return 'Menunggu Konfirmasi';
      case 'dikonfirmasi':
        return 'Pesanan Dikonfirmasi';
      case 'sedang_dimasak':
        return 'Sedang Dimasak';
      case 'dalam_pengiriman':
        return 'Dalam Pengiriman';
      case 'selesai':
        return 'Telah Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String get statusPembayaranLabel {
    switch (statusPembayaran) {
      case 'lunas':
        return 'Lunas';
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi';
      case 'ditolak':
        return 'Ditolak';
      case 'belum_bayar':
      default:
        return 'Belum Bayar';
    }
  }

  String get formattedTotal => Formatters.formatRupiah(totalHarga);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'];
    List<OrderItemModel> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems
          .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] != null ? (json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString())) : null,
      orderCode: json['order_code']?.toString() ?? '',
      namaPelanggan: json['nama_pelanggan']?.toString() ?? '',
      telepon: json['telepon']?.toString() ?? '',
      email: json['email']?.toString(),
      alamatLengkap: json['alamat_lengkap']?.toString() ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      catatan: json['catatan']?.toString(),
      totalHarga: (json['total_harga'] is num) ? (json['total_harga'] as num).toDouble() : double.tryParse(json['total_harga']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'menunggu_konfirmasi',
      keteranganAdmin: json['keterangan_admin']?.toString(),
      paymentMethodId: json['payment_method_id'] != null ? int.tryParse(json['payment_method_id'].toString()) : null,
      metodePembayaran: json['metode_pembayaran']?.toString(),
      tipePembayaran: json['tipe_pembayaran']?.toString(),
      buktiPembayaran: json['bukti_pembayaran']?.toString(),
      buktiPembayaranUrl: json['bukti_pembayaran_url']?.toString(),
      statusPembayaran: json['status_pembayaran']?.toString() ?? 'belum_bayar',
      rating: json['rating'] != null ? int.tryParse(json['rating'].toString()) : null,
      ulasan: json['ulasan']?.toString(),
      isDiterima: json['is_diterima'] == 1 || json['is_diterima'] == true || json['is_diterima'] == '1',
      diterimaAt: Formatters.parseDate(json['diterima_at']),
      createdAt: Formatters.parseDate(json['created_at']),
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_code': orderCode,
      'nama_pelanggan': namaPelanggan,
      'telepon': telepon,
      'email': email,
      'alamat_lengkap': alamatLengkap,
      'latitude': latitude,
      'longitude': longitude,
      'catatan': catatan,
      'total_harga': totalHarga,
      'status': status,
      'keterangan_admin': keteranganAdmin,
      'payment_method_id': paymentMethodId,
      'metode_pembayaran': metodePembayaran,
      'tipe_pembayaran': tipePembayaran,
      'bukti_pembayaran': buktiPembayaran,
      'bukti_pembayaran_url': buktiPembayaranUrl,
      'status_pembayaran': statusPembayaran,
      'rating': rating,
      'ulasan': ulasan,
      'is_diterima': isDiterima,
      'diterima_at': diterimaAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
