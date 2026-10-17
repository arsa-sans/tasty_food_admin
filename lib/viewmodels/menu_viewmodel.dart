import 'package:flutter/material.dart';
import '../data/models/menu_model.dart';
import '../data/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class MenuViewModel extends ChangeNotifier {
  final ApiService _api;

  MenuViewModel(this._api);

  bool _isLoading = false;
  String? _errorMessage;
  List<MenuModel> _menus = [];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<MenuModel> get menus => _menus;

  List<String> get categories {
    final cats = _menus.map((m) => m.kategori).toSet().toList();
    cats.sort();
    return ['Semua', ...cats];
  }

  List<MenuModel> get filteredMenus {
    return _menus.where((menu) {
      final matchesCategory = _selectedCategory == 'Semua' ||
          menu.kategori.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          menu.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          menu.kategori.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchMenus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get(ApiConstants.menus);
      List<MenuModel> list = [];

      if (response is List) {
        list = response.map((m) => MenuModel.fromJson(m as Map<String, dynamic>)).toList();
      } else if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          list = data.map((m) => MenuModel.fromJson(m as Map<String, dynamic>)).toList();
        }
      }

      _menus = list;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Fallback with real sample menus from Tasty Food database
      _menus = [
        MenuModel(
          id: 1,
          nama: 'Mie Ayam Spesial Pangsit',
          slug: 'mie-ayam-spesial-pangsit',
          kategori: 'Makanan Utama',
          harga: 25000,
          deskripsi: 'Mie kenyal dengan ayam semur gurih manis, sawi segar, dan pangsit renyah.',
          isTersedia: true,
        ),
        MenuModel(
          id: 2,
          nama: 'Nasi Goreng Spesial Nusantara',
          slug: 'nasi-goreng-spesial-nusantara',
          kategori: 'Makanan Utama',
          harga: 28000,
          deskripsi: 'Nasi goreng harum rempah dengan potongan ayam, telur mata sapi, dan acar segar.',
          isTersedia: true,
        ),
        MenuModel(
          id: 3,
          nama: 'Sate Ayam Madura (10 Tusuk)',
          slug: 'sate-ayam-madura',
          kategori: 'Makanan Utama',
          harga: 30000,
          deskripsi: 'Daging ayam empuk dengan baluran bumbu kacang kental dan lontong.',
          isTersedia: true,
        ),
        MenuModel(
          id: 4,
          nama: 'Rendang Daging Sapi Minang',
          slug: 'rendang-daging-sapi-minang',
          kategori: 'Makanan Utama',
          harga: 38000,
          deskripsi: 'Daging sapi empuk dimasak perlahan dengan santan kental dan rempah pilihan.',
          isTersedia: true,
        ),
        MenuModel(
          id: 5,
          nama: 'Soto Ayam Lamongan Koya',
          slug: 'soto-ayam-lamongan-koya',
          kategori: 'Makanan Utama',
          harga: 24000,
          deskripsi: 'Kuah kaldu kuning gurih dengan suwiran ayam, soun, dan taburan koya istimewa.',
          isTersedia: true,
        ),
        MenuModel(
          id: 6,
          nama: 'Es Teh Manis Melati',
          slug: 'es-teh-manis-melati',
          kategori: 'Minuman',
          harga: 6000,
          deskripsi: 'Teh melati wangi segar disajikan dingin manis.',
          isTersedia: true,
        ),
        MenuModel(
          id: 7,
          nama: 'Jus Alpukat Kocok',
          slug: 'jus-alpukat-kocok',
          kategori: 'Minuman',
          harga: 18000,
          deskripsi: 'Alpukat mentega asli dengan sirup cokelat kental manis.',
          isTersedia: false,
        ),
      ];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveMenu({
    int? id,
    required String nama,
    required String kategori,
    required double harga,
    String? deskripsi,
    String? imagePath,
    bool isTersedia = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fields = {
        'nama': nama,
        'kategori': kategori,
        'harga': harga.toString(),
        'deskripsi': deskripsi ?? '',
        'is_tersedia': isTersedia ? '1' : '0',
      };

      if (id != null) {
        // Edit
        await _api.multipartRequest(
          method: 'POST', // With _method=PUT or POST
          endpoint: '${ApiConstants.menus}/$id',
          fields: {...fields, '_method': 'PUT'},
          fileField: 'image',
          filePath: imagePath,
        );
      } else {
        // Create
        await _api.multipartRequest(
          method: 'POST',
          endpoint: ApiConstants.menus,
          fields: fields,
          fileField: 'image',
          filePath: imagePath,
        );
      }

      await fetchMenus();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleAvailability(MenuModel menu) async {
    final newStatus = !menu.isTersedia;
    try {
      await _api.put(
        '${ApiConstants.menus}/${menu.id}',
        body: {'is_tersedia': newStatus ? 1 : 0},
      );
      final index = _menus.indexWhere((m) => m.id == menu.id);
      if (index != -1) {
        _menus[index] = _menus[index].copyWith(isTersedia: newStatus);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMenu(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.delete('${ApiConstants.menus}/$id');
      _menus.removeWhere((m) => m.id == id);
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
