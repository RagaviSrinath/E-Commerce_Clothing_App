import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;

  const ProductRepositoryImpl(this.localDataSource);

  @override
  Future<List<ProductEntity>> getProducts() {
    return localDataSource.getProducts();
  }
}
