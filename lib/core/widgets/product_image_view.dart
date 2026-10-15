import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Reusable, robust image view for fashion products.
/// Handles network loading with mobile browser headers, asset images,
/// and an elegant editorial fallback card if network/CDN fails or is offline.
class ProductImageView extends StatelessWidget {
  final String imageUrl;
  final String category;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ProductImageView({
    super.key,
    required this.imageUrl,
    this.category = '',
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildFallbackCard(),
      );
    } else {
      imageWidget = Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        headers: const {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Mobile Safari/537.36',
          'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.surfaceVariant,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackCard();
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildFallbackCard() {
    final theme = _getCategoryVisualTheme(category);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.gradientColors,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle watermark icon in background
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              theme.icon,
              size: 80,
              color: Colors.white.withAlpha(25),
            ),
          ),
          // Main center fashion emblem
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(200),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(theme.icon, size: 28, color: theme.accentColor),
              ),
              const SizedBox(height: 8),
              Text(
                category.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: theme.accentColor.withAlpha(220),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _CategoryTheme _getCategoryVisualTheme(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('outerwear')) {
      return const _CategoryTheme(
        gradientColors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
        accentColor: Color(0xFF334155),
        icon: Icons.dry_cleaning_rounded,
      );
    } else if (lower.contains('top')) {
      return const _CategoryTheme(
        gradientColors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
        accentColor: Color(0xFF475569),
        icon: Icons.checkroom_rounded,
      );
    } else if (lower.contains('bottom')) {
      return const _CategoryTheme(
        gradientColors: [Color(0xFFE0E7FF), Color(0xFFC7D2FE)],
        accentColor: Color(0xFF3730A3),
        icon: Icons.straighten_rounded,
      );
    } else if (lower.contains('footwear')) {
      return const _CategoryTheme(
        gradientColors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
        accentColor: Color(0xFF92400E),
        icon: Icons.snowshoeing_rounded,
      );
    } else if (lower.contains('dress')) {
      return const _CategoryTheme(
        gradientColors: [Color(0xFFFFE4E6), Color(0xFFFECDD3)],
        accentColor: Color(0xFF9F1239),
        icon: Icons.woman_rounded,
      );
    } else {
      // Accessories
      return const _CategoryTheme(
        gradientColors: [Color(0xFFF5F3FF), Color(0xFFDDD6FE)],
        accentColor: Color(0xFF5B21B6),
        icon: Icons.shopping_bag_outlined,
      );
    }
  }
}

class _CategoryTheme {
  final List<Color> gradientColors;
  final Color accentColor;
  final IconData icon;

  const _CategoryTheme({
    required this.gradientColors,
    required this.accentColor,
    required this.icon,
  });
}
