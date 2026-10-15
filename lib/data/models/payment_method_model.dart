class PaymentMethodModel {
  final int id;
  final String nama;
  final String tipe; // cash, e_wallet, bank
  final String? nomorRekening;
  final String? atasNama;
  final String? instruksi;
  final String? gambar;
  final String? gambarUrl;
  final bool isAktif;

  PaymentMethodModel({
    required this.id,
    required this.nama,
    required this.tipe,
    this.nomorRekening,
    this.atasNama,
    this.instruksi,
    this.gambar,
    this.gambarUrl,
    this.isAktif = true,
  });

  String get tipeLabel {
    switch (tipe) {
      case 'cash':
        return 'Tunai (COD)';
      case 'e_wallet':
        return 'E-Wallet / QRIS';
      case 'bank':
        return 'Transfer Bank';
      default:
        return tipe;
    }
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nama: json['nama']?.toString() ?? '',
      tipe: json['tipe']?.toString() ?? 'cash',
      nomorRekening: json['nomor_rekening']?.toString(),
      atasNama: json['atas_nama']?.toString(),
      instruksi: json['instruksi']?.toString(),
      gambar: json['gambar']?.toString(),
      gambarUrl: json['gambar_url']?.toString(),
      isAktif: json['is_aktif'] == 1 || json['is_aktif'] == true || json['is_aktif'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'tipe': tipe,
      'nomor_rekening': nomorRekening,
      'atas_nama': atasNama,
      'instruksi': instruksi,
      'gambar': gambar,
      'gambar_url': gambarUrl,
      'is_aktif': isAktif,
    };
  }

  PaymentMethodModel copyWith({
    int? id,
    String? nama,
    String? tipe,
    String? nomorRekening,
    String? atasNama,
    String? instruksi,
    String? gambar,
    String? gambarUrl,
    bool? isAktif,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      tipe: tipe ?? this.tipe,
      nomorRekening: nomorRekening ?? this.nomorRekening,
      atasNama: atasNama ?? this.atasNama,
      instruksi: instruksi ?? this.instruksi,
      gambar: gambar ?? this.gambar,
      gambarUrl: gambarUrl ?? this.gambarUrl,
      isAktif: isAktif ?? this.isAktif,
    );
  }
}
