import 'package:flutter/material.dart';
import 'package:mealmatch/features/app/presentation/Model/recipe.dart';
// Assuming your Recipe model is in this file

class RecipeProvider with ChangeNotifier {
  // List to store recipes
  List<Recipe> _recipes = [];

  // Getter to access the list of recipes
  List<Recipe> get recipes => _recipes;

  // Set the list of recipes
  void setRecipes(List<Recipe> recipes) {
    _recipes = recipes;
    notifyListeners();
  }

  // Toggle the 'isFavorited' status of a recipe
  void toggleFavorite(int index) {
    _recipes[index].isFavorited = !_recipes[index].isFavorited;
    notifyListeners(); // Notify listeners to update the UI
  }
}
