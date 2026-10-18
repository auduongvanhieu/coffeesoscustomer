import '../../../core/network/api_client.dart';
import '../domain/menu_models.dart';

class MenuRepository {
  MenuRepository(this._api);

  final ApiClient _api;

  Future<StoreMenu> storeMenu(String storeId) async {
    try {
      final res = await _api.dio.get<Map<String, dynamic>>(
        '/app/stores/$storeId/menu',
      );
      return StoreMenu.fromJson(res.data!);
    } catch (e) {
      throw unwrapApiError(e);
    }
  }
}
