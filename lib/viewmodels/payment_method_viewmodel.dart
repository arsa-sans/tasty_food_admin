import 'package:flutter/material.dart';
import '../data/models/payment_method_model.dart';
import '../data/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class PaymentMethodViewModel extends ChangeNotifier {
  final ApiService _api;

  PaymentMethodViewModel(this._api);

  bool _isLoading = false;
  String? _errorMessage;
  List<PaymentMethodModel> _methods = [];
  String _selectedTipe = 'Semua';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedTipe => _selectedTipe;

  List<PaymentMethodModel> get filteredMethods {
    if (_selectedTipe == 'Semua') return _methods;
    return _methods.where((m) => m.tipe == _selectedTipe).toList();
  }

  void setTipe(String tipe) {
    _selectedTipe = tipe;
    notifyListeners();
  }

  Future<void> fetchPaymentMethods() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get(ApiConstants.paymentMethods);
      List<PaymentMethodModel> list = [];

      if (response is List) {
        list = response.map((p) => PaymentMethodModel.fromJson(p as Map<String, dynamic>)).toList();
      } else if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          list = data.map((p) => PaymentMethodModel.fromJson(p as Map<String, dynamic>)).toList();
        }
      }

      _methods = list;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _methods = [
        PaymentMethodModel(
          id: 1,
          nama: 'Tunai saat Pengantaran (COD)',
          tipe: 'cash',
          instruksi: 'Siapkan uang pas saat pesanan diantarkan oleh kurir ke alamat Anda.',
          isAktif: true,
        ),
        PaymentMethodModel(
          id: 2,
          nama: 'QRIS (Semua E-Wallet & M-Banking)',
          tipe: 'e_wallet',
          nomorRekening: '08516114767',
          atasNama: 'Tasty Food Resto',
          instruksi: 'Scan kode QRIS yang tersedia menggunakan aplikasi BCA, GoPay, OVO, Dana, atau ShopeePay.',
          isAktif: true,
        ),
        PaymentMethodModel(
          id: 3,
          nama: 'Transfer Bank BCA',
          tipe: 'bank',
          nomorRekening: '5221345678',
          atasNama: 'M. Arsa Prayata',
          instruksi: 'Transfer sesuai total belanja ke rekening BCA tertera dan upload bukti transfer Anda.',
          isAktif: true,
        ),
        PaymentMethodModel(
          id: 4,
          nama: 'Dana',
          tipe: 'e_wallet',
          nomorRekening: '08516114767',
          atasNama: 'Arsa Prayata',
          instruksi: 'Transfer ke nomor Dana tertera.',
          isAktif: true,
        ),
      ];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> savePaymentMethod({
    int? id,
    required String nama,
    required String tipe,
    String? nomorRekening,
    String? atasNama,
    String? instruksi,
    String? imagePath,
    bool isAktif = true,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fields = {
        'nama': nama,
        'tipe': tipe,
        'nomor_rekening': nomorRekening ?? '',
        'atas_nama': atasNama ?? '',
        'instruksi': instruksi ?? '',
        'is_aktif': isAktif ? '1' : '0',
      };

      if (id != null) {
        await _api.multipartRequest(
          method: 'POST',
          endpoint: '${ApiConstants.paymentMethods}/$id',
          fields: {...fields, '_method': 'PUT'},
          fileField: 'gambar',
          filePath: imagePath,
        );
      } else {
        await _api.multipartRequest(
          method: 'POST',
          endpoint: ApiConstants.paymentMethods,
          fields: fields,
          fileField: 'gambar',
          filePath: imagePath,
        );
      }

      await fetchPaymentMethods();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleActive(PaymentMethodModel method) async {
    final newStatus = !method.isAktif;
    try {
      await _api.put(
        '${ApiConstants.paymentMethods}/${method.id}',
        body: {'is_aktif': newStatus ? 1 : 0},
      );
      final index = _methods.indexWhere((m) => m.id == method.id);
      if (index != -1) {
        _methods[index] = _methods[index].copyWith(isAktif: newStatus);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePaymentMethod(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.delete('${ApiConstants.paymentMethods}/$id');
      _methods.removeWhere((m) => m.id == id);
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
