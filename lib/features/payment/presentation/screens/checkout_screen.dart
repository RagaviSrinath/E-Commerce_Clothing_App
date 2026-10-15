import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/product_image_view.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_history_bloc.dart';
import '../bloc/payment_history_event.dart';
import '../bloc/payment_state.dart';
import 'payment_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Demo Card (•••• 4242)';

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'Demo Card (•••• 4242)',
      'title': 'Demo Credit / Debit Card',
      'subtitle': 'Mastercard ending in 4242',
      'icon': Icons.credit_card_rounded,
    },
    {
      'id': 'Apple Pay',
      'title': 'Apple Pay',
      'subtitle': 'One-touch biometric checkout',
      'icon': Icons.apple_rounded,
    },
    {
      'id': 'Google Pay',
      'title': 'Google Pay',
      'subtitle': 'Instant digital wallet',
      'icon': Icons.account_balance_wallet_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSuccessState) {
          // Clear cart only AFTER payment succeeds
          context.read<CartBloc>().add(const ClearCart());

          // Record completed transaction in payment history
          context.read<PaymentHistoryBloc>().add(RecordNewOrder(state.order));

          // Navigate to Payment Success Screen and clear navigation stack
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PaymentSuccessScreen(order: state.order),
            ),
          );
        } else if (state is PaymentFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
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
          title: const Text(
            'CHECKOUT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            if (cartState.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 60,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No items to checkout.',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Return to Bag'),
                    ),
                  ],
                ),
              );
            }

            return BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, paymentState) {
                final isProcessing = paymentState is PaymentProcessing;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Shipping Address
                      _buildSectionHeader('SHIPPING ADDRESS'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Aarav Sharma • +91 98765 43210',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Flat 402, Shanti Heights, MG Road\nBengaluru, Karnataka 560001, India',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 2: Payment Method
                      _buildSectionHeader('PAYMENT METHOD'),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          children: _paymentMethods.map((method) {
                            final isSelected =
                                _selectedPaymentMethod == method['id'];
                            return Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    method['icon'] as IconData,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  title: Text(
                                    method['title'] as String,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    method['subtitle'] as String,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  trailing: Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textMuted,
                                    size: 22,
                                  ),
                                  onTap: isProcessing
                                      ? null
                                      : () {
                                          setState(
                                            () => _selectedPaymentMethod =
                                                method['id'] as String,
                                          );
                                        },
                                ),
                                if (method != _paymentMethods.last)
                                  const Divider(
                                    height: 1,
                                    color: AppColors.borderSubtle,
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 3: Order Items Preview
                      _buildSectionHeader(
                        'ORDER ITEMS (${cartState.totalQuantity})',
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: cartState.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: ProductImageView(
                                      imageUrl: item.product.imageUrl,
                                      category: item.product.category,
                                      width: 44,
                                      height: 52,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Qty: ${item.quantity} • ${item.selectedSize}',
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(item.lineTotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 4: Cost Breakdown
                      _buildSectionHeader('ORDER SUMMARY'),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              'Subtotal',
                              CurrencyFormatter.format(cartState.subtotal),
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              'Shipping Fee',
                              cartState.shippingFee == 0
                                  ? 'FREE'
                                  : CurrencyFormatter.format(
                                      cartState.shippingFee,
                                    ),
                              valueColor: cartState.shippingFee == 0
                                  ? AppColors.success
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              'Estimated Tax (5%)',
                              CurrencyFormatter.format(cartState.estimatedTax),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Divider(color: AppColors.borderSubtle),
                            ),
                            _buildSummaryRow(
                              'Total Amount Due',
                              CurrencyFormatter.format(cartState.totalPayable),
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Pay Now CTA Button
                      CustomButton(
                        text: isProcessing
                            ? 'Processing Payment...'
                            : 'Pay Now ${CurrencyFormatter.format(cartState.totalPayable)}',
                        isLoading: isProcessing,
                        icon: Icons.check_circle_outline_rounded,
                        onPressed: isProcessing
                            ? null
                            : () {
                                context.read<PaymentBloc>().add(
                                  ProcessPaymentSubmitted(
                                    items: cartState.items,
                                    subtotal: cartState.subtotal,
                                    shippingFee: cartState.shippingFee,
                                    estimatedTax: cartState.estimatedTax,
                                    totalAmount: cartState.totalPayable,
                                    paymentMethod: _selectedPaymentMethod,
                                  ),
                                );
                              },
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '256-Bit SSL Demo Encrypted Transaction',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )
              : AppTextStyles.bodyMedium,
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 17 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
