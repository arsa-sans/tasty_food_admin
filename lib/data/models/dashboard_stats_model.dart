import 'order_model.dart';
import 'galeri_model.dart';
import 'message_model.dart';

class DashboardStatsModel {
  final int totalBerita;
  final int totalGaleri;
  final int unreadMessagesCount;
  final int totalMenu;
  final int totalOrders;
  final int unconfirmedOrdersCount;
  final List<OrderModel> latestOrders;
  final List<GaleriModel> latestGaleri;
  final List<MessageModel> latestMessages;

  DashboardStatsModel({
    this.totalBerita = 0,
    this.totalGaleri = 0,
    this.unreadMessagesCount = 0,
    this.totalMenu = 0,
    this.totalOrders = 0,
    this.unconfirmedOrdersCount = 0,
    this.latestOrders = const [],
    this.latestGaleri = const [],
    this.latestMessages = const [],
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    var rawOrders = json['latestOrders'] ?? json['latest_orders'];
    var rawGaleri = json['latestGaleri'] ?? json['latest_galeri'];
    var rawMessages = json['latestMessages'] ?? json['latest_messages'];

    return DashboardStatsModel(
      totalBerita: json['totalBerita'] ?? json['total_berita'] ?? 0,
      totalGaleri: json['totalGaleri'] ?? json['total_galeri'] ?? 0,
      unreadMessagesCount: json['unreadMessagesCount'] ?? json['unread_messages_count'] ?? 0,
      totalMenu: json['totalMenu'] ?? json['total_menu'] ?? 0,
      totalOrders: json['totalOrders'] ?? json['total_orders'] ?? 0,
      unconfirmedOrdersCount: json['unconfirmedOrdersCount'] ?? json['unconfirmed_orders_count'] ?? 0,
      latestOrders: rawOrders is List
          ? rawOrders.map((o) => OrderModel.fromJson(o as Map<String, dynamic>)).toList()
          : [],
      latestGaleri: rawGaleri is List
          ? rawGaleri.map((g) => GaleriModel.fromJson(g as Map<String, dynamic>)).toList()
          : [],
      latestMessages: rawMessages is List
          ? rawMessages.map((m) => MessageModel.fromJson(m as Map<String, dynamic>)).toList()
          : [],
    );
  }
}
