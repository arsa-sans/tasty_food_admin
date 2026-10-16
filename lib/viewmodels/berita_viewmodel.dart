import 'package:flutter/material.dart';
import '../data/models/berita_model.dart';
import '../data/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class BeritaViewModel extends ChangeNotifier {
  final ApiService _api;

  BeritaViewModel(this._api);

  bool _isLoading = false;
  String? _errorMessage;
  List<BeritaModel> _beritas = [];
  String _statusFilter = 'Semua';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get statusFilter => _statusFilter;

  List<BeritaModel> get filteredBeritas {
    if (_statusFilter == 'Semua') return _beritas;
    return _beritas.where((b) => b.status == _statusFilter.toLowerCase()).toList();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  Future<void> fetchBeritas() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get(ApiConstants.beritas);
      List<BeritaModel> list = [];

      if (response is List) {
        list = response.map((b) => BeritaModel.fromJson(b as Map<String, dynamic>)).toList();
      } else if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          list = data.map((b) => BeritaModel.fromJson(b as Map<String, dynamic>)).toList();
        }
      }

      _beritas = list;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _beritas = [
        BeritaModel(
          id: 1,
          judul: 'Mie Ayam, Kuliner Sederhana yang Dicintai Semua Orang',
          slug: 'mie-ayam-kuliner-sederhana-yang-dicintai-semua-orang',
          konten: 'Mie ayam menjadi salah satu kuliner yang tetap populer di tengah banyaknya makanan modern...',
          status: 'published',
          tanggal: DateTime.parse('2026-07-26'),
        ),
        BeritaModel(
          id: 2,
          judul: 'Opor Ayam, Kelezatan Kuah Santan Berbumbu Rempah dan Makna Tradisi',
          slug: 'opor-ayam-kelezatan-kuah-santan-berbumbu-rempah',
          konten: 'Di balik semaraknya perayaan Hari Raya di Indonesia, aroma harum hidangan hangat selalu menyertai...',
          status: 'published',
          tanggal: DateTime.parse('2026-07-25'),
        ),
        BeritaModel(
          id: 3,
          judul: 'Menjelajahi Nasi Goreng: Sejarah dan Ragam Kuliner Favorit Dunia',
          slug: 'menjelajahi-nasi-goreng-sejarah-dan-ragam-kuliner-favorit-dunia',
          konten: 'Nasi goreng bukan sekadar makanan pengisi perut di kala lapar...',
          status: 'published',
          tanggal: DateTime.parse('2026-07-25'),
        ),
      ];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveBerita({
    int? id,
    required String judul,
    required String konten,
    required String status,
    required DateTime tanggal,
    String? imagePath,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fields = {
        'judul': judul,
        'konten': konten,
        'status': status,
        'tanggal': tanggal.toIso8601String().split('T').first,
      };

      if (id != null) {
        await _api.multipartRequest(
          method: 'POST',
          endpoint: '${ApiConstants.beritas}/$id',
          fields: {...fields, '_method': 'PUT'},
          fileField: 'image',
          filePath: imagePath,
        );
      } else {
        await _api.multipartRequest(
          method: 'POST',
          endpoint: ApiConstants.beritas,
          fields: fields,
          fileField: 'image',
          filePath: imagePath,
        );
      }

      await fetchBeritas();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBerita(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.delete('${ApiConstants.beritas}/$id');
      _beritas.removeWhere((b) => b.id == id);
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
