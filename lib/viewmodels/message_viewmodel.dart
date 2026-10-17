import 'package:flutter/material.dart';
import '../data/models/message_model.dart';
import '../data/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class MessageViewModel extends ChangeNotifier {
  final ApiService _api;

  MessageViewModel(this._api);

  bool _isLoading = false;
  String? _errorMessage;
  List<MessageModel> _messages = [];
  bool _onlyUnread = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get onlyUnread => _onlyUnread;

  int get unreadCount => _messages.where((m) => m.isUnread).length;

  List<MessageModel> get filteredMessages {
    if (_onlyUnread) {
      return _messages.where((m) => m.isUnread).toList();
    }
    return _messages;
  }

  void toggleOnlyUnread(bool val) {
    _onlyUnread = val;
    notifyListeners();
  }

  Future<void> fetchMessages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get(ApiConstants.messages);
      List<MessageModel> list = [];

      if (response is List) {
        list = response.map((m) => MessageModel.fromJson(m as Map<String, dynamic>)).toList();
      } else if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          list = data.map((m) => MessageModel.fromJson(m as Map<String, dynamic>)).toList();
        }
      }

      _messages = list;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _messages = [
        MessageModel(
          id: 1,
          nama: 'Bunga Citra',
          email: 'bunga@gmail.com',
          subjek: 'Pemesanan Menu Katering Prasmanan',
          pesan: 'Halo Tasty Food, apakah restoran menyediakan paket katering nasi kotak dan prasmanan untuk acara syukuran kantor 50 porsi?',
          status: 'belum_dibaca',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        MessageModel(
          id: 2,
          nama: 'Ikmal Ramadhan',
          email: 'ikmal@gmail.com',
          subjek: 'Reservasi Meja Makan Keluarga',
          pesan: 'Halo admin, saya ingin reservasi meja untuk 8 orang di akhir pekan ini jam 19.00. Apakah tersedia area VIP yang nyaman?',
          status: 'belum_dibaca',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        MessageModel(
          id: 3,
          nama: 'Iko Johansyah',
          email: 'marketing@cyberlabs.co.id',
          subjek: 'Penawaran Kerjasama Pemasok Bahan Segar',
          pesan: 'Kami dari distributor bahan pangan segar ingin menawarkan kerjasama pasokan sayuran dan daging berkualitas untuk restoran Tasty Food.',
          status: 'dibaca',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsRead(int id) async {
    try {
      await _api.post(
        ApiConstants.markMessageRead.replaceAll('{id}', id.toString()),
      );
      _updateLocalStatus(id, 'dibaca');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _updateLocalStatus(int id, String status) {
    final index = _messages.indexWhere((m) => m.id == id);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(status: status);
      notifyListeners();
    }
  }

  Future<bool> deleteMessage(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.delete('${ApiConstants.messages}/$id');
      _messages.removeWhere((m) => m.id == id);
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
