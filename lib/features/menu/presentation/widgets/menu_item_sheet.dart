import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money.dart';
import '../../domain/menu_models.dart';
import 'menu_image.dart';
import 'sold_out_badge.dart';

/// Read-only item detail: photo, price and the options the shop offers.
/// Ordering happens at the counter until the cart screen exists.
Future<void> showMenuItemSheet(BuildContext context, MenuItem item) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => _MenuItemSheet(item: item),
    );

class _MenuItemSheet extends StatelessWidget {
  const _MenuItemSheet({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: MenuImage(url: item.imageUrl, radius: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: text.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formatVnd(item.price),
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (!item.available) ...[
                    const SizedBox(height: 8),
                    const SoldOutBadge(),
                  ],
                  if (item.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.description!,
                      style: text.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                  for (final group in item.options) ...[
                    const SizedBox(height: 20),
                    _OptionGroupView(group: group),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Gọi món tại quầy hoặc báo nhân viên phục vụ.',
                          style: text.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionGroupView extends StatelessWidget {
  const _OptionGroupView({required this.group});

  final OptionGroup group;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final hint = group.multi ? 'chọn nhiều' : 'chọn 1';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: group.name),
              TextSpan(
                text: '  ·  $hint',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in group.choices)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: c.name),
                      if (c.priceDelta != 0)
                        TextSpan(
                          text:
                              '  ${c.priceDelta > 0 ? '+' : ''}${formatVnd(c.priceDelta)}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  style: text.bodyMedium,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
