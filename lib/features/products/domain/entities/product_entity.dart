import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> sizes;
  final List<String> colors;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.sizes,
    required this.colors,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    category,
    imageUrl,
    rating,
    reviewCount,
    sizes,
    colors,
  ];
}
