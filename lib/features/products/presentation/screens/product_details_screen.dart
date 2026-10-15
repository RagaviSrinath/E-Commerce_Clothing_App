import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/navigation/navigation_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/product_image_view.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../watchlist/presentation/bloc/watchlist_bloc.dart';
import '../../../watchlist/presentation/bloc/watchlist_event.dart';
import '../../../watchlist/presentation/bloc/watchlist_state.dart';
import '../../domain/entities/product_entity.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late String _selectedSize;
  late String _selectedColor;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.sizes.isNotEmpty
        ? widget.product.sizes.first
        : 'Standard';
    _selectedColor = widget.product.colors.isNotEmpty
        ? widget.product.colors.first
        : 'Default';
  }

  void _increment() {
    setState(() => _quantity++);
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(product.name, style: AppTextStyles.titleMedium),
        centerTitle: true,
        actions: [
          BlocBuilder<WatchlistBloc, WatchlistState>(
            builder: (context, watchlistState) {
              final isFavorite = watchlistState.isFavorite(product.id);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? AppColors.favorite
                      : AppColors.textPrimary,
                ),
                onPressed: () {
                  context.read<WatchlistBloc>().add(ToggleWatchlist(product));
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Container(
              height: 380,
              width: double.infinity,
              color: AppColors.surfaceVariant,
              child: ProductImageView(
                imageUrl: product.imageUrl,
                category: product.category,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 380,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge & rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${product.reviewCount} reviews)',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title & Price
                  Text(product.name, style: AppTextStyles.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: AppTextStyles.price.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 20),

                  const Divider(color: AppColors.borderSubtle),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Editorial Notes',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(product.description, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 24),

                  // Size selection
                  if (product.sizes.isNotEmpty) ...[
                    const Text('Select Size', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: product.sizes.map((size) {
                        final isSelected = size == _selectedSize;
                        return ChoiceChip(
                          label: Text(
                            size,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                          onSelected: (_) {
                            setState(() => _selectedSize = size);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Color selection
                  if (product.colors.isNotEmpty) ...[
                    const Text(
                      'Select Shade',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: product.colors.map((color) {
                        final isSelected = color == _selectedColor;
                        return ChoiceChip(
                          label: Text(
                            color,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                          onSelected: (_) {
                            setState(() => _selectedColor = color);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Quantity Selector
                  const Text('Quantity', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 10),
                  Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: _quantity > 1 ? _decrement : null,
                          color: AppColors.textPrimary,
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: _increment,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Price', style: AppTextStyles.bodySmall),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(product.price * _quantity),
                      style: AppTextStyles.price.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: 'Add to Bag',
                  icon: Icons.shopping_bag_outlined,
                  onPressed: () {
                    context.read<CartBloc>().add(
                      AddToCart(
                        product: product,
                        quantity: _quantity,
                        size: _selectedSize,
                        color: _selectedColor,
                      ),
                    );
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.hideCurrentSnackBar();
                    final controller = messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added $_quantity × "${product.name}" to your bag',
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'VIEW BAG',
                          textColor: Colors.amberAccent,
                          onPressed: () {
                            Navigator.of(context).pop();
                            NavigationController.switchToTab(2);
                          },
                        ),
                      ),
                    );

                    // Auto-dismiss in 2 seconds if user does not interact
                    Future.delayed(const Duration(seconds: 2), () {
                      controller.close();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
