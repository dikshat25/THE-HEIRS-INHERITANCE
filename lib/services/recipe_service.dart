import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mealmatch/features/app/presentation/Model/recipe.dart';




class RecipeService {
  static const String baseUrl = 'http://192.168.3.240:5000/predict';

  static Future<List<Recipe>> fetchRecipes(String ingredient) async {
    if (ingredient.isEmpty) return [];

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'ingredients_name': ingredient},
      );

      if (response.statusCode == 200) {
        List<dynamic> recipesJson = json.decode(response.body);

        return recipesJson.map((data) => Recipe.fromList(data)).toList();
      } else {
        throw Exception('Failed to fetch recipes');
      }
    } catch (e) {
      print("Error fetching recipes: $e");
      return [];
    }
  }
}
