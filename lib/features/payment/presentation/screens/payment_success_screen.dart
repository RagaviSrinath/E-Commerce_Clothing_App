import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/navigation/navigation_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final OrderEntity order;

  const PaymentSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy • hh:mm a');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        context.read<PaymentBloc>().add(const ResetPayment());
        NavigationController.switchToTab(0);
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'ORDER CONFIRMED',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // Success Animated Check Icon
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.successBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 44,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Payment Received',
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Thank you for your order. We’ve sent your receipt and tracking details to your registered email.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 28),

              // Order Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRow(
                      'Order Reference',
                      order.orderId,
                      isHighlight: true,
                    ),
                    const Divider(height: 24, color: AppColors.borderSubtle),
                    _buildRow(
                      'Date & Time',
                      dateFormat.format(order.paymentDate),
                    ),
                    const Divider(height: 24, color: AppColors.borderSubtle),
                    _buildRow('Payment Method', order.paymentMethod),
                    const Divider(height: 24, color: AppColors.borderSubtle),
                    _buildRow(
                      'Total Paid',
                      CurrencyFormatter.format(order.totalPaid),
                      isLargePrice: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Items purchased mini summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PURCHASED ITEMS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.quantity}x ${item.product.name} (${item.selectedSize})',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(item.lineTotal),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Action Buttons
              CustomButton(
                text: 'View Bag',
                icon: Icons.shopping_bag_outlined,
                onPressed: () {
                  context.read<PaymentBloc>().add(const ResetPayment());
                  NavigationController.switchToTab(2);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'View Orders',
                icon: Icons.receipt_long_outlined,
                variant: ButtonVariant.outline,
                onPressed: () {
                  context.read<PaymentBloc>().add(const ResetPayment());
                  NavigationController.switchToTab(3);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Continue Shopping',
                icon: Icons.storefront_outlined,
                variant: ButtonVariant.secondary,
                onPressed: () {
                  context.read<PaymentBloc>().add(const ResetPayment());
                  NavigationController.switchToTab(0);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isHighlight = false,
    bool isLargePrice = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: TextStyle(
            fontSize: isLargePrice ? 18 : 13,
            fontWeight: isLargePrice || isHighlight
                ? FontWeight.w700
                : FontWeight.w500,
            color: isLargePrice
                ? AppColors.primary
                : (isHighlight ? AppColors.accent : AppColors.textPrimary),
            letterSpacing: isHighlight ? 0.8 : 0,
          ),
        ),
      ],
    );
  }
}
