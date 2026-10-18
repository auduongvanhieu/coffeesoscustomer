import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'features/menu/presentation/menu_screen.dart';

/// `/s/:storeId` is the link printed on each store's QR code.
/// `/` falls back to the default (demo) store.
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', redirect: (_, _) => '/s/${AppConfig.defaultStoreId}'),
    GoRoute(
      path: '/s/:storeId',
      builder: (_, state) =>
          MenuScreen(storeId: state.pathParameters['storeId']!),
    ),
  ],
  errorBuilder: (_, _) => const MenuScreen(storeId: AppConfig.defaultStoreId),
);

class CoffeeSosCustomerApp extends StatelessWidget {
  const CoffeeSosCustomerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: AppConfig.appName,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    routerConfig: _router,
  );
}
