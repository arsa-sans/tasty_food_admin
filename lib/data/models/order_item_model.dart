import '../../core/utils/formatters.dart';

class OrderItemModel {
  final int id;
  final int orderId;
  final int? menuId;
  final String namaMenu;
  final double harga;
  final int jumlah;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.orderId,
    this.menuId,
    required this.namaMenu,
    required this.harga,
    required this.jumlah,
    required this.subtotal,
  });

  String get formattedSubtotal => Formatters.formatRupiah(subtotal);

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      orderId: json['order_id'] is int ? json['order_id'] : int.tryParse(json['order_id']?.toString() ?? '0') ?? 0,
      menuId: json['menu_id'] != null ? (json['menu_id'] is int ? json['menu_id'] : int.tryParse(json['menu_id'].toString())) : null,
      namaMenu: json['nama_menu']?.toString() ?? '',
      harga: (json['harga'] is num) ? (json['harga'] as num).toDouble() : double.tryParse(json['harga']?.toString() ?? '0') ?? 0.0,
      jumlah: json['jumlah'] is int ? json['jumlah'] : int.tryParse(json['jumlah']?.toString() ?? '1') ?? 1,
      subtotal: (json['subtotal'] is num) ? (json['subtotal'] as num).toDouble() : double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'menu_id': menuId,
      'nama_menu': namaMenu,
      'harga': harga,
      'jumlah': jumlah,
      'subtotal': subtotal,
    };
  }
}
