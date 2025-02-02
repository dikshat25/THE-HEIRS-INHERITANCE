import 'package:flutter/material.dart';
import 'package:mealmatch/features/app/presentation/Model/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mealmatch/features/app/presentation/pages/recipe_detail_page.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class RecipeSerachCPage extends StatefulWidget {
  final bool showFavoritesOnly; // Flag to show only favorite recipes

  const RecipeSerachCPage({super.key, this.showFavoritesOnly = false});

  @override
  State<RecipeSerachCPage> createState() => _RecipeSerachCPageState();
}

class _RecipeSerachCPageState extends State<RecipeSerachCPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _allRecipes = []; // List to hold all recipes
  List<Recipe> _filteredRecipes = []; // List to hold filtered recipes
  String _selectedFilter = "All"; // Currently selected filter option
  List<String> _recentSearches = []; // List to hold recent searches
  bool _isListening = false;
  final stt.SpeechToText _speech = stt.SpeechToText();


  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _loadRecentSearches();
  }


  void _startListening() async {
    print('Start Listening Triggered');
    try {
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
            _filterRecipes(result.recognizedWords);
          }),
        );
      } else {
        print('Speech recognition is not available');
      }
    } catch (e) {
      print('Error during speech initialization: $e');
    }
  }


  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }


  void _loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    List<Recipe> recipes = Recipe.fetchRecipes() ?? [];

    // Load the saved favorite states from SharedPreferences
    for (var recipe in recipes) {
      bool isFavorited = prefs.getBool('favorite_${recipe.recipeId}') ?? false;
      recipe.isFavorited = isFavorited;
    }

    setState(() {
      _allRecipes = recipes;
      _filteredRecipes = List.from(_allRecipes);

      // Filter by favorites if the flag is true
      if (widget.showFavoritesOnly) {
        _filteredRecipes = _allRecipes.where((recipe) => recipe.isFavorited).toList();
      }
    });
  }

  void _saveRecipeFavoriteState(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('favorite_${recipe.recipeId}', recipe.isFavorited);
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

  void _filterRecipes(String query) {
    List<Recipe> results = _allRecipes;

    if (widget.showFavoritesOnly) {
      results = results.where((recipe) => recipe.isFavorited).toList(); // Filter favorited recipes
    }

    if (query.isNotEmpty) {
      List<String> queryWords = query.toLowerCase().split(' ');

      results = results.where((recipe) {
        String recipeNameLower = recipe.name?.toLowerCase() ?? '';
        String recipeDescriptionLower = recipe.description?.toLowerCase() ?? '';

        return queryWords.every((word) =>
        recipeNameLower.contains(word) || recipeDescriptionLower.contains(word));
      }).toList();
    }

    setState(() {
      _filteredRecipes = results;
    });
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
    _filterRecipes(query);
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
    _saveRecentSearches();
  }

  void _filterBySelectedFilter() {
    setState(() {
      if (_selectedFilter == "All") {
        _filteredRecipes = List.from(_allRecipes);
      } else {
        _filteredRecipes = _allRecipes.where((recipe) {
          String diet = recipe.diet?.toLowerCase() ?? '';
          String cuisine = recipe.cuisine?.toLowerCase() ?? '';
          String course = recipe.course?.toLowerCase() ?? '';
          return diet == _selectedFilter.toLowerCase() ||
              cuisine == _selectedFilter.toLowerCase() ||
              course == _selectedFilter.toLowerCase();
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Recipes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff437069),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.filter_list_rounded,
              color: Colors.white,
            ),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
                _filterBySelectedFilter();
              });
            },
            itemBuilder: (context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem(value: "All", child: Text("All")),
                const PopupMenuItem(value: "Vegetarian", child: Text("Vegetarian")),
                const PopupMenuItem(value: "Vegan", child: Text("Vegan")),
                const PopupMenuItem(value: "Gluten-Free", child: Text("Gluten-Free")),
                const PopupMenuItem(value: "American", child: Text("American")),
                const PopupMenuItem(value: "Italian", child: Text("Italian")),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _filterRecipes(value),
                    onSubmitted: _onSearchSubmitted,
                    decoration: InputDecoration(
                      hintText: 'Search recipes...',
                      prefixIcon: const Icon(Icons.search, color: Colors.black54),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.black54),
                              onPressed: () {
                                _searchController.clear();
                                _filterRecipes('');
                              },
                            ),
                          IconButton(
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: Colors.black54,
                            ),
                            onPressed: _isListening ? _stopListening : _startListening,
                          ),
                        ],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                // Display the message based on `_isListening` state
                if (_isListening)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Listening... Speak now!',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
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
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentSearches.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_recentSearches[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel_outlined, color: Color(0xFF9B0707)),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Results',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: MediaQuery.of(context).size.height - 200, // Adjust the height to fit the remaining screen
                    child: ListView.builder(
                      itemCount: _filteredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _filteredRecipes[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailPage(recipe: recipe),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      recipe.imageURL, // Use local asset path
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recipe.name ?? 'No Name',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          recipe.description ?? 'No Description',
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      recipe.isFavorited ? Icons.favorite : Icons.favorite_border,
                                      color: recipe.isFavorited ? Colors.red : Colors.black,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        recipe.isFavorited = !recipe.isFavorited;
                                        _saveRecipeFavoriteState(recipe);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}