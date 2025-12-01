import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich/models/cart.dart';
import 'package:sandwich/repositories/pricing_repository.dart';

void main() {
  late PricingRepository pricing;
  late Cart cart;

  setUp(() {
    pricing = PricingRepository();
    cart = Cart(pricingRepo: pricing);
  });

  test('adds items and updates itemCount / isEmpty', () {
    expect(cart.isEmpty, isTrue);
    expect(cart.itemCount, 0);

    cart.addItem(CartItem(
      sandwichType: 'footlong',
      bread: 'white',
      quantity: 1,
      isFootlong: true,
    ));

    expect(cart.isEmpty, isFalse);
    expect(cart.itemCount, 1);
    expect(cart.items.length, 1);
  });

  test('merges items with same properties', () {
    cart.addItem(CartItem(
      sandwichType: 'footlong',
      bread: 'white',
      quantity: 1,
      isFootlong: true,
    ));
    cart.addItem(CartItem(
      sandwichType: 'footlong',
      bread: 'white',
      quantity: 2,
      isFootlong: true,
    ));

    expect(cart.items.length, 1);
    expect(cart.items.first.quantity, 3);
    expect(cart.itemCount, 3);
  });

  test('removeOneAt decrements quantity and removes when zero', () {
    cart.addItem(CartItem(
      sandwichType: 'six-inch',
      bread: 'wheat',
      quantity: 2,
      isFootlong: false,
    ));

    expect(cart.items.length, 1);
    expect(cart.items.first.quantity, 2);

    cart.removeOneAt(0);
    expect(cart.items.first.quantity, 1);
    expect(cart.items.length, 1);

    cart.removeOneAt(0);
    expect(cart.items.length, 0);
    expect(cart.isEmpty, isTrue);
  });

  test('removeItemAt removes full item', () {
    cart.addItem(CartItem(
      sandwichType: 'six-inch',
      bread: 'wheat',
      quantity: 1,
      isFootlong: false,
    ));
    cart.addItem(CartItem(
      sandwichType: 'footlong',
      bread: 'white',
      quantity: 1,
      isFootlong: true,
    ));

    expect(cart.items.length, 2);
    cart.removeItemAt(0);
    expect(cart.items.length, 1);
    expect(cart.items.first.sandwichType, 'footlong');
  });

  test('clear empties the cart and totalPrice becomes zero', () {
    cart.addItem(CartItem(
      sandwichType: 'six-inch',
      bread: 'wheat',
      quantity: 2,
      isFootlong: false,
    ));
    cart.addItem(CartItem(
      sandwichType: 'footlong',
      bread: 'white',
      quantity: 1,
      isFootlong: true,
    ));

    expect(cart.isEmpty, isFalse);
    expect(cart.totalPrice(), greaterThan(0));

    cart.clear();
    expect(cart.isEmpty, isTrue);
    expect(cart.totalPrice(), 0.0);
  });

  test('totalPrice uses PricingRepository rates', () {
    // PricingRepository in this project: six-inch = 7.00, footlong = 11.00
    cart.addItem(CartItem(
      sandwichType: 'six-inch',
      bread: 'wheat',
      quantity: 2,
      isFootlong: false,
    )); // 2 * 7.00 = 14.00

    cart.addItem(CartItem(
      sandwichType: 'footlong',
      bread: 'white',
      quantity: 3,
      isFootlong: true,
    )); // 3 * 11.00 = 33.00

    final total = cart.totalPrice();
    expect(total, closeTo(47.0, 0.0001));
  });

  // New: updateItemAt replaces an item and totalPrice reflects changes
  test('updateItemAt replaces item and updates totalPrice', () {
    cart.addItem(CartItem(
      sandwichType: 'footlong',
      bread: 'white',
      quantity: 1,
      isFootlong: true,
    ));
    expect(cart.items.length, 1);
    expect(cart.totalPrice(), closeTo(11.0, 0.0001));

    // update to quantity 3
    cart.updateItemAt(0, CartItem(
      sandwichType: 'footlong',
      bread: 'white',
      quantity: 3,
      isFootlong: true,
    ));

    expect(cart.items[0].quantity, 3);
    expect(cart.totalPrice(), closeTo(33.0, 0.0001));
  });

  // New: invalid index for updateItemAt is ignored (no throw, no change)
  test('updateItemAt with invalid index does nothing', () {
    cart.addItem(CartItem(
      sandwichType: 'six-inch',
      bread: 'wheat',
      quantity: 1,
      isFootlong: false,
    ));
    final before = cart.items.map((e) => e.quantity).toList();
    cart.updateItemAt(-1, CartItem(
      sandwichType: 'six-inch',
      bread: 'wheat',
      quantity: 5,
      isFootlong: false,
    ));
    cart.updateItemAt(10, CartItem(
      sandwichType: 'six-inch',
      bread: 'wheat',
      quantity: 5,
      isFootlong: false,
    ));
    final after = cart.items.map((e) => e.quantity).toList();
    expect(after, before);
  });
}