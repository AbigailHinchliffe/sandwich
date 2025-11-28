import 'package:flutter/material.dart';
import 'package:sandwich/repositories/pricing_repository.dart';
import 'package:sandwich/views/app_styles.dart';
import 'package:sandwich/models/cart.dart';
import 'package:sandwich/models/sandwich.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sandwich Shop App',
      home: OrderScreen(maxQuantity: 5),
    );
  }
}

class OrderScreen extends StatefulWidget {
  final int maxQuantity;

  const OrderScreen({super.key, this.maxQuantity = 10});

  @override
  State<OrderScreen> createState() {
    return _OrderScreenState();
  }
}

class _OrderScreenState extends State<OrderScreen> {
  late final PricingRepository _pricingRepository;
  late final Cart _cart;
  final TextEditingController _notesController = TextEditingController();

  SandwichType _selectedSandwichType = SandwichType.veggieDelight;
  bool _isFootlong = true;
  BreadType _selectedBreadType = BreadType.white;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _pricingRepository = PricingRepository();
    _cart = Cart(pricingRepo: _pricingRepository);
    _notesController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _addToCart() {
    if (_quantity > 0) {
      final Sandwich sandwich = Sandwich(
        type: _selectedSandwichType,
        isFootlong: _isFootlong,
        breadType: _selectedBreadType,
      );

      setState(() {
        // create a CartItem and add to cart
        _cart.addItem(CartItem(
          sandwichType: sandwich.name,
          bread: _selectedBreadType.name,
          quantity: _quantity,
          notes: _notesController.text,
          isFootlong: _isFootlong,
        ));
      });

      final String sizeText = _isFootlong ? 'footlong' : 'six-inch';
      final String confirmationMessage =
          'Added $_quantity $sizeText ${sandwich.name} sandwich(es) on ${_selectedBreadType.name} bread to cart';

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(confirmationMessage),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  VoidCallback? _getAddToCartCallback() {
    if (_quantity > 0) {
      return _addToCart;
    }
    return null;
  }

  List<DropdownMenuEntry<SandwichType>> _buildSandwichTypeEntries() {
    List<DropdownMenuEntry<SandwichType>> entries = [];
    for (SandwichType type in SandwichType.values) {
      Sandwich sandwich =
          Sandwich(type: type, isFootlong: true, breadType: BreadType.white);
      DropdownMenuEntry<SandwichType> entry = DropdownMenuEntry<SandwichType>(
        value: type,
        label: sandwich.name,
      );
      entries.add(entry);
    }
    return entries;
  }

  List<DropdownMenuEntry<BreadType>> _buildBreadTypeEntries() {
    List<DropdownMenuEntry<BreadType>> entries = [];
    for (BreadType bread in BreadType.values) {
      DropdownMenuEntry<BreadType> entry = DropdownMenuEntry<BreadType>(
        value: bread,
        label: bread.name,
      );
      entries.add(entry);
    }
    return entries;
  }

  String _getCurrentImagePath() {
    final Sandwich sandwich = Sandwich(
      type: _selectedSandwichType,
      isFootlong: _isFootlong,
      breadType: _selectedBreadType,
    );
    return sandwich.image;
  }

  void _onSandwichTypeChanged(SandwichType? value) {
    if (value != null) {
      setState(() {
        _selectedSandwichType = value;
      });
    }
  }

  void _onSizeChanged(bool value) {
    setState(() {
      _isFootlong = value;
    });
  }

  void _onBreadTypeChanged(BreadType? value) {
    if (value != null) {
      setState(() {
        _selectedBreadType = value;
      });
    }
  }

  void _increaseQuantity() {
    setState(() {
      if (_quantity < widget.maxQuantity) _quantity++;
    });
  }

  void _decreaseQuantity() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
      });
    }
  }

  VoidCallback? _getDecreaseCallback() {
    if (_quantity > 0) {
      return _decreaseQuantity;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double totalPrice = _pricingRepository.calculatePrice(
      quantity: _quantity,
      isFootlong: _isFootlong,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sandwich Counter',
          style: heading1,
        ),
        actions: [
          // show cart icon in top-right
          CartIconButton(cart: _cart),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 300,
                child: Image.asset(
                  _getCurrentImagePath(),
                  fit: BoxFit.cover,
                  // improved error handling and placeholder so you don't see the red X
                  errorBuilder: (context, error, stackTrace) {
                    // log the failure so you can see the attempted path in the console
                    debugPrint('Failed to load image: ${_getCurrentImagePath()} -> $error');
                    return Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.broken_image, size: 48, color: Colors.black38),
                          SizedBox(height: 8),
                          Text('Image not available', style: normalText),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              DropdownMenu<SandwichType>(
                width: double.infinity,
                label: const Text('Sandwich Type'),
                textStyle: normalText,
                initialSelection: _selectedSandwichType,
                onSelected: _onSandwichTypeChanged,
                dropdownMenuEntries: _buildSandwichTypeEntries(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Six-inch', style: normalText),
                  Switch(
                    key: const Key('size_switch'),
                    value: _isFootlong,
                    onChanged: _onSizeChanged,
                  ),
                  const Text('Footlong', style: normalText),
                ],
              ),
              const SizedBox(height: 20),
              DropdownMenu<BreadType>(
                width: double.infinity,
                label: const Text('Bread Type'),
                textStyle: normalText,
                initialSelection: _selectedBreadType,
                onSelected: _onBreadTypeChanged,
                dropdownMenuEntries: _buildBreadTypeEntries(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Quantity: ', style: normalText),
                  IconButton(
                    onPressed: _getDecreaseCallback(),
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$_quantity', style: heading1),
                  IconButton(
                    onPressed: _increaseQuantity,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  key: const Key('notes_textfield'),
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Add special instructions (optional)',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              StyledButton(
                onPressed: _getAddToCartCallback(),
                icon: Icons.add_shopping_cart,
                label: 'Add to Cart',
                colour: Colors.green, // fixed named parameter
              ),
              const SizedBox(height: 12),
              // Cart summary: shows number of items and total price, updates automatically
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AnimatedBuilder(
                  animation: _cart,
                  builder: (context, _) {
                    final int count = _cart.itemCount;
                    final String total = _cart.totalPrice().toStringAsFixed(2);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cart: $count items — Total: \$${total}',
                          key: const Key('cart_summary'),
                          style: normalText,
                        ),
                        const SizedBox(height: 8),
                        // list of items with remove buttons
                        SizedBox(
                          height: 120,
                          child: _cart.isEmpty
                              ? const SizedBox.shrink()
                              : ListView.separated(
                                  itemCount: _cart.items.length,
                                  separatorBuilder: (_, __) => const Divider(),
                                  itemBuilder: (context, i) {
                                    final item = _cart.items[i];
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${item.quantity} × ${item.bread} ${item.sandwichType}',
                                            style: normalText,
                                          ),
                                        ),
                                        IconButton(
                                          key: Key('cart_remove_one_$i'),
                                          tooltip: 'Remove one',
                                          onPressed: () => _cart.removeOneAt(i),
                                          icon:
                                              const Icon(Icons.remove_circle_outline),
                                        ),
                                        IconButton(
                                          key: Key('cart_remove_item_$i'),
                                          tooltip: 'Remove item',
                                          onPressed: () => _cart.removeItemAt(i),
                                          icon: const Icon(Icons.delete),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Total: \$${totalPrice.toStringAsFixed(2)}',
                    style: normalText),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class StyledButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color colour;
  final IconData? icon;

  const StyledButton(
      {required this.label,
      required this.onPressed,
      required this.colour,
      this.icon,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colour,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey,
        disabledForegroundColor: Colors.black38,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon),
            const SizedBox(width: 6),
          ],
          Text(label),
        ],
      ),
    );
  }
}

class OrderItemDisplay extends StatelessWidget {
  final int quantity;
  final String itemType;
  final BreadType breadType;
  final String notes;

  const OrderItemDisplay(this.quantity, this.itemType, this.breadType,
      this.notes,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final emojis = List.filled(quantity, '🥪').join();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.cyanAccent,
          alignment: Alignment.center,
          width: 300,
          height: 80,
          child: Text(
            "$quantity ${breadType.name} $itemType sandwich(es): $emojis",
          ),
        ),
        if (notes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              'Note: $notes',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to my sandwich shop!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}