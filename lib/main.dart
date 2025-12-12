import 'package:flutter/material.dart';
import 'package:sandwich/repositories/pricing_repository.dart';
import 'package:sandwich/views/app_styles.dart';
import 'package:sandwich/models/cart.dart';
import 'package:sandwich/models/sandwich.dart';
import 'package:sandwich/views/cart_view.dart' as cart_view;
export 'package:sandwich/views/profile_screen.dart';

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

  // New: show editor dialog to edit existing cart item in-place
  Future<void> _showEditDialog(int index) async {
    final modelItem = _cart.items[index];
    int quantity = modelItem.quantity;
    bool isFootlong = modelItem.isFootlong;
    SandwichType sandType = SandwichType.values.firstWhere(
      (t) => Sandwich(type: t, isFootlong: isFootlong, breadType: BreadType.white).name == modelItem.sandwichType,
      orElse: () => SandwichType.veggieDelight,
    );
    BreadType breadType = BreadType.values.firstWhere(
      (b) => b.name == modelItem.bread,
      orElse: () => BreadType.white,
    );
    final TextEditingController notesController = TextEditingController(text: modelItem.notes);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setState2) {
          return AlertDialog(
            title: const Text('Edit item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownMenu<SandwichType>(
                    width: double.infinity,
                    initialSelection: sandType,
                    dropdownMenuEntries: SandwichType.values.map((t) {
                      final s = Sandwich(type: t, isFootlong: true, breadType: BreadType.white);
                      return DropdownMenuEntry<SandwichType>(value: t, label: s.name);
                    }).toList(),
                    onSelected: (v) {
                      if (v != null) setState2(() { sandType = v; });
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Six-inch'),
                      Switch(value: isFootlong, onChanged: (val) => setState2(() => isFootlong = val)),
                      const Text('Footlong'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownMenu<BreadType>(
                    width: double.infinity,
                    initialSelection: breadType,
                    dropdownMenuEntries: BreadType.values.map((b) =>
                      DropdownMenuEntry<BreadType>(value: b, label: b.name)).toList(),
                    onSelected: (v) {
                      if (v != null) setState2(() { breadType = v; });
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) setState2(() => quantity--);
                        },
                      ),
                      Text('$quantity'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: quantity < widget.maxQuantity ? () => setState2(() => quantity++) : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx2).pop(), child: const Text('Cancel')),
              TextButton(onPressed: () {
                // validation
                if (quantity < 1 || quantity > widget.maxQuantity) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Quantity must be 1–${widget.maxQuantity}')),
                  );
                  return;
                }

                // replace item in-place and notify listeners
                final updated = CartItem(
                  sandwichType: Sandwich(type: sandType, isFootlong: isFootlong, breadType: breadType).name,
                  bread: breadType.name,
                  quantity: quantity,
                  notes: notesController.text,
                  isFootlong: isFootlong,
                );
                _cart.updateItemAt(index, updated);
                Navigator.of(ctx2).pop();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item updated')));
              }, child: const Text('Save')),
            ],
          );
        });
      },
    );
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
          // show cart icon in top-right -> navigate to full cart screen
          Semantics(
            label: 'Open cart',
            button: true,
            child: IconButton(
              key: const Key('open_cart'),
              icon: const Icon(Icons.shopping_cart),
              tooltip: 'Open cart',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening cart...'),
                    duration: Duration(milliseconds: 800),
                  ),
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CartScreen(
                      cart: _cart,
                      maxQuantity: widget.maxQuantity,
                    ),
                  ),
                );
              },
            ),
          ),
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
                          'Cart: $count items — Total: \$$total',
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
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${item.quantity}x ${item.bread} ${item.sandwichType}',
                                              style: normalText,
                                            ),
                                          ),

                                          // Quantity controls: decrement, quantity label, increment
                                          Row(
                                            children: [
                                              IconButton(
                                                key: Key('cart_dec_$i'),
                                                tooltip: 'Decrease quantity',
                                                onPressed: () {
                                                  if (item.quantity > 1) {
                                                    _cart.removeOneAt(i);
                                                  } else {
                                                    final removed = CartItem(
                                                      sandwichType: item.sandwichType,
                                                      bread: item.bread,
                                                      quantity: item.quantity,
                                                      notes: item.notes,
                                                      isFootlong: item.isFootlong,
                                                    );
                                                    _cart.removeItemAt(i);
                                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: const Text('Item removed'),
                                                        action: SnackBarAction(
                                                          label: 'Undo',
                                                          onPressed: () {
                                                            _cart.addItem(removed);
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                icon: const Icon(Icons.remove_circle_outline),
                                              ),
                                              Text('${item.quantity}', style: normalText),
                                              IconButton(
                                                key: Key('cart_inc_$i'),
                                                tooltip: 'Increase quantity',
                                                onPressed: item.quantity < widget.maxQuantity
                                                    ? () => _cart.addItem(CartItem(
                                                          sandwichType: item.sandwichType,
                                                          bread: item.bread,
                                                          quantity: 1,
                                                          notes: item.notes,
                                                          isFootlong: item.isFootlong,
                                                        ))
                                                    : null,
                                                icon: const Icon(Icons.add_circle_outline),
                                              ),
                                            ],
                                          ),

                                          // Edit button
                                          IconButton(
                                            key: Key('cart_edit_$i'),
                                            tooltip: 'Edit item',
                                            onPressed: () => _showEditDialog(i),
                                            icon: const Icon(Icons.edit),
                                          ),

                                          // Remove item button: tap immediate + Undo, long-press shows confirmation dialog
                                          IconButton(
                                            key: Key('cart_remove_item_$i'),
                                            tooltip: 'Remove item',
                                            onPressed: () {
                                              final removed = CartItem(
                                                sandwichType: item.sandwichType,
                                                bread: item.bread,
                                                quantity: item.quantity,
                                                notes: item.notes,
                                                isFootlong: item.isFootlong,
                                              );
                                              _cart.removeItemAt(i);
                                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text('Item removed'),
                                                  action: SnackBarAction(
                                                    label: 'Undo',
                                                    onPressed: () {
                                                      _cart.addItem(removed);
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                            onLongPress: () async {
                                              final messenger = ScaffoldMessenger.of(context);
                                              final confirmed = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text('Confirm remove'),
                                                  content: const Text('Remove this item from the cart?'),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Remove')),
                                                  ],
                                                ),
                                              );
                                              if (confirmed == true) {
                                                final removed = CartItem(
                                                  sandwichType: item.sandwichType,
                                                  bread: item.bread,
                                                  quantity: item.quantity,
                                                  notes: item.notes,
                                                  isFootlong: item.isFootlong,
                                                );
                                                _cart.removeItemAt(i);
                                                messenger.hideCurrentSnackBar();
                                                messenger.showSnackBar(
                                                  SnackBar(
                                                    content: const Text('Item removed'),
                                                    action: SnackBarAction(
                                                      label: 'Undo',
                                                      onPressed: () {
                                                        _cart.addItem(removed);
                                                      },
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            icon: const Icon(Icons.delete),
                                          ),
                                        ],
                                      ),
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

// New: full-screen cart screen using the cart_view widget
class CartScreen extends StatefulWidget {
  final Cart cart;
  final int maxQuantity;

  const CartScreen({super.key, required this.cart, this.maxQuantity = 10});

  @override
  State<CartScreen> createState() {
    return _CartScreenState();
  }
}

class _CartScreenState extends State<CartScreen> {
  // helper to show editor dialog inside CartScreen and update cart in-place
  Future<void> showEditDialog(int index) async {
    final modelItem = widget.cart.items[index];
    int quantity = modelItem.quantity;
    bool isFootlong = modelItem.isFootlong;
    SandwichType sandType = SandwichType.values.firstWhere(
      (t) => Sandwich(type: t, isFootlong: isFootlong, breadType: BreadType.white).name == modelItem.sandwichType,
      orElse: () => SandwichType.veggieDelight,
    );
    BreadType breadType = BreadType.values.firstWhere(
      (b) => b.name == modelItem.bread,
      orElse: () => BreadType.white,
    );
    final TextEditingController notesController = TextEditingController(text: modelItem.notes);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setState2) {
          return AlertDialog(
            title: const Text('Edit item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownMenu<SandwichType>(
                    width: double.infinity,
                    initialSelection: sandType,
                    dropdownMenuEntries: SandwichType.values.map((t) {
                      final s = Sandwich(type: t, isFootlong: true, breadType: BreadType.white);
                      return DropdownMenuEntry<SandwichType>(value: t, label: s.name);
                    }).toList(),
                    onSelected: (v) { if (v != null) setState2(() { sandType = v; }); },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Six-inch'),
                      Switch(value: isFootlong, onChanged: (val) => setState2(() => isFootlong = val)),
                      const Text('Footlong'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownMenu<BreadType>(
                    width: double.infinity,
                    initialSelection: breadType,
                    dropdownMenuEntries: BreadType.values.map((b) =>
                      DropdownMenuEntry<BreadType>(value: b, label: b.name)).toList(),
                    onSelected: (v) { if (v != null) setState2(() { breadType = v; }); },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) setState2(() => quantity--);
                        },
                      ),
                      Text('$quantity'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: quantity < widget.maxQuantity ? () => setState2(() => quantity++) : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx2).pop(), child: const Text('Cancel')),
              TextButton(onPressed: () {
                if (quantity < 1 || quantity > widget.maxQuantity) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quantity must be 1–${widget.maxQuantity}')));
                  return;
                }
                final updated = CartItem(
                  sandwichType: Sandwich(type: sandType, isFootlong: isFootlong, breadType: breadType).name,
                  bread: breadType.name,
                  quantity: quantity,
                  notes: notesController.text,
                  isFootlong: isFootlong,
                );
                widget.cart.updateItemAt(index, updated);
                Navigator.of(ctx2).pop();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item updated')));
              }, child: const Text('Save')),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          Semantics(
            label: 'Clear cart',
            button: true,
            child: IconButton(
              key: const Key('cart_clear'),
              tooltip: 'Clear cart',
              icon: const Icon(Icons.delete_forever),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear cart'),
                    content: const Text('Are you sure you want to clear the entire cart?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Clear')),
                    ],
                  ),
                );
                if (confirm == true) {
                  // save exact state for undo
                  final removedItems = widget.cart.items
                      .map((it) => CartItem(
                            sandwichType: it.sandwichType,
                            bread: it.bread,
                            quantity: it.quantity,
                            notes: it.notes,
                            isFootlong: it.isFootlong,
                          ))
                      .toList();
                  widget.cart.clear();
                  messenger.hideCurrentSnackBar();
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('Cart cleared'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          for (final it in removedItems) {
                            widget.cart.addItem(it);
                          }
                        },
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedBuilder(
                animation: widget.cart,
                builder: (context, _) {
                  final items = widget.cart.items
                      .map((it) => cart_view.CartItem(name: it.sandwichType, bread: it.bread, quantity: it.quantity))
                      .toList();

                  return items.isEmpty
                      ? const Center(child: Text('Cart is empty'))
                      : cart_view.CartView(
                          items: items,
                          maxQuantity: widget.maxQuantity,
                          onIncrement: (index) {
                            final modelItem = widget.cart.items[index];
                            if (modelItem.quantity < widget.maxQuantity) {
                              widget.cart.addItem(CartItem(
                                sandwichType: modelItem.sandwichType,
                                bread: modelItem.bread,
                                quantity: 1,
                                notes: modelItem.notes,
                                isFootlong: modelItem.isFootlong,
                              ));
                            } else {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Maximum quantity reached (${widget.maxQuantity})')),
                              );
                            }
                          },
                          onDecrement: (index) {
                            final modelItem = widget.cart.items[index];
                            if (modelItem.quantity > 1) {
                              widget.cart.removeOneAt(index);
                            } else {
                              final removed = CartItem(
                                sandwichType: modelItem.sandwichType,
                                bread: modelItem.bread,
                                quantity: modelItem.quantity,
                                notes: modelItem.notes,
                                isFootlong: modelItem.isFootlong,
                              );
                              widget.cart.removeItemAt(index);
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Item removed'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      widget.cart.addItem(removed);
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          onRemove: (index) {
                            final modelItem = widget.cart.items[index];
                            final removed = CartItem(
                              sandwichType: modelItem.sandwichType,
                              bread: modelItem.bread,
                              quantity: modelItem.quantity,
                              notes: modelItem.notes,
                              isFootlong: modelItem.isFootlong,
                            );
                            widget.cart.removeItemAt(index);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Item removed'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    widget.cart.addItem(removed);
                                  },
                                ),
                              ),
                            );
                          },
                          onLongPressRemove: (index) async {
                            final messenger = ScaffoldMessenger.of(context);
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Confirm remove'),
                                content: const Text('Remove this item from the cart?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Remove')),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              final modelItem = widget.cart.items[index];
                              final removed = CartItem(
                                sandwichType: modelItem.sandwichType,
                                bread: modelItem.bread,
                                quantity: modelItem.quantity,
                                notes: modelItem.notes,
                                isFootlong: modelItem.isFootlong,
                              );
                              widget.cart.removeItemAt(index);
                              messenger.hideCurrentSnackBar();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: const Text('Item removed'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      widget.cart.addItem(removed);
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          onEdit: (index) => showEditDialog(index),
                        );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('back_to_order'),
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Back to Order',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}