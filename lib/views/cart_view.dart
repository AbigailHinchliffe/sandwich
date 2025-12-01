import 'package:flutter/material.dart';

// Temporary/placeholder data model.
// If you already have a CartItem model in your project, remove or replace this.
class CartItem {
  final String name;
  final String bread;
  int quantity;

  CartItem({
    required this.name,
    required this.bread,
    required this.quantity,
  });
}

// A concise CartView that lists items and exposes required controls.
// Replace CartItem with your project's model type if needed.
class CartView extends StatelessWidget {
  final List<CartItem> items;
  final void Function(int index) onIncrement;
  final void Function(int index) onDecrement;
  final void Function(int index) onRemove;
  final void Function(int index) onEdit;
  final int maxQuantity;
  final void Function(int index)? onLongPressRemove; // new optional

  const CartView({
    super.key,
    required this.items,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onEdit,
    this.maxQuantity = 10,
    this.onLongPressRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text('Cart is empty'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Summary: quantity, bread, sandwich name
              Expanded(
                child: Text(
                  '${item.quantity}x ${item.bread} ${item.name}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              // Quantity controls
              Row(
                children: [
                  Semantics(
                    label: 'Decrease quantity for item $index',
                    button: true,
                    child: IconButton(
                      key: Key('cart_dec_$index'),
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => onDecrement(index),
                      tooltip: 'Decrease quantity',
                    ),
                  ),
                  Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                  Semantics(
                    label: 'Increase quantity for item $index',
                    button: true,
                    child: IconButton(
                      key: Key('cart_inc_$index'),
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: item.quantity < maxQuantity ? () => onIncrement(index) : null,
                      tooltip: item.quantity < maxQuantity ? 'Increase quantity' : 'Max reached',
                    ),
                  ),
                ],
              ),

              // Edit button
              Semantics(
                label: 'Edit item $index',
                button: true,
                child: IconButton(
                  key: Key('cart_edit_$index'),
                  icon: const Icon(Icons.edit),
                  onPressed: () => onEdit(index),
                  tooltip: 'Edit item',
                ),
              ),

              // Remove button: tap => immediate remove (handled by caller), long-press => optional confirmation dialog
              Semantics(
                label: 'Remove item $index',
                button: true,
                child: IconButton(
                  key: Key('cart_remove_item_$index'),
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => onRemove(index),
                  onLongPress: onLongPressRemove != null ? () => onLongPressRemove!(index) : null,
                  tooltip: 'Remove item',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}