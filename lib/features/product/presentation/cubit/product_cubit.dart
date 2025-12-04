import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/product_service.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductService _productService;

  ProductCubit(this._productService) : super(ProductInitial());

  Future<void> fetchProducts() async {
    emit(ProductLoading());
    try {
      final products = await _productService.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductFailure(e.toString()));
    }
  }
}
