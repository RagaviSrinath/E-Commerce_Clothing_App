import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/widgets/minimal_profile_chip.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../watchlist/presentation/bloc/watchlist_bloc.dart';
import '../../../watchlist/presentation/bloc/watchlist_event.dart';
import '../../../watchlist/presentation/bloc/watchlist_state.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar_widget.dart';
import 'product_details_screen.dart';

class CatalogueScreen extends StatelessWidget {
  final VoidCallback onGoToCart;

  const CatalogueScreen({super.key, required this.onGoToCart});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WatchlistBloc, WatchlistState>(
          listener: (context, state) {
            if (state.feedbackMessage != null) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.feedbackMessage!),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.read<WatchlistBloc>().add(const ClearWatchlistFeedback());
            }
          },
        ),
        BlocListener<CartBloc, CartState>(
          listenWhen: (previous, current) =>
              current.feedbackMessage != null &&
              previous.feedbackMessage != current.feedbackMessage,
          listener: (context, state) {
            final message = state.feedbackMessage;
            if (message != null) {
              context.read<CartBloc>().add(const ClearCartFeedback());
              final messenger = ScaffoldMessenger.of(context);
              messenger.hideCurrentSnackBar();
              final controller = messenger.showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'VIEW BAG',
                    textColor: Colors.amberAccent,
                    onPressed: onGoToCart,
                  ),
                ),
              );

              // Auto-dismiss in 2 seconds if user does not interact
              Future.delayed(const Duration(seconds: 2), () {
                controller.close();
              });
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NEXTGEN WARDROBE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Contemporary Curations',
                style: AppTextStyles.bodySmall.copyWith(letterSpacing: 0.5),
              ),
            ],
          ),
          actions: const [MinimalProfileChip()],
        ),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const LoadingIndicator(
                message: 'Curating seasonal collection...',
              );
            }

            if (state.isFailure) {
              return ErrorView(
                message: state.errorMessage ?? 'Failed to load products.',
                onRetry: () {
                  context.read<ProductBloc>().add(const LoadProducts());
                },
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<ProductBloc>().add(const RefreshProducts());
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Search & Category Filters
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: SearchBarWidget(
                        initialValue: state.searchQuery,
                        onChanged: (query) {
                          context.read<ProductBloc>().add(
                            SearchProducts(query),
                          );
                        },
                      ),
                    ),
                  ),

                  // Category Chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CategoryFilterChips(
                        categories: state.categories,
                        selectedCategory: state.selectedCategory,
                        onSelected: (category) {
                          context.read<ProductBloc>().add(
                            FilterCategory(category),
                          );
                        },
                      ),
                    ),
                  ),

                  // Results summary / count
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${state.filteredProducts.length} ${state.filteredProducts.length == 1 ? 'PIECE' : 'PIECES'}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: AppColors.textMuted,
                            ),
                          ),
                          if (state.searchQuery.isNotEmpty ||
                              state.selectedCategory != 'All')
                            GestureDetector(
                              onTap: () {
                                context.read<ProductBloc>().add(
                                  const FilterCategory('All'),
                                );
                                context.read<ProductBloc>().add(
                                  const SearchProducts(''),
                                );
                              },
                              child: const Text(
                                'Clear Filters',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Empty State or Product Grid
                  if (state.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateView(
                        icon: Icons.search_off_rounded,
                        title: 'No matching pieces found',
                        message:
                            'We couldn’t find anything matching "${state.searchQuery}". Try a different keyword or category.',
                        actionTitle: 'Reset Search',
                        onAction: () {
                          context.read<ProductBloc>().add(
                            const FilterCategory('All'),
                          );
                          context.read<ProductBloc>().add(
                            const SearchProducts(''),
                          );
                        },
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) {
                          // Responsive column count based on available viewport width
                          final width = constraints.crossAxisExtent;
                          final int crossAxisCount = width > 900
                              ? 4
                              : width > 600
                              ? 3
                              : 2;

                          return SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: 0.62,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 16,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final product = state.filteredProducts[index];
                              return ProductCard(
                                product: product,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailsScreen(
                                        product: product,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }, childCount: state.filteredProducts.length),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
