import 'package:flutter/material.dart';
import 'package:mealmatch/features/app/presentation/Model/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mealmatch/features/app/presentation/pages/recipe_detail_page.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert'; // For json decoding
import 'package:http/http.dart' as http; // For API calls

class RecipeSearchPage extends StatefulWidget {
  final bool showFavoritesOnly; // Flag to show only favorite recipes

  const RecipeSearchPage({super.key, this.showFavoritesOnly = false});

  @override
  State<RecipeSearchPage> createState() => _RecipeSearchPageState();
}

class _RecipeSearchPageState extends State<RecipeSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredRecipes = [];
  List<String> _recentSearches = [];
  bool _isListening = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isLoading = false;
  String _selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Widget buildTextWithHeading(String heading, String? text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[800]),
        ),
        Text(text ?? 'Not Available', style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
      ],
    );
  }

  Future<void> fetchRecipes(String ingredient) async {
    if (ingredient.isEmpty) {
      setState(() {
        _filteredRecipes = [];
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final String url = 'http://192.168.3.240:5000/predict';
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'ingredients_name': ingredient},
      );
      if (response.statusCode == 200) {
        setState(() {
          _filteredRecipes = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch recipes');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    fetchRecipes(query);
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
      _saveRecentSearches();
    }
  }

  void _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  void _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => setState(() {
        _isListening = _speech.isListening;
      }),
      onError: (error) => setState(() {
        _isListening = false;
      }),
    );
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(
        onResult: (result) => setState(() {
          _searchController.text = result.recognizedWords;
          fetchRecipes(result.recognizedWords);
        }),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Recipes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmitted,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _filteredRecipes = [];
                          });
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                      ),
                      onPressed: _isListening ? _stopListening : _startListening,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _recentSearches.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentSearches.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_recentSearches[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          setState(() {
                            _recentSearches.removeAt(index);
                          });
                          _saveRecentSearches();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          )
              : const SizedBox(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: _filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _filteredRecipes[index];
                return GestureDetector(
                  onTap: () {
                    // Implement navigation to detailed recipe page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailPage(recipe: recipe),
                      ),
                    );
                  },
                    child: ListTile(
                      tileColor: Colors.grey[200], // Background color for the ListTile
                      contentPadding: EdgeInsets.all(16), // Adjust padding as needed
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          recipe['image_url'] != null
                              ? Image.network(
                            recipe['image_url'],
                            width: 800, // Increased image size
                            height: 200, // Increased image size
                            fit: BoxFit.cover,
                          )
                              : const Icon(Icons.image, size: 120), // Placeholder icon if no image
                          SizedBox(height: 10), // Space between image and title
                          Text(
                            recipe['name'] ?? 'No Name',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bold Heading for Ingredients with Larger Font
                          Text(
                            'Ingredients:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[800]),
                          ),
                          // Ensure both ingredients and quantities have the same length
                          if (recipe['ingredients_name'] != null && recipe['ingredients_quantity'] != null)
                            ...List.generate(
                              recipe['ingredients_name'].split(', ').length,
                                  (index) {
                                if (index < recipe['ingredients_quantity'].split(', ').length) {
                                  String ingredient = recipe['ingredients_name'].split(', ')[index];
                                  String quantity = recipe['ingredients_quantity'].split(', ')[index];
                                  return Text('$ingredient - $quantity', style: TextStyle(fontSize: 16));
                                } else {
                                  return Text('${recipe['ingredients_name'].split(', ')[index]} - No quantity available', style: TextStyle(fontSize: 16));
                                }
                              },
                            ),
                          SizedBox(height: 10), // Add more space between sections

                          // Bold Heading for Description
                          Text(
                            'Description:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[800]),
                          ),
                          Text('Description: ${recipe['description'] ?? 'No Description'}', style: TextStyle(fontSize: 16)),

                          SizedBox(height: 10),

                          // Bold Heading for Cuisine, Course, and other sections with new colors and sizes
                          buildTextWithHeading('Cuisine:', recipe['cuisine']),
                          buildTextWithHeading('Course:', recipe['course']),
                          buildTextWithHeading('Diet:', recipe['diet']),
                          buildTextWithHeading('Difficulty:', recipe['difficulty_level']),
                          buildTextWithHeading('Total Time:', '${recipe['total_time']} min'),
                          buildTextWithHeading('Prep Time:', '${recipe['prep_time']} min'),
                          buildTextWithHeading('Cook Time:', '${recipe['cook_time']} min'),

                          SizedBox(height: 10),

                          // Bold Heading for Instructions
                          Text(
                            'Instructions:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[800]),
                          ),
                          Text('Instructions: ${recipe['instructions'] ?? 'No Instructions Available'}', style: TextStyle(fontSize: 16)),

                          SizedBox(height: 10),

                          // Bold Heading for Ingredient Category
                          Text(
                            'Ingredient Category:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[800]),
                          ),
                          Text('Ingredient Category: ${recipe['ingredient_category'] ?? 'Not Available'}', style: TextStyle(fontSize: 16)),

                          SizedBox(height: 30),

                          // Spacer with background color
                          Container(
                            color: Colors.white, // Background color
                            height: 40, // Set height to space out sections
                          )
                        ],
                      ),
                    )









                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
