import 'package:flutter/material.dart';
import '../data/models/galeri_model.dart';
import '../data/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class GaleriViewModel extends ChangeNotifier {
  final ApiService _api;

  GaleriViewModel(this._api);

  bool _isLoading = false;
  String? _errorMessage;
  List<GaleriModel> _galeris = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<GaleriModel> get galeris => _galeris;

  Future<void> fetchGaleris() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get(ApiConstants.galeris);
      List<GaleriModel> list = [];

      if (response is List) {
        list = response.map((g) => GaleriModel.fromJson(g as Map<String, dynamic>)).toList();
      } else if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          list = data.map((g) => GaleriModel.fromJson(g as Map<String, dynamic>)).toList();
        }
      }

      _galeris = list;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _galeris = [
        GaleriModel(id: 1, judul: 'Suasana Restoran Cozy', deskripsi: 'Interior bernuansa modern minimalis dan nyaman'),
        GaleriModel(id: 2, judul: 'Dapur Higienis & Bersih', deskripsi: 'Koki profesional dengan standar higienis tinggi'),
        GaleriModel(id: 3, judul: 'Meja Makan Outdoor', deskripsi: 'Area santai dengan tanaman hijau segar'),
        GaleriModel(id: 4, judul: 'Penyajian Hidangan Istimewa', deskripsi: 'Plating menarik dengan bahan pilihan segar'),
      ];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveGaleri({
    int? id,
    required String judul,
    String? deskripsi,
    String? imagePath,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fields = {
        'judul': judul,
        'deskripsi': deskripsi ?? '',
      };

      if (id != null) {
        await _api.multipartRequest(
          method: 'POST',
          endpoint: '${ApiConstants.galeris}/$id',
          fields: {...fields, '_method': 'PUT'},
          fileField: 'image',
          filePath: imagePath,
        );
      } else {
        await _api.multipartRequest(
          method: 'POST',
          endpoint: ApiConstants.galeris,
          fields: fields,
          fileField: 'image',
          filePath: imagePath,
        );
      }

      await fetchGaleris();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGaleri(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.delete('${ApiConstants.galeris}/$id');
      _galeris.removeWhere((g) => g.id == id);
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
