import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/product_image_view.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/payment_history_bloc.dart';
import '../bloc/payment_history_event.dart';
import '../bloc/payment_history_state.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final VoidCallback onStartShopping;

  const PaymentHistoryScreen({super.key, required this.onStartShopping});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PAYMENT HISTORY',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Verified Orders & Receipts',
              style: AppTextStyles.bodySmall.copyWith(letterSpacing: 0.5),
            ),
          ],
        ),
      ),
      body: BlocBuilder<PaymentHistoryBloc, PaymentHistoryState>(
        builder: (context, state) {
          if (state.status == PaymentHistoryStatus.loading &&
              state.orders.isEmpty) {
            return const Center(child: LoadingIndicator());
          }

          if (state.status == PaymentHistoryStatus.failure &&
              state.orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage ?? 'Failed to load orders',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PaymentHistoryBloc>().add(
                          const LoadPaymentHistory(),
                        );
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.isEmpty) {
            return EmptyStateView(
              icon: Icons.receipt_long_outlined,
              title: 'No Payment History Yet',
              message: 'Transactions and receipts for your orders will appear here once you make a purchase.',
              actionTitle: 'Explore Wardrobe',
              onAction: onStartShopping,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PaymentHistoryBloc>().add(
                const LoadPaymentHistory(),
              );
            },
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                // Summary Metrics Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'COMPLETED ORDERS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${state.orderCount}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(height: 36, width: 1, color: Colors.white24),
                      Column(
                        children: [
                          const Text(
                            'TOTAL SPENT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            CurrencyFormatter.format(state.totalSpent),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'RECENT TRANSACTIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),

                // Order Cards
                ...state.orders.map((order) {
                  return _buildOrderCard(context, order, dateFormat);
                }),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderEntity order,
    DateFormat dateFormat,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.orderId,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 12,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'PAID',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date & Method
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat.format(order.paymentDate),
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      order.paymentMethod,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, color: AppColors.borderSubtle),

                // Purchased items list
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: ProductImageView(
                            imageUrl: item.product.imageUrl,
                            category: item.product.category,
                            width: 38,
                            height: 46,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Qty: ${item.quantity} • Size: ${item.selectedSize}',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
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

                const Divider(height: 22, color: AppColors.borderSubtle),

                // Footer with Total and Receipt Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL AMOUNT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(order.totalPaid),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.borderSubtle),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.receipt_long_rounded, size: 15),
                      label: const Text(
                        'View Receipt',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => _showReceiptBottomSheet(context, order),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReceiptBottomSheet(BuildContext context, OrderEntity order) {
    final dateFormat = DateFormat('MMMM dd, yyyy • hh:mm a');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TRANSACTION RECEIPT',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(color: AppColors.borderSubtle),
              const SizedBox(height: 8),

              _buildReceiptRow(
                'Order ID',
                order.orderId,
                action: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: order.orderId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order ID copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.copy, size: 14, color: AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildReceiptRow('Date', dateFormat.format(order.paymentDate)),
              const SizedBox(height: 8),
              _buildReceiptRow('Payment Method', order.paymentMethod),
              const SizedBox(height: 8),
              _buildReceiptRow(
                'Status',
                'Success (Paid)',
                valueColor: AppColors.success,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: AppColors.borderSubtle),
              ),

              _buildReceiptRow(
                'Subtotal',
                CurrencyFormatter.format(order.subtotal),
              ),
              const SizedBox(height: 6),
              _buildReceiptRow(
                'Shipping Fee',
                order.shippingFee == 0
                    ? 'FREE'
                    : CurrencyFormatter.format(order.shippingFee),
                valueColor: order.shippingFee == 0 ? AppColors.success : null,
              ),
              const SizedBox(height: 6),
              _buildReceiptRow(
                'Estimated Tax',
                CurrencyFormatter.format(order.estimatedTax),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(color: AppColors.borderSubtle),
              ),
              _buildReceiptRow(
                'Total Amount Paid',
                CurrencyFormatter.format(order.totalPaid),
                isBold: true,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Done',
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    Widget? action,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )
              : AppTextStyles.bodyMedium,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: isBold ? 16 : 13,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
            ?action,
          ],
        ),
      ],
    );
  }
}
