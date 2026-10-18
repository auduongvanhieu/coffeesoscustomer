import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Item photo from R2 with a beige placeholder while loading or missing.
class MenuImage extends StatelessWidget {
  const MenuImage({super.key, required this.url, this.radius = 12});

  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.beige,
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_cafe_outlined,
        color: AppColors.primaryLight,
        size: 32,
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url == null
          ? placeholder
          : Image.network(
              url!,
              // Keyed so a reused slot never keeps the previous <img>.
              key: ValueKey(url),
              fit: BoxFit.cover,
              // The R2 CDN sends no CORS headers; let Flutter web fall back
              // to an <img> element like the Staff app does.
              webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
              frameBuilder: (_, child, frame, sync) =>
                  sync || frame != null ? child : placeholder,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}
