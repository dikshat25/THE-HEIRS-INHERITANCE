// recipe_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mealmatch/features/app/presentation/Model/recipe.dart'; // Adjust the import path as necessary

class RecipeAPI {
  final String baseUrl;

  RecipeAPI({this.baseUrl = "http://192.168.3.240:5000"}); // You can update the base URL if needed

  Future<List<Recipe>> fetchRecipes(String ingredient) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict'),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {'ingredients_name': ingredient},
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      // Convert the JSON response to a list of Recipe objects
      return responseData.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch recipes');
    }
  }
}
