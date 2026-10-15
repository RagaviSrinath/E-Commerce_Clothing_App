import 'package:flutter/foundation.dart';

/// Central cross-feature controller for bottom bar navigation tabs.
///
/// Shell Tab indices:
/// - 0: Catalogue
/// - 1: Wishlist
/// - 2: Bag (Shopping Cart)
/// - 3: Orders (Payment History)
class NavigationController {
  static final ValueNotifier<int> selectedTabNotifier = ValueNotifier<int>(0);

  /// Switch the active bottom bar tab in [MainNavigationShell].
  static void switchToTab(int index) {
    selectedTabNotifier.value = index;
  }
}
