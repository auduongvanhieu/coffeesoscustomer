/// Mirrors the Go `menu.StoreMenu` view served at
/// `GET /api/v1/app/stores/:storeId/menu`.
class MenuCategory {
  const MenuCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
    id: json['id'] as String,
    name: json['name'] as String,
    sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  );

  final String id;
  final String name;
  final int sortOrder;
}

class OptionChoice {
  const OptionChoice({
    required this.code,
    required this.name,
    required this.priceDelta,
  });

  factory OptionChoice.fromJson(Map<String, dynamic> json) => OptionChoice(
    code: json['code'] as String,
    name: json['name'] as String,
    priceDelta: (json['priceDelta'] as num?)?.toInt() ?? 0,
  );

  final String code;
  final String name;
  final int priceDelta;
}

class OptionGroup {
  const OptionGroup({
    required this.code,
    required this.name,
    required this.multi,
    required this.required,
    required this.choices,
  });

  factory OptionGroup.fromJson(Map<String, dynamic> json) => OptionGroup(
    code: json['code'] as String,
    name: json['name'] as String,
    multi: json['type'] == 'multi',
    required: json['required'] as bool? ?? false,
    choices: [
      for (final c in (json['choices'] as List? ?? const []))
        OptionChoice.fromJson(c as Map<String, dynamic>),
    ],
  );

  final String code;
  final String name;
  final bool multi;
  final bool required;
  final List<OptionChoice> choices;
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.available,
    required this.sortOrder,
    required this.options,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final desc = (json['description'] as String?)?.trim();
    final image = (json['imageUrl'] as String?)?.trim();
    return MenuItem(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      description: desc == null || desc.isEmpty ? null : desc,
      imageUrl: image == null || image.isEmpty ? null : image,
      // `price` is the store-resolved price; fall back to the brand price.
      price: ((json['price'] ?? json['basePrice']) as num?)?.toInt() ?? 0,
      available: json['available'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      options: [
        for (final g in (json['options'] as List? ?? const []))
          OptionGroup.fromJson(g as Map<String, dynamic>),
      ],
    );
  }

  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final String? imageUrl;
  final int price;
  final bool available;
  final int sortOrder;
  final List<OptionGroup> options;

  /// True when some choice raises the price (e.g. size L), so the card
  /// shows "từ 45.000đ".
  bool get hasPriceVariants =>
      options.any((g) => g.choices.any((c) => c.priceDelta > 0));
}

/// A category with its items, in display order.
class MenuSection {
  const MenuSection(this.category, this.items);

  final MenuCategory category;
  final List<MenuItem> items;
}

class StoreMenu {
  const StoreMenu({required this.storeId, required this.sections});

  factory StoreMenu.fromJson(Map<String, dynamic> json) {
    final categories = [
      for (final c in (json['categories'] as List? ?? const []))
        if ((c as Map<String, dynamic>)['isActive'] != false)
          MenuCategory.fromJson(c),
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final items = [
      for (final i in (json['items'] as List? ?? const []))
        MenuItem.fromJson(i as Map<String, dynamic>),
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final known = {for (final c in categories) c.id};
    final sections = [
      for (final c in categories)
        MenuSection(c, [
          for (final i in items)
            if (i.categoryId == c.id) i,
        ]),
      // Items whose category is hidden or missing still get shown.
      MenuSection(
        const MenuCategory(id: '_other', name: 'Khác', sortOrder: 1 << 30),
        [
          for (final i in items)
            if (!known.contains(i.categoryId)) i,
        ],
      ),
    ].where((s) => s.items.isNotEmpty).toList();

    return StoreMenu(storeId: json['storeId'] as String, sections: sections);
  }

  final String storeId;
  final List<MenuSection> sections;

  bool get isEmpty => sections.isEmpty;

  /// Case- and accent-insensitive search over names and descriptions.
  StoreMenu filter(String query) {
    final q = foldVietnamese(query.trim());
    if (q.isEmpty) return this;
    return StoreMenu(
      storeId: storeId,
      sections: [
        for (final s in sections)
          MenuSection(s.category, [
            for (final i in s.items)
              if (foldVietnamese('${i.name} ${i.description ?? ''}')
                  .contains(q))
                i,
          ]),
      ].where((s) => s.items.isNotEmpty).toList(),
    );
  }
}

const _accentGroups = {
  'a': 'àáạảãâầấậẩẫăằắặẳẵ',
  'e': 'èéẹẻẽêềếệểễ',
  'i': 'ìíịỉĩ',
  'o': 'òóọỏõôồốộổỗơờớợởỡ',
  'u': 'ùúụủũưừứựửữ',
  'y': 'ỳýỵỷỹ',
  'd': 'đ',
};

final _accentMap = {
  for (final e in _accentGroups.entries)
    for (final ch in e.value.split('')) ch: e.key,
};

/// Lowercases and strips Vietnamese diacritics so "tra dao" finds "Trà đào".
String foldVietnamese(String input) =>
    input.toLowerCase().split('').map((c) => _accentMap[c] ?? c).join();
