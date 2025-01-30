import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mealmatch/recipe_provider.dart';
import 'package:mealmatch/features/app/presentation/Model/recipe.dart';
import 'package:mealmatch/features/app/presentation/pages/recipe_search.dart';
import 'recipe_detail_page.dart'; // Import the recipe detail page

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}


class _HomepageState extends State<Homepage> {


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateCategorySelectionOnScroll);
  }

  // Function to get dynamic greeting message based on the current time
  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Good Morning!";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon!";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening!";
    } else {
      return "Good Night!";
    }
  }

  // Scroll controller for the main content and categories
  final ScrollController _scrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();

  // Selected index for categories
  int selectedIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  // Update selected index as user scrolls
  void _updateCategorySelectionOnScroll() {
    double offset = _scrollController.offset;
    int newIndex = (offset / (MediaQuery.of(context).size.height * 0.8)).round();
    if (newIndex != selectedIndex) {
      setState(() {
        selectedIndex = newIndex;
      });

      // Ensure the selected category is visible in the categories list
      _categoryScrollController.animateTo(
        (selectedIndex - 1).clamp(0, 10) * 80.0, // Adjust based on item width
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    List<Recipe> recipelist = Recipe.fetchRecipes();

    // Recipe categories
    List<String> recipeTypes = [
      'Recommended',
      'Our Latest Articles',
      'Courses',
      'Cuisines'
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFD5ECCE),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic greeting section
          Container(
            padding: const EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  width: size.width * .9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _getGreetingMessage(),
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff00473d),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Search bar with navigation to RecipeSearchPage
          Container(
            padding: const EdgeInsets.only(top: 50, left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecipeSearchPage(),
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
                            'Search Recipes',
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
          const SizedBox(height: 16),

          // Sticky Recipe Categories
          Container(
            color: Color(0xFFD5ECCE),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            height: 50.0,
            child: ListView.builder(
              controller: _categoryScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: recipeTypes.length,
              itemBuilder: (BuildContext context, int index) {
                final isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });

                    // Scroll to the corresponding section
                    _scrollController.animateTo(
                      index * size.height * 0.8,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: isSelected
                          ? const Border(
                        bottom: BorderSide(
                          color: Color(0xff00473d), // Underline color
                          width: 2.0,
                        ),
                      )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        recipeTypes[index],
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w300,
                          color: isSelected
                              ? const Color(0xff00473d)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Content Sections
          Expanded(
            child: ListView(
              controller: _scrollController,
              children: [
                _buildRecommendedSection(recipelist, size),
                _buildArticlesSection(recipelist, size),
                _buildCoursesSection(recipelist, size),
                _buildCuisinesSection(recipelist, size),

              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build separate sections
  Widget _buildRecommendedSection(List<Recipe> recipelist, Size size) {
    return Container(
      height: size.height * 0.45,
      padding: const EdgeInsets.only(left: 16, top: 20, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended',
            style: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00473D),
            ),
          ),
          SizedBox(
            height: size.height * 0.3,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recipelist.length,
              itemBuilder: (BuildContext context, int index) {
                final recipe = recipelist[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailPage(recipe: recipe),
                      ),
                    );
                  },
                  child: Container(
                    width: size.width * 0.7,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xff00473d).withOpacity(.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: size.height * 0.3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              recipe.imageURL,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.ingredientCategory,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  recipe.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }

  // Add this method in the class where you want to build the Articles section
  Widget _buildArticlesSection(List<Recipe> recipelist, Size size) {
    return Container(
      padding: const EdgeInsets.only(left: 33, top: 20, right: 33),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Improved Heading Style
          const Padding(
            padding: EdgeInsets.only(bottom: 16 ,right: 5), // Space between heading and articles
            child: Text(
              'Our Latest Articles',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00473D), // Heading color
                letterSpacing: 1.2, // Added letter spacing for a modern feel
              ),
            ),
          ),

          // Article Preview Section
          SizedBox(
            height: size.height * 0.9, // Adjusted height for preview articles
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: 6, // Displaying only the first 3 articles initially
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to Recipe Detail Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailPage(recipe: recipelist[index]),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10), // Smaller margin between items
                    padding: const EdgeInsets.symmetric(horizontal: 15), // Reduced padding for compactness
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16), // Slightly smaller radius for a more compact look
                      boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 4, spreadRadius: 0.5)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16), // Matching the container's radius
                          child: Image.asset(
                            recipelist[index].imageURL,
                            height: 120, // Smaller image size
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0), // Reduced vertical padding
                          child: Text(
                            recipelist[index].name,
                            style: const TextStyle(
                              fontSize: 14.0, // Smaller font size for article name
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00473D), // Article title color
                            ),
                          ),
                        ),
                        Text(
                          recipelist[index].ingredientCategory,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0, // Smaller font size for ingredient category
                          ),
                        ),
                        const SizedBox(height: 6), // Space between content and description
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            recipelist[index].description,
                            style: const TextStyle(
                              fontSize: 12.0, // Smaller font size for description
                              color: Colors.black54, // Slightly lighter color for description
                            ),
                            maxLines: 2, // Limit the description to 2 lines
                            overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Simpler Show More Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LatestArticlesPage(recipelist: recipelist),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.teal, // Solid color for simplicity
                borderRadius: BorderRadius.circular(20), // Rounded corners
                boxShadow: const [
                  BoxShadow(color: Colors.teal, blurRadius: 4, spreadRadius: 1),
                ],
              ),
              child: Center(
                child: Text(
                  'Show More',
                  style: TextStyle(
                    fontSize: 14.0, // Smaller font size for a more compact look
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesSection(List<Recipe> recipelist, Size size) {
    // List of course categories (e.g., Breakfast, Lunch)
    List<String> courseCategories = ['Breakfast', 'Lunch', 'Dinner', 'Dessert', 'Snack'];

    return Container(
      padding: const EdgeInsets.only(left: 16, top: 60, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading for the Courses section
          const Padding(
            padding: EdgeInsets.only(bottom: 16 , left: 5),
            child: Text(
              'Courses',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00473D),
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Course selection buttons
          SizedBox(
            height: size.height * 0.1, // Adjust height for course buttons
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: courseCategories.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    // Filter recipes based on the selected course category
                    List<Recipe> filteredRecipes = recipelist.where((recipe) {
                      return recipe.course == courseCategories[index]; // Assuming `course` is a field in Recipe
                    }).toList();

                    // Navigate to the filtered recipe page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilteredRecipePage(course: courseCategories[index], recipes: filteredRecipes),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xff0c3934), // Lighter, modern color
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        courseCategories[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600, // Slightly lighter weight for modern look
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuisinesSection(List<Recipe> recipelist, Size size) {
    // List of cuisine categories (e.g., Indian, Italian, Mexican, Thai)
    List<String> cuisineCategories = ['Indian', 'Italian', 'Mexican', 'Thai', 'Chinese'];

    return Container(
      padding: const EdgeInsets.only(left: 16, top: 60, right: 16, bottom: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading for the Cuisines section
          const Padding(
            padding: EdgeInsets.only(bottom: 16, left: 5),
            child: Text(
              'Cuisines',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00473D),
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Cuisine selection buttons
          SizedBox(
            height: size.height * 0.1, // Adjust height for cuisine buttons
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cuisineCategories.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    // Filter recipes based on the selected cuisine
                    List<Recipe> filteredRecipes = recipelist.where((recipe) {
                      return recipe.cuisine == cuisineCategories[index]; // Assuming `cuisine` is a field in Recipe
                    }).toList();

                    // Navigate to the filtered recipe page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilteredRecipePage(
                          course: cuisineCategories[index], // You can use course or cuisine as the title
                          recipes: filteredRecipes,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xff0c3934), // Lighter, modern color
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        cuisineCategories[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600, // Slightly lighter weight for modern look
                        ),
                      ),
                    ),
                  ),
                );
              },
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
        title: Text('$course Recipes', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff437069),
      ),
      body: recipes.isEmpty
          ? Center(
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
              // Navigate to Recipe Detail Page
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
                boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 2, spreadRadius: 0.5)],
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

class LatestArticlesPage extends StatelessWidget {
  final List<Recipe> recipelist;

  const LatestArticlesPage({super.key, required this.recipelist});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Latest Articles',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff437069),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: recipelist.length, // Show all articles
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                // Navigate to RecipeDetailPage when a recipe is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailPage(
                      recipe: recipelist[index], // Pass the recipe to details page
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        recipelist[index].imageURL,
                        height: size.height * 0.25, // Adjust image size
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        recipelist[index].name,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00473D), // Title color
                        ),
                      ),
                    ),
                    Text(
                      recipelist[index].ingredientCategory,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0), // Space between description and category
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        recipelist[index].description, // Show description
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16.0,
                          height: 1.5, // Improve text readability
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


