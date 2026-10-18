/// Build-time configuration. Override with `--dart-define`, e.g.
/// `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api/v1`
abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dev.coffeesos.online/api/v1',
  );

  /// Store shown at `/` when the link has no store id
  /// (demo store "Daily Bean · Quận 3").
  static const defaultStoreId = String.fromEnvironment(
    'DEFAULT_STORE_ID',
    defaultValue: '6ec9fd14-86f1-4b77-83fa-0f01d4187beb',
  );

  static const appName = 'CoffeeSOS';
}
