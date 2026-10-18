import 'package:coffeesos_customer/features/menu/domain/menu_models.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _item(
  String id,
  String cat,
  String name, {
  bool available = true,
}) => {
  'id': id,
  'categoryId': cat,
  'name': name,
  'description': null,
  'imageUrl': '',
  'basePrice': 40000,
  'price': 45000,
  'available': available,
  'sortOrder': 0,
  'options': [
    {
      'code': 'size',
      'name': 'Size',
      'type': 'single',
      'required': true,
      'choices': [
        {'code': 'm', 'name': 'M', 'priceDelta': 0},
        {'code': 'l', 'name': 'L', 'priceDelta': 5000},
      ],
    },
  ],
};

void main() {
  final menu = StoreMenu.fromJson({
    'storeId': 's1',
    'categories': [
      {'id': 'tea', 'name': 'Trà', 'sortOrder': 1, 'isActive': true},
      {'id': 'cf', 'name': 'Cà phê', 'sortOrder': 0, 'isActive': true},
      {'id': 'old', 'name': 'Cũ', 'sortOrder': 2, 'isActive': false},
    ],
    'items': [
      _item('1', 'tea', 'Trà đào cam sả'),
      _item('2', 'cf', 'Cà phê sữa đá', available: false),
      _item('3', 'old', 'Bạc xỉu'),
    ],
  });

  test('groups items by category order and keeps orphans under Khác', () {
    expect(menu.sections.map((s) => s.category.name), [
      'Cà phê',
      'Trà',
      'Khác',
    ]);
    final tea = menu.sections[1].items.single;
    expect(tea.price, 45000);
    expect(tea.imageUrl, isNull);
    expect(tea.hasPriceVariants, isTrue);
    expect(menu.sections.first.items.single.available, isFalse);
  });

  test('search ignores case and Vietnamese accents', () {
    final hit = menu.filter('TRA DAO');
    expect(hit.sections.single.items.single.id, '1');
    expect(menu.filter('xyz').isEmpty, isTrue);
    expect(foldVietnamese('Đường'), 'duong');
  });
}
