class Recipe {
  final String title;
  final String description;
  final String category;
  final String imageURL;
  bool isFavorated;
  final double rating;
  final String recipeName;

  Recipe({
    required this.title,
    required this.description,
    required this.category,
    required this.imageURL,
    this.isFavorated = false,
    required this.rating,
    required this.recipeName,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      imageURL: json['imageURL'] as String,
      isFavorated: json['isFavorated'] as bool? ?? false,
      rating: json['rating'] as double,
      // Parse price
      recipeName: json['recipeName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'imageURL': imageURL,
      'isFavorated': isFavorated,
      'rating': rating,
      'recipeName': recipeName,
    };
  }

  static List<Recipe> fetchRecipes() {
    return [
      Recipe(
        title: 'Classic Pancakes',
        description: 'Fluffy and delicious pancakes with syrup and berries.',
        category: 'Breakfast',
        imageURL: 'assets/Ellipse.png',
        isFavorated: true,
        rating: 5,
        recipeName: 'Pancakes',
      ),
      Recipe(
        title: 'Garden Salad',
        description: 'Fresh mixed greens with a variety of vegetables.',
        category: 'Lunch',
        imageURL: 'assets/Ellipse.png',
        isFavorated: false,
        rating: 4,
        recipeName: 'Salad',
      ),
      Recipe(
        title: 'Spaghetti Carbonara',
        description: 'A creamy pasta with eggs, cheese, and pancetta.',
        category: 'Dinner',
        imageURL: 'assets/Ellipse.png',
        isFavorated: true,
        rating: 4.2,
        recipeName: 'Carbonara',
      ),
      Recipe(
        title: 'Chicken Caesar Wrap',
        description: 'Grilled chicken, romaine, and Caesar dressing in a wrap.',
        category: 'Lunch',
        imageURL: 'assets/Ellipse.png',
        isFavorated: false,
        rating: 2.5,
        recipeName: 'Caesar Wrap',
      ),
      Recipe(
        title: 'Avocado Toast',
        description: 'Toasted bread topped with creamy avocado and spices.',
        category: 'Breakfast',
        imageURL: 'assets/Ellipse.png',
        isFavorated: true,
        rating: 4.9,
        recipeName: 'Avocado Toast',
      ),
      Recipe(
        title: 'Grilled Cheese Sandwich',
        description: 'Crispy grilled bread with melted cheese inside.',
        category: 'Snack',
        imageURL: 'assets/Ellipse.png',
        isFavorated: false,
        rating: 3.6,
        recipeName: 'Grilled Cheese',
      ),
      Recipe(
        title: 'Beef Stir Fry',
        description: 'Savory beef with stir-fried vegetables.',
        category: 'Dinner',
        imageURL: 'assets/Ellipse.png',
        isFavorated: true,
        rating: 3.9,
        recipeName: 'Stir Fry',
      ),
      Recipe(
        title: 'Chicken Soup',
        description: 'Warm and comforting chicken soup with vegetables.',
        category: 'Soup',
        imageURL: 'assets/Ellipse.png',
        isFavorated: false,
        rating: 3.5,
        recipeName: 'Chicken Soup',
      ),
      Recipe(
        title: 'Chocolate Chip Cookies',
        description: 'Soft and chewy cookies loaded with chocolate chips.',
        category: 'Dessert',
        imageURL: 'assets/Ellipse.png',
        isFavorated: true,
        rating: 3.9,
        recipeName: 'Cookies',
      ),
      Recipe(
        title: 'Mango Smoothie',
        description: 'Refreshing mango smoothie with a hint of coconut.',
        category: 'Beverage',
        imageURL: 'assets/Ellipse.png',
        isFavorated: false,
        rating: 5,
        recipeName: 'Smoothie',
      ),
    ];
  }
}