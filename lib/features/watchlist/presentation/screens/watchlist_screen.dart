import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/product_image_view.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../products/presentation/screens/product_details_screen.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';

class WatchlistScreen extends StatelessWidget {
  final VoidCallback onExplore;

  const WatchlistScreen({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'WISHLIST',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return EmptyStateView(
              icon: Icons.favorite_border_rounded,
              title: 'Your wishlist is currently empty',
              message: 'Save pieces you love to build your seasonal capsule wardrobe and track availability.',
              actionTitle: 'Explore Collection',
              onAction: onExplore,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = state.items[index];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: product),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 80,
                            height: 95,
                            child: ProductImageView(
                              imageUrl: product.imageUrl,
                              category: product.category,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 95,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.category.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                CurrencyFormatter.format(product.price),
                                style: AppTextStyles.price,
                              ),
                            ],
                          ),
                        ),

                        // Actions
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.textMuted,
                              ),
                              onPressed: () {
                                context.read<WatchlistBloc>().add(
                                  RemoveFromWatchlistEvent(product.id),
                                );
                              },
                              tooltip: 'Remove',
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                context.read<CartBloc>().add(
                                  AddToCart(
                                    product: product,
                                    size: product.sizes.isNotEmpty
                                        ? product.sizes.first
                                        : 'M',
                                    color: product.colors.isNotEmpty
                                        ? product.colors.first
                                        : 'Default',
                                  ),
                                );
                              },
                              child: const Text(
                                'Move to Bag',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
