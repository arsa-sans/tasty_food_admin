import '../../core/utils/formatters.dart';

class MessageModel {
  final int id;
  final String nama;
  final String email;
  final String subjek;
  final String pesan;
  final String status; // belum_dibaca, dibaca
  final DateTime? createdAt;

  MessageModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.subjek,
    required this.pesan,
    required this.status,
    this.createdAt,
  });

  bool get isUnread => status == 'belum_dibaca';
  String get formattedDate => Formatters.formatDateTime(createdAt);

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nama: json['nama']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      subjek: json['subjek']?.toString() ?? '',
      pesan: json['pesan']?.toString() ?? '',
      status: json['status']?.toString() ?? 'belum_dibaca',
      createdAt: Formatters.parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'subjek': subjek,
      'pesan': pesan,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  MessageModel copyWith({
    int? id,
    String? nama,
    String? email,
    String? subjek,
    String? pesan,
    String? status,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      subjek: subjek ?? this.subjek,
      pesan: pesan ?? this.pesan,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
