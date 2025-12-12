import 'package:flutter/material.dart';
import 'package:sandwich/views/profile_screen.dart';
import 'package:sandwich/models/cart.dart';
import 'package:sandwich/main.dart';

class AppDrawer extends StatelessWidget {
  final Cart? cart;
  final int? maxQuantity;

  const AppDrawer({super.key, this.cart, this.maxQuantity});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.orange),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fastfood, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  'Sandwich Shop',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
          ),
          ListTile(
            key: const Key('drawer_order'),
            leading: const Icon(Icons.home),
            title: const Text('Order'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              // Pop until we reach the home screen
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          ListTile(
            key: const Key('drawer_cart'),
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Cart'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              if (cart != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CartScreen(
                      cart: cart!,
                      maxQuantity: maxQuantity ?? 10,
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            key: const Key('drawer_profile'),
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            key: const Key('drawer_about'),
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushNamed(context, '/about');
            },
          ),
        ],
      ),
    );
  }
}
