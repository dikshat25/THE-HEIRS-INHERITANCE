import 'package:flutter/material.dart';
import 'package:mealmatch/features/app/presentation/Model/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mealmatch/features/app/presentation/pages/recipe_detail_page.dart';
import 'package:mealmatch/features/app/presentation/pages/recipe_search.dart';
import 'package:mealmatch/features/app/presentation/pages/add_recipe.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  final List<Map<String, dynamic>> recipeCategories = [
    {"title": "All Saved Recipes", "count": 14},
    {"title": "All Personal Recipes", "count": 4},
    {"title": "Breakfast", "count": 0},
    {"title": "Lunch", "count": 5},
    {"title": "Dessert", "count": 3},
    {"title": "Drink", "count": 2},
    {"title": "Dinner", "count": 8},
  ];

  void _addNewCollection(String title, int count) {
    setState(() {
      recipeCategories.add({"title": title, "count": count});
    });
  }

  void _showAddCollectionDialog() {
    String newTitle = "";
    String newCount = "0";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Collection"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Collection Title"),
                onChanged: (value) => newTitle = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Number of Recipes"),
                keyboardType: TextInputType.number,
                onChanged: (value) => newCount = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (newTitle.isNotEmpty && int.tryParse(newCount) != null) {
                  _addNewCollection(newTitle, int.parse(newCount));
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCategory(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredRecipePage(
          course: title,
          recipes: [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(

      body: Stack(
        children: [

          Positioned.fill(
            child: Container(
              color: Color(0xffe7fae4),  // Set the background color you want
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 30, top: 30, bottom: 20),
                  child: Row(
                    children: const [
                      Text(
                        'Collections',
                        style: TextStyle(
                          color: Color(0xff0c3934) ,
                          fontWeight: FontWeight.w900,
                          fontSize: 35.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 20),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Passing the 'isFavoritesOnly' flag to RecipeSearchPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeSearchPage(
                                showFavoritesOnly: true, // Updated flag here
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                          width: size.width * .9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, color: Colors.black54.withOpacity(.6), size: 28),
                              const Expanded(
                                child: Text(
                                  'Search your Collections',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Icon(Icons.mic, color: Colors.black54.withOpacity(.6), size: 28),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to the 'add_recipe' page
                          Navigator.pushNamed(context, '/add_recipe');
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 28.0,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'New collection',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )

                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: size.height * .7,
                  child: ListView.builder(
                    itemCount: recipeCategories.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () => _navigateToCategory(
                          context,
                          recipeCategories[index]['title'],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff00E390).withOpacity(.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 80.0,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    recipeCategories[index]['title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xff00473d),
                                    ),
                                  ),
                                  Text(
                                    "${recipeCategories[index]['count']} recipes",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xff00473d),
                              ),
                            ],
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
    );
  }
}

class FilteredRecipePage extends StatelessWidget {
  final String course;
  final List<Recipe> recipes;

  FilteredRecipePage({required this.course, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$course Recipes', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff437069),
      ),
      body: recipes.isEmpty
          ? const Center(
        child: Text(
          'No recipes found',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
        ),
      )
          : ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailPage(recipe: recipes[index]),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.grey, blurRadius: 2, spreadRadius: 0.5),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      recipes[index].imageURL,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      recipes[index].name,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00473D),
                      ),
                    ),
                  ),
                  Text(
                    recipes[index].ingredientCategory,
                    style: const TextStyle(color: Colors.grey, fontSize: 14.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      recipes[index].description,
                      style: const TextStyle(color: Colors.black54, fontSize: 12.0),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}