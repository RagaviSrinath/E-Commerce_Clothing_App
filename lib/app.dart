import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_colors.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/cart/data/datasources/cart_local_data_source.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/domain/usecases/cart_usecases.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/cart/presentation/bloc/cart_event.dart';
import 'features/payment/data/datasources/payment_local_data_source.dart';
import 'features/payment/data/repositories/payment_repository_impl.dart';
import 'features/payment/domain/usecases/get_payment_history_usecase.dart';
import 'features/payment/domain/usecases/process_dummy_payment_usecase.dart';
import 'features/payment/presentation/bloc/payment_bloc.dart';
import 'features/payment/presentation/bloc/payment_history_bloc.dart';
import 'features/payment/presentation/bloc/payment_history_event.dart';
import 'features/products/data/datasources/product_local_data_source.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/domain/usecases/get_products_usecase.dart';
import 'features/products/presentation/bloc/product_bloc.dart';
import 'features/products/presentation/bloc/product_event.dart';
import 'features/shell/presentation/screens/main_navigation_shell.dart';
import 'features/watchlist/data/datasources/watchlist_local_data_source.dart';
import 'features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'features/watchlist/domain/usecases/watchlist_usecases.dart';
import 'features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'features/watchlist/presentation/bloc/watchlist_event.dart';

class NextGenApp extends StatefulWidget {
  const NextGenApp({super.key});

  @override
  State<NextGenApp> createState() => _NextGenAppState();
}

class _NextGenAppState extends State<NextGenApp> {
  // Data Sources
  late final AuthLocalDataSource _authLocalDataSource;
  late final ProductLocalDataSource _productLocalDataSource;
  late final WatchlistLocalDataSource _watchlistLocalDataSource;
  late final CartLocalDataSource _cartLocalDataSource;
  late final PaymentLocalDataSource _paymentLocalDataSource;

  // Repositories
  late final AuthRepositoryImpl _authRepository;
  late final ProductRepositoryImpl _productRepository;
  late final WatchlistRepositoryImpl _watchlistRepository;
  late final CartRepositoryImpl _cartRepository;
  late final PaymentRepositoryImpl _paymentRepository;

  // Use Cases
  late final LoginUseCase _loginUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GetProductsUseCase _getProductsUseCase;
  late final GetWatchlistUseCase _getWatchlistUseCase;
  late final AddToWatchlistUseCase _addToWatchlistUseCase;
  late final RemoveFromWatchlistUseCase _removeFromWatchlistUseCase;
  late final GetCartUseCase _getCartUseCase;
  late final AddToCartUseCase _addToCartUseCase;
  late final RemoveFromCartUseCase _removeFromCartUseCase;
  late final UpdateCartQuantityUseCase _updateCartQuantityUseCase;
  late final ClearCartUseCase _clearCartUseCase;
  late final ProcessDummyPaymentUseCase _processDummyPaymentUseCase;
  late final GetPaymentHistoryUseCase _getPaymentHistoryUseCase;

  @override
  void initState() {
    super.initState();
    // Initialize Data Sources
    _authLocalDataSource = AuthLocalDataSourceImpl();
    _productLocalDataSource = ProductLocalDataSourceImpl();
    _watchlistLocalDataSource = WatchlistLocalDataSourceImpl();
    _cartLocalDataSource = CartLocalDataSourceImpl();
    _paymentLocalDataSource = PaymentLocalDataSourceImpl();

    // Initialize Repositories
    _authRepository = AuthRepositoryImpl(_authLocalDataSource);
    _productRepository = ProductRepositoryImpl(_productLocalDataSource);
    _watchlistRepository = WatchlistRepositoryImpl(_watchlistLocalDataSource);
    _cartRepository = CartRepositoryImpl(_cartLocalDataSource);
    _paymentRepository = PaymentRepositoryImpl(_paymentLocalDataSource);

    // Initialize Use Cases
    _loginUseCase = LoginUseCase(_authRepository);
    _getCurrentUserUseCase = GetCurrentUserUseCase(_authRepository);
    _logoutUseCase = LogoutUseCase(_authRepository);
    _getProductsUseCase = GetProductsUseCase(_productRepository);
    _getWatchlistUseCase = GetWatchlistUseCase(_watchlistRepository);
    _addToWatchlistUseCase = AddToWatchlistUseCase(_watchlistRepository);
    _removeFromWatchlistUseCase = RemoveFromWatchlistUseCase(
      _watchlistRepository,
    );
    _getCartUseCase = GetCartUseCase(_cartRepository);
    _addToCartUseCase = AddToCartUseCase(_cartRepository);
    _removeFromCartUseCase = RemoveFromCartUseCase(_cartRepository);
    _updateCartQuantityUseCase = UpdateCartQuantityUseCase(_cartRepository);
    _clearCartUseCase = ClearCartUseCase(_cartRepository);
    _processDummyPaymentUseCase = ProcessDummyPaymentUseCase(
      _paymentRepository,
    );
    _getPaymentHistoryUseCase = GetPaymentHistoryUseCase(_paymentRepository);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUseCase: _loginUseCase,
            getCurrentUserUseCase: _getCurrentUserUseCase,
            logoutUseCase: _logoutUseCase,
          )..add(const AuthCheckRequested()),
        ),
        BlocProvider<ProductBloc>(
          create: (_) =>
              ProductBloc(getProductsUseCase: _getProductsUseCase)
                ..add(const LoadProducts()),
        ),
        BlocProvider<WatchlistBloc>(
          create: (_) => WatchlistBloc(
            getWatchlistUseCase: _getWatchlistUseCase,
            addToWatchlistUseCase: _addToWatchlistUseCase,
            removeFromWatchlistUseCase: _removeFromWatchlistUseCase,
          )..add(const LoadWatchlist()),
        ),
        BlocProvider<CartBloc>(
          create: (_) => CartBloc(
            getCartUseCase: _getCartUseCase,
            addToCartUseCase: _addToCartUseCase,
            removeFromCartUseCase: _removeFromCartUseCase,
            updateCartQuantityUseCase: _updateCartQuantityUseCase,
            clearCartUseCase: _clearCartUseCase,
          )..add(const LoadCart()),
        ),
        BlocProvider<PaymentBloc>(
          create: (_) => PaymentBloc(
            processDummyPaymentUseCase: _processDummyPaymentUseCase,
          ),
        ),
        BlocProvider<PaymentHistoryBloc>(
          create: (_) => PaymentHistoryBloc(
            getPaymentHistoryUseCase: _getPaymentHistoryUseCase,
          )..add(const LoadPaymentHistory()),
        ),
      ],
      child: MaterialApp(
        title: 'NextGen Wardrobe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              return const MainNavigationShell();
            }
            return LoginScreen(
              onLoginSuccess: () {
                // Navigation managed reactively by AuthBloc state
              },
            );
          },
        ),
      ),
    );
  }
}
