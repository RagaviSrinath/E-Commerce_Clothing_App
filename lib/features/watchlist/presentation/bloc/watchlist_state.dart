import 'package:equatable/equatable.dart';
import 'package:nextgen/features/products/domain/entities/product_entity.dart';

enum WatchlistStatus { initial, loading, loaded, failure }

class WatchlistState extends Equatable {
  final WatchlistStatus status;
  final List<ProductEntity> items;
  final Set<String> favoriteIds;
  final String? feedbackMessage;
  final String? errorMessage;

  const WatchlistState({
    this.status = WatchlistStatus.initial,
    this.items = const [],
    this.favoriteIds = const {},
    this.feedbackMessage,
    this.errorMessage,
  });

  bool get isLoading => status == WatchlistStatus.loading;
  bool get isEmpty => items.isEmpty;
  int get count => items.length;

  bool isFavorite(String productId) => favoriteIds.contains(productId);

  WatchlistState copyWith({
    WatchlistStatus? status,
    List<ProductEntity>? items,
    Set<String>? favoriteIds,
    String? feedbackMessage,
    String? errorMessage,
    bool clearFeedback = false,
  }) {
    return WatchlistState(
      status: status ?? this.status,
      items: items ?? this.items,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      feedbackMessage: clearFeedback
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    favoriteIds,
    feedbackMessage,
    errorMessage,
  ];
}
