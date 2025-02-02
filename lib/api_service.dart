import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> getRecipeRecommendations(String ingredient) async {
  final String url = 'http://127.0.0.1:5000';

  final response = await http.post(
    Uri.parse(url),
    body: {'ingredients_name': ingredient},
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);  // Returns a list of recommended recipes
  } else {
    throw Exception('Failed to load recommendations');
  }
}
