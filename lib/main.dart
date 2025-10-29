import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sandwich Shop App',
      home: OrderScreen(maxQuantity: 8),
      //home: Scaffold(
      //  appBar: AppBar(title: const Text('Sandwich Counter')),
      //  body: Center(
      //    child: Row(
      //      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //      children: [
      //        const OrderItemDisplay(5, 'Footlong'),
      //        const OrderItemDisplay(3, 'Panini'),
      //        const OrderItemDisplay(7, 'Wrap'),
      //        Row(
      //          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //          children:[
      //            ElevatedButton(
      //              onPressed: () => print('Add button pressed!'),
      //              child: const Text('Add'),
      //            ),
      //            ElevatedButton(
      //              onPressed: () => print('Remove button pressed!'),
      //              child: const Text('Remove'),
      //            )
      //          ]
      //        )
      //      ],
      //    ),
      //  ),
      //),
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
  int _quantity = 0;

  void _increaseQuantity() {
    if (_quantity < widget.maxQuantity) {
      setState(() => _quantity++);
    }
  }
      
  void _decreaseQuantity() {
    if (_quantity > 0) {
      setState(() => _quantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sandwich Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OrderItemDisplay(
              _quantity,
              'Footlong',
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _increaseQuantity,
                    //() => print('Add button pressed!'),
                    child: const Text('Add'),
                  ),
                  ElevatedButton(
                    onPressed: _decreaseQuantity,
                    //=> print('Remove button pressed!'),
                    child: const Text('Remove'),
                  ),
                ],
              )
            ]
        ),
      ),
    );
  }
}

class OrderItemDisplay extends StatelessWidget {
  final String itemType;
  final int quantity;

  const OrderItemDisplay (this.quantity,this.itemType,{super.key});

  @override
  Widget build(BuildContext context) {
    return Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          color: Colors.cyanAccent,
          alignment: Alignment.center,
          width: 300,
          height: 80,
          child: Text(
            "$quantity $itemType sandwich(es): ${'🥪' * quantity}", 
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
