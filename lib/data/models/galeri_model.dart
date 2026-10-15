class GaleriModel {
  final int id;
  final String? image;
  final String? imageUrl;
  final String judul;
  final String? deskripsi;

  GaleriModel({
    required this.id,
    this.image,
    this.imageUrl,
    required this.judul,
    this.deskripsi,
  });

  factory GaleriModel.fromJson(Map<String, dynamic> json) {
    return GaleriModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      image: json['image']?.toString(),
      imageUrl: json['image_url']?.toString(),
      judul: json['judul']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'image_url': imageUrl,
      'judul': judul,
      'deskripsi': deskripsi,
    };
  }
}
