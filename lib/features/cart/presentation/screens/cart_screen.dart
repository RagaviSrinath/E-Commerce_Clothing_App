import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../payment/presentation/screens/checkout_screen.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/cart_item_tile.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback onStartShopping;

  const CartScreen({super.key, required this.onStartShopping});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SHOPPING BAG',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${state.totalQuantity} ${state.totalQuantity == 1 ? 'item' : 'items'}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            );
          },
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Clear Shopping Bag?'),
                      content: const Text(
                        'Are you sure you want to remove all items from your bag?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<CartBloc>().add(const ClearCart());
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Text(
                            'Clear All',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return EmptyStateView(
              icon: Icons.shopping_bag_outlined,
              title: 'Your shopping bag is empty',
              message: 'Explore our latest collection of contemporary tailoring, knitwear, and seasonal garments.',
              actionTitle: 'Start Shopping',
              onAction: onStartShopping,
            );
          }

          return Column(
            children: [
              // Items List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return CartItemTile(
                      item: item,
                      onQuantityChanged: (newQty) {
                        context.read<CartBloc>().add(
                          UpdateCartQuantity(
                            itemKey: item.itemKey,
                            quantity: newQty,
                          ),
                        );
                      },
                      onRemove: () {
                        context.read<CartBloc>().add(
                          RemoveFromCart(item.itemKey),
                        );
                      },
                    );
                  },
                ),
              ),

              // Order Summary Bottom Sheet
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: AppColors.borderSubtle),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Subtotal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            CurrencyFormatter.format(state.subtotal),
                            style: AppTextStyles.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Shipping
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Estimated Shipping',
                                style: AppTextStyles.bodyMedium,
                              ),
                              const SizedBox(width: 6),
                              if (state.subtotal >= 150)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.successBackground,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'FREE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            state.shippingFee == 0
                                ? 'FREE'
                                : CurrencyFormatter.format(state.shippingFee),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: state.shippingFee == 0
                                  ? AppColors.success
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Estimated Tax
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Estimated Tax (5%)',
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            CurrencyFormatter.format(state.estimatedTax),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(color: AppColors.borderSubtle),
                      ),

                      // Total Payable
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Payable',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(state.totalPayable),
                            style: AppTextStyles.price.copyWith(fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Checkout CTA button
                      CustomButton(
                        text:
                            'Proceed to Checkout (${CurrencyFormatter.format(state.totalPayable)})',
                        icon: Icons.lock_outline_rounded,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CheckoutScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
