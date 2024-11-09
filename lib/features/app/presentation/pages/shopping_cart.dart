import 'package:flutter/material.dart';
import 'package:recipe_app/features/app/presentation/Model/recipe.dart';

class ShoppingCart extends StatelessWidget {
  const ShoppingCart();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: Theme.of(context).primaryColor, 
      ),
      body: Center(
        child: Text(
          'Shopping Cart',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
