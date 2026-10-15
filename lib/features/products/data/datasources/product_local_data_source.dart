import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/errors/failures.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getProducts();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  static const String _assetPath = 'assets/data/products.json';

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      final dynamic decoded = json.decode(jsonString);

      if (decoded is! List) {
        throw const ProductFailure('Malformed product data format');
      }

      final products = decoded
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return products;
    } catch (e) {
      if (e is ProductFailure) rethrow;
      throw ProductFailure(
        'Failed to load catalogue products: ${e.toString()}',
      );
    }
  }
}
