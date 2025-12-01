import 'package:flutter/material.dart';
import 'package:sandwich/repositories/pricing_repository.dart';

/// Simple cart item. Uses plain strings to avoid circular imports with main.dart.
class CartItem {
  final String sandwichType; // e.g. "sandwich" or descriptive text
  final String bread; // e.g. "white"
  final bool isFootlong;
  final String notes;
  int quantity;

  CartItem({
    required this.sandwichType,
    required this.bread,
    required this.quantity,
    this.notes = '',
    required this.isFootlong,
  });

  double totalPrice(PricingRepository pricingRepo) {
    return pricingRepo.calculatePrice(quantity: quantity, isFootlong: isFootlong);
  }
}

/// ChangeNotifier cart that holds items and computes totals via PricingRepository.
class Cart extends ChangeNotifier {
  final PricingRepository pricingRepo;
  final List<CartItem> _items = [];

  Cart({required this.pricingRepo});

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  /// Adds an item; merges with existing matching item when appropriate.
  void addItem(CartItem item) {
    final index = _items.indexWhere((existing) =>
        existing.sandwichType == item.sandwichType &&
        existing.bread == item.bread &&
        existing.notes == item.notes &&
        existing.isFootlong == item.isFootlong);
    if (index >= 0) {
      _items[index].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  /// Remove one unit from the item at index. If quantity reaches 0 remove the item.
  void removeOneAt(int index) {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    if (item.quantity > 1) {
      item.quantity -= 1;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  /// Remove full item at index.
  void removeItemAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Total price for the whole cart, using the pricing repository.
  double totalPrice() {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice(pricingRepo));
  }

  /// Replace the item at `index` with `newItem` and notify listeners.
  void updateItemAt(int index, CartItem newItem) {
    if (index < 0 || index >= _items.length) return;
    _items[index] = newItem;
    notifyListeners();
  }
}

/// Small reusable Cart icon button that shows a popup listing items and the total.
/// - Put this in your AppBar.leading (top-left) or wherever you want the cart icon.
/// - Provide an optional checkoutPageBuilder to navigate to a full checkout page.
class CartIconButton extends StatelessWidget {
  final Cart cart;
  final Widget Function(Cart)? checkoutPageBuilder;

  const CartIconButton({super.key, required this.cart, this.checkoutPageBuilder});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        return IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_basket),
              if (!cart.isEmpty)
                Positioned(
                  right: -6,
                  top: -6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      cart.itemCount.toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => _showCartPopup(context),
        );
      },
    );
  }

  void _showCartPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Basket'),
          content: SizedBox(
            width: 320,
            height: 300,
            child: Column(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: cart,
                    builder: (context, _) {
                      if (cart.isEmpty) {
                        return const Center(child: Text('Your basket is empty.'));
                      }
                      return ListView.separated(
                        itemCount: cart.items.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, i) {
                          final item = cart.items[i];
                          return ListTile(
                            title: Text('${item.quantity} × ${item.bread} ${item.sandwichType}'),
                            subtitle: item.notes.isNotEmpty ? Text('Note: ${item.notes}') : null,
                            trailing: Text('\$${item.totalPrice(cart.pricingRepo).toStringAsFixed(2)}'),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: cart,
                  builder: (context, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Items: ${cart.itemCount}'),
                        Text('Total: \$${cart.totalPrice().toStringAsFixed(2)}'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: cart.isEmpty
                  ? null
                  : () {
                      Navigator.of(ctx).pop();
                      if (checkoutPageBuilder != null) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => checkoutPageBuilder!(cart),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Checkout not implemented. Total: \$${cart.totalPrice().toStringAsFixed(2)}')),
                        );
                      }
                    },
              child: const Text('Checkout'),
            ),
          ],
        );
      },
    );
  }
}