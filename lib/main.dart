import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/storage_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/order_viewmodel.dart';
import 'viewmodels/menu_viewmodel.dart';
import 'viewmodels/payment_method_viewmodel.dart';
import 'viewmodels/berita_viewmodel.dart';
import 'viewmodels/galeri_viewmodel.dart';
import 'viewmodels/message_viewmodel.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'views/auth/login_view.dart';
import 'views/main_navigation_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Indonesian Date Formatting for intl
  await initializeDateFormatting('id_ID', null);

  // Initialize Storage Service
  final storageService = await StorageService.init();
  final apiService = ApiService(storageService);
  final authService = AuthService(apiService, storageService);

  runApp(
    TastyFoodAdminApp(
      storageService: storageService,
      apiService: apiService,
      authService: authService,
    ),
  );
}

class TastyFoodAdminApp extends StatelessWidget {
  final StorageService storageService;
  final ApiService apiService;
  final AuthService authService;

  const TastyFoodAdminApp({
    super.key,
    required this.storageService,
    required this.apiService,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authService, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderViewModel(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => MenuViewModel(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentMethodViewModel(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => BeritaViewModel(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => GaleriViewModel(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => MessageViewModel(apiService),
        ),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, authVm, _) {
          return MaterialApp(
            title: 'Tasty Food Admin',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: authVm.isLoggedIn ? const MainNavigationView() : const LoginView(),
          );
        },
      ),
    );
  }
}
