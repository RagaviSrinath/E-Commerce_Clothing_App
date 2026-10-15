import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.category,
    required super.imageUrl,
    required super.rating,
    required super.reviewCount,
    required super.sizes,
    required super.colors,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled Product',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'General',
      imageUrl: json['imageUrl'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      sizes:
          (json['sizes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['One Size'],
      colors:
          (json['colors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Standard'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'sizes': sizes,
      'colors': colors,
    };
  }
}
