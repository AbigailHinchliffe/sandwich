import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich/models/cart.dart';
import 'package:sandwich/repositories/pricing_repository.dart';
import 'package:sandwich/views/checkout_screen.dart';

void main() {
  testWidgets('Checkout screen shows order summary', (WidgetTester tester) async {
    final pricingRepo = PricingRepository();
    final cart = Cart(pricingRepo: pricingRepo);
    
    // Add some items to cart
    cart.addItem(CartItem(
      sandwichType: 'Turkey Club',
      bread: 'wheat',
      isFootlong: true,
      quantity: 2,
      notes: '',
    ));
    cart.addItem(CartItem(
      sandwichType: 'Veggie Delight',
      bread: 'white',
      isFootlong: false,
      quantity: 1,
      notes: '',
    ));

    await tester.pumpWidget(MaterialApp(
      home: CheckoutScreen(cart: cart),
    ));

    // Verify title
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Order Summary'), findsOneWidget);

    // Verify items are displayed
    expect(find.text('2x Turkey Club'), findsOneWidget);
    expect(find.text('1x Veggie Delight'), findsOneWidget);

    // Verify total is shown
    expect(find.text('Total:'), findsOneWidget);

    // Verify payment info
    expect(find.text('Payment Method: Card ending in 1234'), findsOneWidget);

    // Verify confirm button
    expect(find.text('Confirm Payment'), findsOneWidget);
  });

  testWidgets('Checkout screen processes payment', (WidgetTester tester) async {
    final pricingRepo = PricingRepository();
    final cart = Cart(pricingRepo: pricingRepo);
    
    cart.addItem(CartItem(
      sandwichType: 'BLT',
      bread: 'italian',
      isFootlong: true,
      quantity: 1,
      notes: '',
    ));

    Map? orderConfirmation;

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckoutScreen(cart: cart),
                ),
              );
              orderConfirmation = result as Map?;
            },
            child: const Text('Go to Checkout'),
          ),
        ),
      ),
    ));

    // Navigate to checkout
    await tester.tap(find.text('Go to Checkout'));
    await tester.pumpAndSettle();

    // Verify we're on checkout screen
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Confirm Payment'), findsOneWidget);

    // Tap confirm payment
    await tester.tap(find.text('Confirm Payment'));
    await tester.pump(); // Start processing

    // Verify loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Processing payment...'), findsOneWidget);

    // Wait for payment to complete
    await tester.pumpAndSettle();

    // Verify we returned to previous screen
    expect(find.text('Go to Checkout'), findsOneWidget);

    // Verify order confirmation data
    expect(orderConfirmation, isNotNull);
    expect(orderConfirmation!['orderId'], isNotNull);
    expect(orderConfirmation!['totalAmount'], isA<double>());
    expect(orderConfirmation!['itemCount'], equals(1));
    expect(orderConfirmation!['estimatedTime'], equals('15-20 minutes'));
  });

  testWidgets('Checkout screen calculates correct total', (WidgetTester tester) async {
    final pricingRepo = PricingRepository();
    final cart = Cart(pricingRepo: pricingRepo);
    
    cart.addItem(CartItem(
      sandwichType: 'Ham & Cheese',
      bread: 'white',
      isFootlong: true,
      quantity: 3,
      notes: '',
    ));

    await tester.pumpWidget(MaterialApp(
      home: CheckoutScreen(cart: cart),
    ));

    final expectedTotal = cart.totalPrice();
    
    // Find the total text in the main body (not in drawer)
    // The main total is styled with heading1 (24pt bold), item price with normalText (16pt)
    expect(find.text('\$${expectedTotal.toStringAsFixed(2)}'), findsAtLeastNWidgets(1));
  });
}