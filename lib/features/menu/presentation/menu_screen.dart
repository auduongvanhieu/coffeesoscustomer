import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../application/menu_providers.dart';
import '../domain/menu_models.dart';
import 'widgets/menu_item_card.dart';
import 'widgets/menu_item_sheet.dart';

/// Customer-facing menu of one store: search, category tabs that jump to
/// each section, and item cards that open a read-only detail sheet.
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key, required this.storeId});

  final String storeId;

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  static const _maxContentWidth = 1100.0;

  final _search = TextEditingController();
  final _scroll = ScrollController();
  final _sectionKeys = <String, GlobalKey>{};
  final _chipKeys = <String, GlobalKey>{};
  final _viewportKey = GlobalKey();
  String _query = '';
  String? _activeCategory;
  bool _jumping = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_syncActiveCategory);
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  GlobalKey _sectionKey(String id) =>
      _sectionKeys.putIfAbsent(id, GlobalKey.new);
  GlobalKey _chipKey(String id) => _chipKeys.putIfAbsent(id, GlobalKey.new);

  Future<void> _jumpTo(String categoryId) async {
    final ctx = _sectionKeys[categoryId]?.currentContext;
    if (ctx == null) return;
    setState(() => _activeCategory = categoryId);
    _jumping = true;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
    _jumping = false;
    _revealChip(categoryId);
  }

  /// Highlights the category whose header has scrolled to the top.
  void _syncActiveCategory() {
    if (_jumping) return;
    final viewport = _viewportKey.currentContext?.findRenderObject();
    if (viewport is! RenderBox || !viewport.hasSize) return;
    final top = viewport.localToGlobal(Offset.zero).dy + 24;
    String? active;
    for (final e in _sectionKeys.entries) {
      final box = e.value.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) continue;
      if (box.localToGlobal(Offset.zero).dy <= top) active = e.key;
    }
    active ??= _sectionKeys.keys.firstOrNull;
    if (active != null && active != _activeCategory) {
      setState(() => _activeCategory = active);
      _revealChip(active);
    }
  }

  void _revealChip(String id) {
    final ctx = _chipKeys[id]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: const Duration(milliseconds: 250),
      );
    }
  }

  void _onSearch(String value) {
    setState(() => _query = value);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final menu = ref.watch(storeMenuProvider(widget.storeId));
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: menu.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _Message(
                icon: Icons.wifi_off_rounded,
                title: 'Chưa tải được thực đơn',
                detail: e.toString(),
                action: 'Thử lại',
                onAction: () =>
                    ref.invalidate(storeMenuProvider(widget.storeId)),
              ),
              data: _buildMenu,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(StoreMenu fullMenu) {
    final menu = fullMenu.filter(_query);
    _sectionKeys.removeWhere(
      (id, _) => !menu.sections.any((s) => s.category.id == id),
    );
    final active = menu.sections.any((s) => s.category.id == _activeCategory)
        ? _activeCategory
        : menu.sections.firstOrNull?.category.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(controller: _search, onChanged: _onSearch),
        if (menu.sections.length > 1)
          _CategoryTabs(
            sections: menu.sections,
            activeId: active,
            keyFor: _chipKey,
            onTap: _jumpTo,
          ),
        Expanded(
          key: _viewportKey,
          child: fullMenu.isEmpty
              ? const _Message(
                  icon: Icons.menu_book_outlined,
                  title: 'Quán chưa có món nào',
                  detail: 'Thực đơn sẽ hiện ở đây khi quán cập nhật.',
                )
              : menu.isEmpty
              ? _Message(
                  icon: Icons.search_off_rounded,
                  title: 'Không tìm thấy món',
                  detail: 'Không có món nào khớp với "$_query".',
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(storeMenuProvider(widget.storeId).future),
                  child: _MenuList(
                    menu: menu,
                    controller: _scroll,
                    keyFor: _sectionKey,
                  ),
                ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_cafe_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thực đơn',
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Chọn món yêu thích và gọi tại quầy',
                      style: text.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) => TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Tìm món, ví dụ "trà đào"',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: value.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Xoá',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.sections,
    required this.activeId,
    required this.keyFor,
    required this.onTap,
  });

  final List<MenuSection> sections;
  final String? activeId;
  final GlobalKey Function(String id) keyFor;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = sections[i].category;
          final selected = c.id == activeId;
          return ChoiceChip(
            key: keyFor(c.id),
            label: Text(c.name),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) => onTap(c.id),
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }
}

class _MenuList extends StatelessWidget {
  const _MenuList({
    required this.menu,
    required this.controller,
    required this.keyFor,
  });

  final StoreMenu menu;
  final ScrollController controller;
  final GlobalKey Function(String id) keyFor;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 600
            ? 2
            : 1;
        return CustomScrollView(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            for (final section in menu.sections) ...[
              SliverToBoxAdapter(
                key: keyFor(section.category.id),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: section.category.name),
                        TextSpan(
                          text: '  ${section.items.length} món',
                          style: text.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: MenuItemCard.height,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: section.items.length,
                  itemBuilder: (context, i) {
                    final item = section.items[i];
                    return MenuItemCard(
                      key: ValueKey(item.id),
                      item: item,
                      onTap: () => showMenuItemSheet(context, item),
                    );
                  },
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: SizedBox(
                // Room to scroll the last section up to the top.
                height:
                    constraints.maxHeight * 0.5 +
                    MediaQuery.paddingOf(context).bottom,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.detail,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.primaryLight),
            const SizedBox(height: 12),
            Text(
              title,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: 180,
                child: FilledButton(onPressed: onAction, child: Text(action!)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
