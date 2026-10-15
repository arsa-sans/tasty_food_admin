import '../../core/utils/formatters.dart';

class MenuModel {
  final int id;
  final String nama;
  final String slug;
  final String kategori;
  final double harga;
  final String? deskripsi;
  final String? image;
  final String? imageUrl;
  final bool isTersedia;
  final DateTime? createdAt;

  MenuModel({
    required this.id,
    required this.nama,
    required this.slug,
    required this.kategori,
    required this.harga,
    this.deskripsi,
    this.image,
    this.imageUrl,
    this.isTersedia = true,
    this.createdAt,
  });

  String get formattedHarga => Formatters.formatRupiah(harga);

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nama: json['nama']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? 'Makanan',
      harga: (json['harga'] is num) ? (json['harga'] as num).toDouble() : double.tryParse(json['harga']?.toString() ?? '0') ?? 0.0,
      deskripsi: json['deskripsi']?.toString(),
      image: json['image']?.toString(),
      imageUrl: json['image_url']?.toString(),
      isTersedia: json['is_tersedia'] == 1 || json['is_tersedia'] == true || json['is_tersedia'] == '1',
      createdAt: Formatters.parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'slug': slug,
      'kategori': kategori,
      'harga': harga,
      'deskripsi': deskripsi,
      'image': image,
      'image_url': imageUrl,
      'is_tersedia': isTersedia,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  MenuModel copyWith({
    int? id,
    String? nama,
    String? slug,
    String? kategori,
    double? harga,
    String? deskripsi,
    String? image,
    String? imageUrl,
    bool? isTersedia,
    DateTime? createdAt,
  }) {
    return MenuModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      slug: slug ?? this.slug,
      kategori: kategori ?? this.kategori,
      harga: harga ?? this.harga,
      deskripsi: deskripsi ?? this.deskripsi,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      isTersedia: isTersedia ?? this.isTersedia,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
