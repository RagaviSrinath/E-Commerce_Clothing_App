import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../payment/presentation/bloc/payment_history_bloc.dart';
import '../../../payment/presentation/bloc/payment_history_state.dart';
import '../../../payment/presentation/screens/payment_history_screen.dart';
import '../../../products/presentation/screens/catalogue_screen.dart';
import '../../../watchlist/presentation/bloc/watchlist_bloc.dart';
import '../../../watchlist/presentation/bloc/watchlist_state.dart';
import '../../../watchlist/presentation/screens/watchlist_screen.dart';

import '../../../../core/navigation/navigation_controller.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = NavigationController.selectedTabNotifier.value;
    NavigationController.selectedTabNotifier.addListener(
      _onTabControllerChanged,
    );
  }

  @override
  void dispose() {
    NavigationController.selectedTabNotifier.removeListener(
      _onTabControllerChanged,
    );
    super.dispose();
  }

  void _onTabControllerChanged() {
    if (mounted &&
        _currentIndex != NavigationController.selectedTabNotifier.value) {
      setState(() {
        _currentIndex = NavigationController.selectedTabNotifier.value;
      });
    }
  }

  void _navigateToIndex(int index) {
    NavigationController.switchToTab(index);
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      CatalogueScreen(onGoToCart: () => _navigateToIndex(2)),
      WatchlistScreen(onExplore: () => _navigateToIndex(0)),
      CartScreen(onStartShopping: () => _navigateToIndex(0)),
      PaymentHistoryScreen(onStartShopping: () => _navigateToIndex(0)),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _navigateToIndex,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Catalogue',
            ),
            BottomNavigationBarItem(
              icon: BlocBuilder<WatchlistBloc, WatchlistState>(
                builder: (context, state) {
                  return Badge(
                    isLabelVisible: state.count > 0,
                    label: Text('${state.count}'),
                    backgroundColor: AppColors.accent,
                    child: const Icon(Icons.favorite_border),
                  );
                },
              ),
              activeIcon: BlocBuilder<WatchlistBloc, WatchlistState>(
                builder: (context, state) {
                  return Badge(
                    isLabelVisible: state.count > 0,
                    label: Text('${state.count}'),
                    backgroundColor: AppColors.accent,
                    child: const Icon(Icons.favorite),
                  );
                },
              ),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  return Badge(
                    isLabelVisible: state.totalQuantity > 0,
                    label: Text('${state.totalQuantity}'),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.shopping_bag_outlined),
                  );
                },
              ),
              activeIcon: BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  return Badge(
                    isLabelVisible: state.totalQuantity > 0,
                    label: Text('${state.totalQuantity}'),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.shopping_bag),
                  );
                },
              ),
              label: 'Bag',
            ),
            BottomNavigationBarItem(
              icon: BlocBuilder<PaymentHistoryBloc, PaymentHistoryState>(
                builder: (context, state) {
                  return Badge(
                    isLabelVisible: state.orderCount > 0,
                    label: Text('${state.orderCount}'),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.receipt_long_outlined),
                  );
                },
              ),
              activeIcon: BlocBuilder<PaymentHistoryBloc, PaymentHistoryState>(
                builder: (context, state) {
                  return Badge(
                    isLabelVisible: state.orderCount > 0,
                    label: Text('${state.orderCount}'),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.receipt_long),
                  );
                },
              ),
              label: 'Orders',
            ),
          ],
        ),
      ),
    );
  }
}
