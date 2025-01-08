import 'package:flutter/material.dart';
import 'package:mealmatch/features/app/presentation/Model/recipe.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage();

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Page'),
      ),
    );
  }
}
