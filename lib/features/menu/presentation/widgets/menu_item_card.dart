import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money.dart';
import '../../domain/menu_models.dart';
import 'menu_image.dart';
import 'sold_out_badge.dart';

/// Horizontal card: photo on the left, name / description / price on the right.
class MenuItemCard extends StatelessWidget {
  const MenuItemCard({super.key, required this.item, required this.onTap});

  static const height = 120.0;

  final MenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = !item.available;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox.square(
                dimension: height - 24,
                child: Opacity(
                  opacity: muted ? 0.45 : 1,
                  child: MenuImage(url: item.imageUrl),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: muted ? AppColors.textSecondary : null,
                      ),
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                if (item.hasPriceVariants)
                                  TextSpan(
                                    text: 'từ ',
                                    style: text.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                TextSpan(text: formatVnd(item.price)),
                              ],
                            ),
                            style: text.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: muted
                                  ? AppColors.textSecondary
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        if (muted) const SoldOutBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
