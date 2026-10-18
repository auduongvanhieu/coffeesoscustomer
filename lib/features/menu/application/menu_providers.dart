import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/menu_repository.dart';
import '../domain/menu_models.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final menuRepositoryProvider = Provider<MenuRepository>(
  (ref) => MenuRepository(ref.watch(apiClientProvider)),
);

/// The public menu of one store, keyed by store id from the URL / QR code.
final storeMenuProvider = FutureProvider.family<StoreMenu, String>(
  (ref, storeId) => ref.watch(menuRepositoryProvider).storeMenu(storeId),
);
