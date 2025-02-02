import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mealmatch/recipe_provider.dart';
import 'package:mealmatch/features/app/presentation/Model/recipe.dart';
import 'package:mealmatch/features/app/presentation/pages/recipe_search.dart';
import 'recipe_detail_page.dart'; // Import the recipe detail page
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // To use Clipboard
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Ensure you import url_launcher

// Assuming you have this Article class
class Article {
  final String title;
  final String description;
  final String imageUrl;
  final String url;

  Article({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.url,
  });
}


class LatestArticlesPage extends StatelessWidget {
  // Updated list of articles
  final List<Article> articles;

  const LatestArticlesPage({super.key, required this.articles});

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
          itemCount: articles.length, // Show all articles
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                // Open the URL when an article is tapped
                launchURL(context, articles[index].url); // Pass context to launchURL
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
                      child: Image.network(
                        articles[index].imageUrl, // Load image from URL
                        height: size.height * 0.25, // Adjust image size
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        articles[index].title,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00473D), // Title color
                        ),
                      ),
                    ),
                    Text(
                      articles[index].description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0), // Space between description and category
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Updated launchURL method accepting BuildContext as parameter
  Future<void> launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      // Open Chrome explicitly (on Android)
      if (Theme.of(context).platform == TargetPlatform.android) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // For iOS or other platforms, open in-app WebView
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    } else {
      print("Could not launch $url");
      // Optionally show a SnackBar to notify the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
      throw 'Could not launch $url';
    }
  }
}



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


// Function to launch URL

  Future<void> launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      // Open Chrome explicitly (on Android)
      if (Theme.of(context).platform == TargetPlatform.android) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // For iOS or other platforms, open in app browser or WebView
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    } else {
      print("Could not launch $url");

      // Show a Snackbar to notify the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );

      // Show a dialog with an option to copy the URL to clipboard
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Unable to open URL'),
            content: Text('Would you like to copy the URL to your clipboard?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Copy the URL to the clipboard
                  Clipboard.setData(ClipboardData(text: url));
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('URL copied to clipboard!')),
                  );
                },
                child: Text('Copy URL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );

      throw 'Could not launch $url';
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

    final List<Article> articles = [
      Article(
        title: 'How to Make Delicious Pasta',
        description: 'Learn the secrets of making the perfect pasta at home.',
        imageUrl: 'https://img.buzzfeed.com/buzzfeed-static/static/2024-08/22/23/asset/8ede7382c757/sub-buzz-530-1724371036-1.jpg?downsize=900:*&output-format=auto&output-quality=auto',
        url: 'https://www.loveandlemons.com/homemade-pasta-recipe/',
      ),
      Article(
        title: 'Healthy Smoothie Recipes',
        description: 'Get fresh and healthy smoothie recipes to start your day.',
        imageUrl: 'https://hips.hearstapps.com/hmg-prod/images/breakfast-overnight-tropical-smoothie-6556c124cbe77.jpg?crop=0.608xw:0.508xh;0.213xw,0.190xh&resize=980:*',
        url: 'https://www.prevention.com/food-nutrition/a20499756/20-super-healthy-smoothie-recipes/',
      ),
      Article(
        title: 'The Ultimate Guide to Baking Bread',
        description: 'Discover tips and tricks for baking soft, fluffy bread.',
        imageUrl: 'https://cdn.shopify.com/s/files/1/0562/3883/3827/files/bread-making-ultimate-guide.jpg?v=1681243881',
        url: 'https://cotswoldflour.com/blogs/baking-resources/bread-making-ultimate-guide?srsltid=AfmBOoqPYAMnGMvvNq-0eJtw7LFlueiCDcsVH1qqAA48TYAa4ohglVqK',
      ),
      Article(
        title: '10 Quick and Easy Salad Recipes',
        description: 'Fresh and vibrant salad ideas for a healthy lifestyle.',
        imageUrl: 'https://imageio.forbes.com/specials-images/imageserve/61798c1f785fc9dee939f84c/The-key-to-making-a-delicious-salad-is-to-include-your-favorite-foods-and-make-sure/960x0.jpg?format=jpg&width=1440',
        url: 'https://www.taste.com.au/galleries/top-10-salad-recipes-you-want-light-filling/nsf6nn9l?page=5',
      ),
      Article(
        title: 'Mastering the Art of Grilling',
        description: 'Grill like a pro with these expert BBQ techniques.',
        imageUrl: 'https://cdn.shopify.com/s/files/1/0550/4637/3553/files/7101_Ribeyes_with_Shrimp_-_A_600x600.jpg?v=1685564380',
        url: 'https://meatking.hk/blogs/cooking-tips/the-art-of-grilling#:~:text=There%20are%20several%20grilling%20techniques,side%20of%20the%20heat%20source.',
      ),
      Article(
        title: 'Decadent Chocolate Desserts',
        description: 'Indulge in rich, mouth-watering chocolate treats.',
        imageUrl: 'https://images.immediate.co.uk/production/volatile/sites/30/2021/07/chocolate-pavlova-ded90a7.jpg?quality=90&webp=true&fit=1100,733',
        url: 'https://www.hindustantimes.com/lifestyle/recipe/world-chocolate-day-2024-5-irresistible-chocolate-dessert-recipes-to-satisfy-your-sweet-tooth-101720328572879.html',
      ),
      Article(
        title: 'Refreshing Summer Drinks You Must Try',
        description: 'Cool off with these easy-to-make summer beverages.',
        imageUrl: 'https://dpmiindia.com/blog/wp-content/uploads/2024/05/Refreshing-Summer-Drinks.jpeg',
        url: 'https://dpmiindia.com/blog/2024/05/30/sipping-tradition-refreshing-summer-drinks-from-around-the-world/',
      ),
      Article(
        title: 'Authentic Mexican Tacos Recipe',
        description: 'Savor the flavors of Mexico with this taco recipe.',
        imageUrl: 'https://s23209.pcdn.co/wp-content/uploads/2019/04/Mexican-Street-TacosIMG_9091.jpg.webp',
        url: 'https://www.yummytummyaarthi.com/mexican-tacos/',
      ),
      Article(
        title: 'Vegan Comfort Food Ideas',
        description: 'Delicious plant-based dishes that satisfy your cravings.',
        imageUrl: 'https://images.immediate.co.uk/production/volatile/sites/30/2017/11/vegan-comfort-food-hero-80465cc.jpg?quality=90&webp=true&resize=375,341',
        url: 'https://www.bbcgoodfood.com/recipes/collection/vegan-comfort-food-recipes',
      ),
      Article(
        title: 'Classic Italian Pizza Dough Recipe',
        description: 'Make authentic, crispy Italian pizza dough at home.',
        imageUrl: 'https://images.101cookbooks.com/PIZZA-DOUGH-RECIPE-h.jpg?w=1200&auto=compress&auto=format',
        url: 'https://ciaoflorentina.com/rustic-pizza-dough-recipe/',
      ),
    ];


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
                _buildArticlesSection(articles, MediaQuery.of(context).size),
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

  Widget _buildArticlesSection(List<Article> articles, Size size) {
    return Container(
      padding: const EdgeInsets.only(left: 33, top: 20, right: 33),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading style
          const Padding(
            padding: EdgeInsets.only(bottom: 16, right: 5),
            child: Text(
              'Our Latest Articles',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00473D),
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Articles Section
          SizedBox(
            height: size.height * 0.9, // Adjust height for preview
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: articles.length,
              itemBuilder: (BuildContext context, int index) {
                final article = articles[index];

                return GestureDetector(
                  onTap: () {
                    // Launch the article URL
                    launchURL(context, article.url);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 4, spreadRadius: 0.5)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            article.imageUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            article.title,
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00473D),
                            ),
                          ),
                        ),
                        Text(
                          article.description,
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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



