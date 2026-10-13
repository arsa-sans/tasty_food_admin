class ApiConstants {
  // Default base URL. Can be changed dynamically via Settings in the app.
  // When testing on Android Emulator use 'http://10.0.2.2:8000' or live hosted URL.
  static const String defaultBaseUrl = 'https://arsa.1-cianjur.26.cyberwarrior.co.id'; // Replaceable in app settings
  static const String localEmulatorUrl = 'http://10.0.2.2:8000';
  static const String localDeviceUrl = 'http://192.168.1.100:8000';

  // Auth Endpoints
  static const String login = '/api/admin/login';
  static const String logout = '/api/admin/logout';
  static const String me = '/api/admin/me';

  // Dashboard Endpoints
  static const String dashboard = '/api/admin/dashboard';

  // Menu Endpoints (CRUD)
  static const String menus = '/api/admin/menu';

  // Order Endpoints
  static const String orders = '/api/admin/orders';
  static const String updateOrderStatus = '/api/admin/orders/{id}/status';
  static const String updateOrderPaymentStatus = '/api/admin/orders/{id}/payment-status';

  // Payment Method Endpoints (CRUD)
  static const String paymentMethods = '/api/admin/payment-methods';

  // Berita / Articles Endpoints (CRUD)
  static const String beritas = '/api/admin/berita';

  // Galeri Endpoints (CRUD)
  static const String galeris = '/api/admin/galeri';

  // Messages Endpoints
  static const String messages = '/api/admin/messages';
  static const String markMessageRead = '/api/admin/messages/{id}/mark-as-read';
}
