import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({Key? key}) : super(key: key);

  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _recipeNameController = TextEditingController();
  final _instructionsController = TextEditingController();

  String? _selectedCourse;
  String? _selectedDiet;
  List<XFile> _images = [];
  List<Map<String, String>> _ingredients = []; // List to store ingredients and quantities

  final List<String> courses = ['Breakfast', 'Lunch', 'Dinner', 'Dessert', 'Drink'];
  final List<String> diets = ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Gluten-Free'];

  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();

  int selectedIndex = 0;

  Future<void> _pickImages() async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null) {
      setState(() {
        _images.addAll(pickedImages);
      });
    }
  }

  // Add a new ingredient entry
  void _addIngredient() {
    setState(() {
      _ingredients.add({'ingredient': '', 'quantity': ''});
    });
  }

  // Remove an ingredient entry
  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  // Update ingredient or quantity at a specific index
  void _updateIngredient(int index, String field, String value) {
    setState(() {
      _ingredients[index][field] = value;
    });
  }

  void _addInstructions() {
    // Logic for adding instructions (or save recipe logic)

    // Show a Snackbar message when the recipe is saved
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recipe Saved'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xff437069),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  // Save Recipe (Placeholder function)
  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      // Collect the recipe details and proceed
      print("Recipe Saved");
    }
  }

  // Handle instructions section with bullet points
  void _handleEnterKey(String value) {
    // Automatically add bullet point when user presses enter
    if (value.endsWith('\n')) {
      final lines = _instructionsController.text.split('\n');
      String lastLine = lines.last.trim();

      // Check if last line should be a bullet point
      if (lastLine.isEmpty || lastLine.startsWith('- ')) {
        _instructionsController.text = _instructionsController.text + '\n- ';
      } else {
        _instructionsController.text = _instructionsController.text + '\n- ';
      }
      _instructionsController.selection = TextSelection.fromPosition(TextPosition(offset: _instructionsController.text.length));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff437069),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Preview Carousel
                Container(
                  height: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
                  child: _images.isEmpty
                      ? GestureDetector(
                    onTap: _pickImages,
                    child: Center(child: Text('Tap to Upload Images')),
                  )
                      : PageView.builder(
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(File(_images[index].path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Recipe Name
                TextFormField(
                  controller: _recipeNameController,
                  decoration: const InputDecoration(labelText: 'Recipe Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the recipe name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Course Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCourse,
                  hint: const Text('Select Course'),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCourse = newValue;
                    });
                  },
                  items: courses.map((course) {
                    return DropdownMenuItem(
                      value: course,
                      child: Text(course),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a course';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Diet Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedDiet,
                  hint: const Text('Select Diet'),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDiet = newValue;
                    });
                  },
                  items: diets.map((diet) {
                    return DropdownMenuItem(
                      value: diet,
                      child: Text(diet),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a diet type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 50),

                // Ingredients Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _addIngredient,
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            backgroundColor: Color(0xff437069),
                            padding: EdgeInsets.all(10), // Button size
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: Icon(Icons.add, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 10), // Add space between the icon and the title

                        const Text(
                          'Add Ingredients',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff437069),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Table(
                        border: TableBorder.all(
                          color: Colors.transparent,
                          style: BorderStyle.solid,
                          width: 1.0,
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(1.5),
                          1: FlexColumnWidth(1.5),
                          2: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xffE0F7FA), Color(0xffB2EBF2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(
                                    child: Text(
                                      'Ingredient',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xff437069),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(
                                    child: Text(
                                      'Quantity',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xff437069),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(
                                    child: Text(
                                      'Action',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xff437069),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          for (int i = 0; i < _ingredients.length; i++)
                            TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                      child: Material(
                                        elevation: 3, // Adds elevation (shadow)
                                        borderRadius: BorderRadius.circular(12),
                                        child: TextFormField(
                                          initialValue: _ingredients[i]['ingredient'],
                                          style: TextStyle(fontSize: 16, color: Colors.black),
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintText: "Enter ingredient",
                                            hintStyle: TextStyle(color: Colors.grey.shade600),
                                            border: InputBorder.none,
                                          ),
                                          onChanged: (value) => _updateIngredient(i, 'ingredient', value),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                      child: Material(
                                        elevation: 3, // Adds elevation (shadow)
                                        borderRadius: BorderRadius.circular(12),
                                        child: TextFormField(
                                          initialValue: _ingredients[i]['quantity'],
                                          style: TextStyle(fontSize: 16, color: Colors.black),
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintText: "Enter quantity",
                                            hintStyle: TextStyle(color: Colors.grey.shade600),
                                            border: InputBorder.none,
                                          ),
                                          onChanged: (value) => _updateIngredient(i, 'quantity', value),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                      child: IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _removeIngredient(i),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Add space between the icon and the title

                        const Text(
                          'Add Instructions',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff437069),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Instructions TextField Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const SizedBox(height: 8),
                          Material(
                            elevation: 3, // Adds elevation (shadow)
                            borderRadius: BorderRadius.circular(12),
                            child: TextField(
                              controller: _instructionsController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Enter your instructions here...',
                                hintStyle: TextStyle(color: Colors.grey.shade600),
                                border: InputBorder.none,
                              ),
                              onChanged: _handleEnterKey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),



                const SizedBox(height: 40),

                // Save Recipe Button
                Center(
                  child: ElevatedButton(
                    onPressed: _saveRecipe,
                    child: const Text(
                      'Save Recipe',
                      style: TextStyle(
                        fontSize: 18, // Increase font size for better readability
                        fontWeight: FontWeight.bold, // Make text bold for prominence
                        color: Colors.white, // White text for contrast
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff437069), // Button background color
                      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 120.0), // Increased padding for a larger button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0), // Rounded corners
                      ),
                      elevation: 8.0, // Adds shadow for a raised effect
                      shadowColor: Colors.black.withOpacity(0.3), // Light shadow for depth
                    ),
                  ),
                )

              ],
            ),
          ),
        ],
      ),
    );
  }
}


