import 'package:flutter/material.dart';
import 'package:sandwich/repositories/pricing_repository.dart';
import 'package:sandwich/views/app_styles.dart';
import 'package:sandwich/models/cart.dart';
//import 'package:sandwich/repositories/order_repository.dart';

enum BreadType { white, wheat, multigrain, sourdough, wholemeal }

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
  //late final OrderRepository _orderRepository;
  // local quantity replaces removed OrderRepository
  int _quantity = 0;
  late final PricingRepository _pricingRepository;
  late final Cart _cart;
  final TextEditingController _notesController = TextEditingController();
  bool _isFootlong = true;
  BreadType _selectedBreadType = BreadType.white;
  bool _isToasted = false;

  @override
  void initState() {
    super.initState();
    //_order_repository = OrderRepository(maxQuantity: widget.maxQuantity);
    _pricingRepository = PricingRepository();
    // initialize cart with pricing repo
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

  VoidCallback? _getIncreaseCallback() {
    if (_quantity < widget.maxQuantity) {
      return () => setState(() => _quantity += 1);
    }
    return null;
  }

  VoidCallback? _getDecreaseCallback() {
    if (_quantity > 0) {
      return () => setState(() => _quantity -= 1);
    }
    return null;
  }

  void _onSandwichTypeChanged(bool value) {
    setState(() => _isFootlong = value);
  }

  void _onBreadTypeSelected(BreadType? value) {
    if (value != null) {
      setState(() => _selectedBreadType = value);
    }
  }

  List<DropdownMenuEntry<BreadType>> _buildDropdownEntries() {
    List<DropdownMenuEntry<BreadType>> entries = [];
    for (BreadType bread in BreadType.values) {
      DropdownMenuEntry<BreadType> newEntry = DropdownMenuEntry<BreadType>(
        value: bread,
        label: bread.name,
      );
      entries.add(newEntry);
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final double totalPrice = _pricingRepository.calculatePrice(
      quantity: _quantity,
      isFootlong: _isFootlong,
    );

    final String sandwichType = _isFootlong ? 'footlong' : 'six-inch';
    final String noteForDisplay = _notesController.text;

    return Scaffold(
      appBar: AppBar(
        leading: CartIconButton(cart: _cart),
        title: const Text(
          'Sandwich Counter',
          style: heading1,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OrderItemDisplay(
              _quantity,
              sandwichType,
              _selectedBreadType,
              noteForDisplay,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('six-inch', style: normalText),
                Switch(
                  key: const Key('size_switch'),
                  value: _isFootlong,
                  onChanged: _onSandwichTypeChanged,
                ),
                const Text('footlong', style: normalText),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('untoasted', style: normalText),
                Switch(
                  key: const Key('toast_switch'),
                  value: _isToasted,
                  onChanged: (value) {
                    setState(() => _isToasted = value);
                  },
                ),
                const Text('toasted', style: normalText),
              ],
            ),
            const SizedBox(height: 10),
            DropdownMenu<BreadType>(
              textStyle: normalText,
              initialSelection: _selectedBreadType,
              onSelected: _onBreadTypeSelected,
              dropdownMenuEntries: _buildDropdownEntries(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: TextField(
                key: const Key('notes_textfield'),
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Add a note (e.g., no onions, extra cheese)',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Total: \$${totalPrice.toStringAsFixed(2)}',
                style: normalText,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledButton(
                  onPressed: () {
                    final cb = _getIncreaseCallback();
                    if (cb != null) {
                      cb();
                      // add one of the current selection to the cart
                      _cart.addItem(CartItem(
                        sandwichType: sandwichType,
                        bread: _selectedBreadType.name,
                        quantity: 1,
                        notes: noteForDisplay,
                        isFootlong: _isFootlong,
                      ));
                    }
                  },
                  icon: Icons.add,
                  label: 'Add',
                  colour: Colors.blue,
                ),
                const SizedBox(width: 8),
                StyledButton(
                  onPressed: _getDecreaseCallback(),
                  icon: Icons.remove,
                  label: 'Remove',
                  colour: Colors.red,
                ),
              ],
            ),
          ],
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

  const StyledButton({required this.label, required this.onPressed, required this.colour, this.icon, super.key});
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

  const OrderItemDisplay(this.quantity, this.itemType, this.breadType, this.notes, {super.key});

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
    setState(() {
      
    });
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