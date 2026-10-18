# CoffeeSOS Customer

Flutter app for cafe customers (web + Android + iOS). First screen: the store menu.

- Route `/s/<storeId>` shows the public menu of that store (the link to print on the QR code).
  `/` opens the demo store "Daily Bean · Quận 3".
- Data: `GET /api/v1/app/stores/:storeId/menu` (no login).
- Stack mirrors CoffeeSOSStaff: riverpod, go_router, dio, Be Vietnam Pro, Daily Bean colours.

## Run

```
flutter run -d chrome                       # uses https://dev.coffeesos.online/api/v1
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:8080/api/v1 \
  --dart-define=DEFAULT_STORE_ID=<uuid>     # local backend
flutter test && flutter analyze
```
