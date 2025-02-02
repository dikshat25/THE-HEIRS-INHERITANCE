import 'package:flutter/material.dart';
import 'root_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  // State variables for user inputs
  List<String> _selectedDietType = [];
  List<String> _selectedAllergens = [];
  String _otherAllergens = '';
  List<String> _selectedIngredientsToAvoid = [];
  List<String> _customAvoidIngredients = [];
  List<String> _selectedGoals = [];

  // Navigate to RootPage (Skip or Save)
  void _navigateToRootPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RootPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('Assets/loginbackground.jpg'), // Replace with your actual image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // PageView
          PageView(
            onPageChanged: (int page) {
              setState(() {
                currentIndex = page;
              });
            },
            controller: _pageController,
            children: [
              _buildIntroPage(),
              _buildDietPreferencesPage(),
              _buildAllergiesPage(),
              _buildAvoidIngredientsPage(),
              _buildCustomAvoidIngredientsPage(),
              _buildFinalPage(),
            ],
          ),
          // Indicators
          Positioned(
            bottom: 80,
            left: 30,
            child: Row(
              children: _buildIndicator(),
            ),
          ),
          // Next Button
          Positioned(
            bottom: 60,
            right: 30,
            child: IconButton(
              onPressed: () {
                if (currentIndex < 5) {
                  setState(() {
                    currentIndex++;
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  });
                } else {
                  _navigateToRootPage();
                }
              },
              icon: const Icon(Icons.arrow_forward_ios, color: Color(0xff1b534c)),
            ),
          ),
          // Floating Skip Button
          Positioned(
            top: 30,
            right: 20,

            child: ElevatedButton(
              onPressed: _navigateToRootPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                elevation: 5,
              ),
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Color(0xff1b534c),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Intro Page

  Widget _buildIntroPage() {
    return createPage(
      title: '',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "Let's Get Started",
            style: TextStyle(
              fontSize: 33,
              fontWeight: FontWeight.bold,
              color: Color(0xff1b534c),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Update your profile to match your preferences',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xff1b534c),
            ),
          ),
        ],
      ),
    );
  }

  // Other Pages
  Widget _buildDietPreferencesPage() {
    final List<Map<String, String>> dietOptions = [
      {'name': 'Vegetarian', 'image': 'Assets/vegetarian-icon.webp'},
      {'name': 'Non-Vegetarian', 'image': 'Assets/non-vegetarian-icon.webp'},
      {'name': 'Vegan', 'image': 'Assets/vegan.png'},
      {'name': 'No Specific Preference', 'image': 'Assets/other.png'},
    ];

    return createPage(
      title: 'Diet Preferences',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8), // General padding for the page
          child: SingleChildScrollView(
            child: Column(
              children: [
                GridView.builder(
                  physics: const BouncingScrollPhysics(), // Smooth scrolling
                  shrinkWrap: true, // Allow GridView to take only necessary space
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 items per row
                    crossAxisSpacing: 15, // Spacing between columns
                    mainAxisSpacing: 15, // Spacing between rows
                    childAspectRatio: 1, // Square-shaped buttons
                  ),
                  itemCount: dietOptions.length,
                  itemBuilder: (context, index) {
                    final diet = dietOptions[index];
                    final bool isSelected = _selectedDietType.contains(diet['name']);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedDietType.remove(diet['name']);
                          } else {
                            _selectedDietType.add(diet['name']!);
                          }
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isSelected
                                ? [const Color(0xff1b534c), const Color(0xff2d6a60)]
                                : [Colors.white, Colors.grey[200]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(2, 2),
                            ),
                          ],
                          border: Border.all(
                            color: isSelected ? const Color(0xff1b534c) : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Conditionally render image based on the diet type
                            if (diet['name'] != 'No Specific Preference') ...[
                              Image.asset(
                                diet['image']!, // Ensure the correct image path
                                height: 80, // Adjust image size as needed
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 15),
                            ],
                            Text(
                              diet['name']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xff1b534c),
                                fontWeight: FontWeight.w600,
                                fontSize: 18, // Adjust font size
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }




  Widget _buildAllergiesPage() {
    final List<Map<String, String>> allergens = [
      {'name': 'Nuts', 'image': 'Assets/nutss.png'}, // Replace with actual image path
      {'name': 'Dairy', 'image': 'Assets/dairy.png'},
      {'name': 'Eggs', 'image': 'Assets/eggs.png'},
      {'name': 'Gluten', 'image': 'Assets/gluten.png'},
      {'name': 'Soy', 'image': 'Assets/soy.png'},
      {'name': 'Fish', 'image': 'Assets/fish.png'},
    ];

    return createPage(
      title: 'Allergies',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8), // Adjust padding
          child: GridView.builder(
            shrinkWrap: true, // Ensures GridView takes only the space it needs
            physics: const BouncingScrollPhysics(), // Enable smooth scrolling
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 buttons per row
              crossAxisSpacing: 15, // Spacing between columns
              mainAxisSpacing: 15, // Spacing between rows
              childAspectRatio: 1, // Square-shaped buttons
            ),
            itemCount: allergens.length,
            itemBuilder: (context, index) {
              final allergen = allergens[index];
              final bool isSelected = _selectedAllergens.contains(allergen['name']);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedAllergens.remove(allergen['name']);
                    } else {
                      _selectedAllergens.add(allergen['name']!);
                    }
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected
                          ? [const Color(0xff1b534c), const Color(0xff2d6a60)]
                          : [Colors.white, Colors.grey[200]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(2, 2),
                      ),
                    ],
                    border: Border.all(
                      color: isSelected ? const Color(0xff1b534c) : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        allergen['image']!, // Ensure the correct image path
                        height: 80, // Larger image size
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        allergen['name']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xff1b534c),
                          fontWeight: FontWeight.w600,
                          fontSize: 18, // Increased font size
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAvoidIngredientsPage() {
    final List<Map<String, String>> ingredients = [
      {'name': 'Onion', 'image': 'Assets/onion.png'},
      {'name': 'Garlic', 'image': 'Assets/garlic.png'},
      {'name': 'Sugar', 'image': 'Assets/sugar.png'},
      {'name': 'Artificial Sweeteners', 'image': 'Assets/sweetners.png'},
    ];

    return createPage(
      title: 'Avoid Ingredients',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8), // Adjust padding
          child: Column(
            children: [
              // Removed Expanded, keeping GridView inside a column
              // You can set shrinkWrap to true to ensure the GridView only takes the space it needs.
              GridView.builder(
                shrinkWrap: true, // Ensures GridView only takes the space it needs
                physics: const BouncingScrollPhysics(), // Enable smooth scrolling
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 items per row
                  crossAxisSpacing: 15, // Spacing between columns
                  mainAxisSpacing: 15, // Spacing between rows
                  childAspectRatio: 1, // Square-shaped buttons
                ),
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];
                  final bool isSelected = _selectedIngredientsToAvoid.contains(ingredient['name']);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedIngredientsToAvoid.remove(ingredient['name']);
                        } else {
                          _selectedIngredientsToAvoid.add(ingredient['name']!);
                        }
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [const Color(0xff1b534c), const Color(0xff2d6a60)]
                              : [Colors.white, Colors.grey[200]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(2, 2),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected ? const Color(0xff1b534c) : Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            ingredient['image']!, // Ensure the correct image path
                            height: 70, // Larger image size
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            ingredient['name']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xff1b534c),
                              fontWeight: FontWeight.w600,
                              fontSize: 18, // Increased font size
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAvoidIngredientsPage() {
    final TextEditingController _ingredientController = TextEditingController();

    return createPage(
      title: 'Custom Avoid Ingredients',
      child: SingleChildScrollView( // Wrap the entire content in SingleChildScrollView
        child: Column(
          children: [
            // Input field and add button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ingredientController,
                      decoration: InputDecoration(
                        hintText: 'Enter an ingredient',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_ingredientController.text.isNotEmpty) {
                        setState(() {
                          _customAvoidIngredients.add(_ingredientController.text.trim());
                          _ingredientController.clear();
                        });
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Display added ingredients as buttons in a wrap
            _customAvoidIngredients.isEmpty
                ? const Center(
              child: Text(
                'No ingredients added yet.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                spacing: 10, // Space between buttons
                runSpacing: 10, // Space between rows of buttons
                children: _customAvoidIngredients.map((ingredient) {
                  return Chip(
                    label: Text(ingredient),
                    backgroundColor: const Color(0xff1b534c),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onDeleted: () {
                      setState(() {
                        _customAvoidIngredients.remove(ingredient);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalPage() {
    return createPage(
      title: 'Save Preferences',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // General padding for the page
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Larger container with icon on top
              Container(
                padding: const EdgeInsets.all(30.0), // Larger padding for a bigger container
                width: MediaQuery.of(context).size.width * 0.8, // Set a width for the container
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8), // Light background to blend with the image
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Icon on top
                    Icon(
                      Icons.info_outline, // You can choose any icon you like
                      size: 50,
                      color: const Color(0xff1b534c), // Green color to match theme
                    ),
                    const SizedBox(height: 20),
                    // Informing message
                    Text(
                      'You can update your preferences at any time through your Account Settings.',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff1b534c), // Project green shade
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Save and Continue button
                    ElevatedButton(
                      onPressed: _navigateToRootPage,
                      child: const Text(
                        'Save and Continue',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white, // White text color
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(const Color(0xff1b534c)), // Green button
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }







  // Reusable Widgets
  Widget createPage({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff1b534c),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildMultiSelectOptions(
      String title, List<String> options, List<String> selectedOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((option) {
        return CheckboxListTile(
          title: Text(option, style: const TextStyle(color: Color(0xff1b534c))),
          value: selectedOptions.contains(option),
          onChanged: (value) {
            setState(() {
              if (value!) {
                selectedOptions.add(option);
              } else {
                selectedOptions.remove(option);
              }
            });
          },
        );
      }).toList(),
    );
  }

  List<Widget> _buildIndicator() {
    return List<Widget>.generate(
      6,
          (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 10,
        width: index == currentIndex ? 20 : 8,
        margin: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          color: const Color(0xff1b534c),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}

