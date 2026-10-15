# NextGen Wardrobe — Contemporary Wardrobe Essentials

**NextGen Wardrobe** is an editorial, responsive, production-ready e-commerce clothing application engineered in Flutter and Dart, strictly adhering to **Clean Architecture** and **flutter_bloc** state management.

---

## 📱 Quick Run Commands

### 1. Run on Connected Physical Mobile Device
```bash
flutter run -d <device_id>
```
Or simply:
```bash
flutter run -d android
```

### 2. Run with Side-by-Side Web Preview / Hot Reload
```bash
flutter run -d chrome
```

### 3. Run Automated Unit Tests
```bash
flutter test
```

### 4. Code Formatting & Static Analysis
```bash
dart format lib test
flutter analyze
```

---

## 🔑 Predefined Demo Account

For testing and assessment review, a predefined account is configured in `AuthLocalDataSourceImpl`:

| Role | Email | Password | Name |
| :--- | :--- | :--- | :--- |
| **Demo User** | `user@nextgen.com` | `Password123` | Aarav Sharma |

> **Quick Autofill:** On the login screen, a convenient demo chip is provided to fill this account with a single tap.
>
> **Flexible Reviewer Login:** In addition to the demo account above, you can log in with **any valid email address** (e.g. `test@gmail.com`) with any password. The system dynamically creates a session user profile for seamless review.

---

## 🏛️ Clean Architecture & Directory Structure

Dependencies flow strictly inwards through abstractions:
```
Presentation (UI & BLoC) ➔ Domain (Use Cases & Entity Contracts) ➔ Repository Interfaces
                                                                         ▲
Data (Models, Local Data Sources, Repository Implementations) ───────────┘
```

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         # Editorial color palette
│   │   └── app_text_styles.dart    # Luxury typography hierarchy
│   ├── errors/
│   │   └── failures.dart           # Failure models
│   ├── utils/
│   │   ├── currency_formatter.dart # USD price formatting
│   │   └── validators.dart         # Email & password format validation
│   └── widgets/
│       ├── custom_button.dart      # Standardized button variants & loading state
│       ├── custom_text_field.dart  # Form field with active validation
│       ├── empty_state_view.dart   # Reusable editorial empty state
│       ├── error_view.dart         # Retryable error state
│       └── loading_indicator.dart  # Minimalist loading spinner
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/auth_local_data_source.dart (SharedPreferences session)
│   │   │   └── repositories/auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/user_entity.dart
│   │   │   ├── repositories/auth_repository.dart
│   │   │   └── usecases/ (login, get_current_user, logout)
│   │   └── presentation/
│   │       ├── bloc/ (auth_bloc, auth_event, auth_state)
│   │       ├── screens/login_screen.dart
│   │       └── widgets/minimal_profile_chip.dart # Top bar profile chip & bottom sheet
│   │
│   ├── products/
│   │   ├── data/
│   │   │   ├── datasources/product_local_data_source.dart (loads assets/data/products.json)
│   │   │   ├── models/product_model.dart
│   │   │   └── repositories/product_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/product_entity.dart
│   │   │   ├── repositories/product_repository.dart
│   │   │   └── usecases/get_products_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/ (product_bloc, product_event, product_state)
│   │       ├── screens/
│   │       │   ├── catalogue_screen.dart
│   │       │   └── product_details_screen.dart
│   │       └── widgets/
│   │           ├── category_filter_chips.dart
│   │           ├── product_card.dart
│   │           └── search_bar_widget.dart
│   │
│   ├── watchlist/
│   │   ├── data/
│   │   │   ├── datasources/watchlist_local_data_source.dart (in-memory)
│   │   │   └── repositories/watchlist_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── repositories/watchlist_repository.dart
│   │   │   └── usecases/watchlist_usecases.dart (Get, Add, Remove)
│   │   └── presentation/
│   │       ├── bloc/ (watchlist_bloc, watchlist_event, watchlist_state)
│   │       └── screens/watchlist_screen.dart
│   │
│   ├── cart/
│   │   ├── data/
│   │   │   ├── datasources/cart_local_data_source.dart (in-memory)
│   │   │   ├── models/cart_item_model.dart
│   │   │   └── repositories/cart_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/cart_item_entity.dart
│   │   │   ├── repositories/cart_repository.dart
│   │   │   └── usecases/cart_usecases.dart (Get, Add, Remove, UpdateQuantity, Clear)
│   │   └── presentation/
│   │       ├── bloc/ (cart_bloc, cart_event, cart_state)
│   │       ├── screens/cart_screen.dart
│   │       └── widgets/cart_item_tile.dart
│   │
│   ├── payment/
│   │   ├── data/
│   │   │   ├── datasources/payment_local_data_source.dart (in-memory order history)
│   │   │   ├── models/order_model.dart
│   │   │   └── repositories/payment_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/order_entity.dart
│   │   │   ├── repositories/payment_repository.dart
│   │   │   └── usecases/
│   │   │       ├── process_dummy_payment_usecase.dart
│   │   │       └── get_payment_history_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── payment_bloc (checkout & payment flow)
│   │       │   └── payment_history_bloc (past transactions & metrics)
│   │       └── screens/
│   │           ├── checkout_screen.dart
│   │           ├── payment_success_screen.dart
│   │           └── payment_history_screen.dart (4th bottom bar screen)
│   │
│   └── shell/
│       └── presentation/screens/main_navigation_shell.dart (4-tab navigation)
│
├── app.dart
└── main.dart
```

---

## 🔄 BLoC Events & States Architecture

### 1. `AuthBloc`
- **Events:** `AuthEmailChanged`, `AuthPasswordChanged`, `AuthLoginSubmitted`, `AuthLogoutRequested`, `AuthErrorDismissed`.
- **States:** `AuthState(status, email, password, isEmailValid, isPasswordValid, isFormValid, user, errorMessage)`.
- **Validation:** Live regex validation on email and non-empty password; sign-in button remains disabled until both are valid.

### 2. `ProductBloc`
- **Events:** `LoadProducts`, `RefreshProducts`, `FilterCategory(category)`, `SearchProducts(query)`.
- **States:** `ProductState(status, allProducts, filteredProducts, categories, selectedCategory, searchQuery, errorMessage)`.
- **Features:** Instant client-side search and category filtering with responsive grid layout (adaptive column count).

### 3. `WatchlistBloc`
- **Events:** `LoadWatchlist`, `ToggleWatchlist(product)`, `RemoveFromWatchlistEvent(productId)`, `ClearWatchlistFeedback`.
- **States:** `WatchlistState(status, items, favoriteIds, feedbackMessage)`.
- **Cross-Screen Sync:** Uses `favoriteIds` set lookup (`O(1)`) so product cards and details screens instantly reflect updated heart icons.

### 4. `CartBloc`
- **Events:** `LoadCart`, `AddToCart(product, quantity, size, color)`, `UpdateCartQuantity(itemKey, quantity)`, `RemoveFromCart(itemKey)`, `ClearCart`.
- **States:** `CartState(status, items, feedbackMessage, errorMessage)`.
- **Financial Computations:**
  - `subtotal = Σ (price × quantity)`
  - `shippingFee = subtotal >= ₹1500 ? ₹0.00 : ₹150.00`
  - `estimatedTax = subtotal × 0.05`
  - `totalPayable = subtotal + shippingFee + estimatedTax`
- **Badging:** Live item quantity count reflected in bottom navigation bar and catalogue header.

### 5. `PaymentBloc`
- **Events:** `ProcessPaymentSubmitted(items, subtotal, shippingFee, tax, total, method)`, `ResetPayment`.
- **States:** `PaymentInitial`, `PaymentProcessing`, `PaymentSuccessState(OrderEntity)`, `PaymentFailureState`.
- **Security & Idempotency:** Guarded against duplicate double-taps while processing. Generates dummy order format (`NXG-2026-XXXXX`). Emits receipt details and clears cart only upon successful transaction.

### 6. `PaymentHistoryBloc`
- **Events:** `LoadPaymentHistory`, `RecordNewOrder(order)`.
- **States:** `PaymentHistoryState(status, orders, errorMessage)` with computed `totalSpent` and `orderCount`.
- **4th Tab Sync:** Instantly prepends new completed orders upon checkout and powers the 4th bottom navigation tab with receipt inspection.

---

## 🧪 Unit Testing Suite

The project includes thorough unit tests for all business logic, use cases, and BLoC state transitions:

1. **`test/features/auth/auth_bloc_test.dart`**
   - Form field reactivity and validation logic.
   - Rejection of invalid credentials with user-facing message.
   - Successful authentication and UserEntity assignment.
2. **`test/features/cart/cart_bloc_test.dart`**
   - Adding products with size/color attributes.
   - Quantity increments, decrements, and line totals.
   - Automatic free shipping threshold evaluation ($150+).
   - Clear bag resetting all financial calculations.
3. **`test/features/watchlist/watchlist_bloc_test.dart`**
   - Add to wishlist and instant `favoriteIds` indexing.
   - Removing and toggling states.
4. **`test/features/products/product_bloc_test.dart`**
   - Catalogue loading from repository.
   - Combined category + text query filtering.
5. **`test/features/payment/payment_bloc_test.dart`**
   - Empty cart checkout prevention.
   - Order generation and idempotent payment processing.
6. **`test/features/payment/payment_history_bloc_test.dart`**
   - Asynchronous payment history retrieval.
   - Prepended dynamic order history updates and spending calculation.
7. **`test/widget_test.dart`**
   - Application bootstrap and initial screen smoke test.

Run all 29 automated tests:
```bash
flutter test
```

---

## 🎥 Demo-Recording Checklist

When recording a demo video of NextGen:

1. [ ] **Authentication:**
   - Launch app; observe clean brand header and styled form.
   - Type invalid email; notice disabled button and inline hint.
   - Tap "Aarav Sharma" demo chip; notice button enables.
   - Tap "Sign In"; observe loader and transition to Catalogue.
2. [ ] **Product Catalogue & Search:**
   - Scroll through the 12 curated products (Outerwear, Tops, Bottoms, Footwear, Accessories, Dresses).
   - Tap "Outerwear" filter chip; see filtered items and piece count.
   - Type "blazer" or "silk" in search bar; observe real-time filtering.
3. [ ] **Watchlist Synchronization:**
   - Tap heart icon on "Tailored Wool Blend Blazer"; observe SnackBar confirmation and tab bar badge (1).
   - Switch to "Wishlist" tab; verify blazer is present.
   - Tap "Move to Bag" from Wishlist; verify item added to shopping bag.
4. [ ] **Shopping Bag & Sizing:**
   - Tap a product card to open the **Product Details Screen**.
   - Select size (e.g. `L`) and color (e.g. `Deep Navy`).
   - Increase quantity to 2 and tap "Add to Bag".
   - Switch to "Bag" tab; verify line total (`Rs.240 × 2 = Rs.480.00`).
   - Check financial summary breakdown: Subtotal, Free Shipping threshold, Estimated Tax, Total Payable.
5. [ ] **Checkout & Payment:**
   - Tap "Proceed to Checkout".
   - Inspect shipping address and select payment method (Demo Card, Apple Pay, Google Pay).
   - Tap "Pay Now"; observe loading state and idempotency protection.
   - View **Payment Success Screen** with unique Order Reference (`NXG-2026-XXXXX`), payment timestamp, and itemized receipt.
   - Tap "Continue Shopping"; verify shopping bag has been cleared and user returned to catalogue.

---

## ⚙️ Architectural & Persistence Notes

- **Login Session Persistence:** Login credentials and user identity are persisted via `shared_preferences` across app restarts. Tapping "Sign Out" in the profile sheet clears the saved session.
- **Cart & Watchlist State:** Handled in-memory through BLoC state management and use cases as specified in the assessment requirements.
- **Dummy Payment:** Simulates gateway processing latency with idempotency protection (no real payment gateway integration required).
