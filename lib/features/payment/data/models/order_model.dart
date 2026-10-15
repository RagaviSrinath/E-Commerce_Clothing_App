import 'package:nextgen/features/cart/data/models/cart_item_model.dart';
import 'package:nextgen/features/cart/domain/entities/cart_item_entity.dart';
import 'package:nextgen/features/payment/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.orderId,
    required super.items,
    required super.subtotal,
    required super.shippingFee,
    required super.estimatedTax,
    required super.totalPaid,
    required super.paymentDate,
    required super.paymentMethod,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] as String,
      items: (json['items'] as List<dynamic>)
          .map<CartItemEntity>(
            (item) => CartItemModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingFee: (json['shippingFee'] as num).toDouble(),
      estimatedTax: (json['estimatedTax'] as num).toDouble(),
      totalPaid: (json['totalPaid'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      paymentMethod: json['paymentMethod'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'items': items.map((i) => CartItemModel.fromEntity(i).toJson()).toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'estimatedTax': estimatedTax,
      'totalPaid': totalPaid,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod,
    };
  }
}
