import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SoldOutBadge extends StatelessWidget {
  const SoldOutBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.dangerSoft,
      borderRadius: BorderRadius.circular(6),
    ),
    child: const Text(
      'Hết món',
      style: TextStyle(
        color: AppColors.danger,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
