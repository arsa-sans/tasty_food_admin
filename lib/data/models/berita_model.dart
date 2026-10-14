import '../../core/utils/formatters.dart';

class BeritaModel {
  final int id;
  final String? image;
  final String? imageUrl;
  final String judul;
  final String slug;
  final String konten;
  final String status; // draft, published
  final DateTime? tanggal;

  BeritaModel({
    required this.id,
    this.image,
    this.imageUrl,
    required this.judul,
    required this.slug,
    required this.konten,
    required this.status,
    this.tanggal,
  });

  bool get isPublished => status == 'published';
  String get formattedDate => Formatters.formatDate(tanggal);

  String get ringkasan {
    if (konten.isEmpty) return '';
    return konten.length > 90 ? '${konten.substring(0, 90)}...' : konten;
  }

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    return BeritaModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      image: json['image']?.toString(),
      imageUrl: json['image_url']?.toString(),
      judul: json['judul']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      konten: json['konten']?.toString() ?? '',
      status: json['status']?.toString() ?? 'published',
      tanggal: Formatters.parseDate(json['tanggal']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'image_url': imageUrl,
      'judul': judul,
      'slug': slug,
      'konten': konten,
      'status': status,
      'tanggal': tanggal?.toIso8601String(),
    };
  }
}
