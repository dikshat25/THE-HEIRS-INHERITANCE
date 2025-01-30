import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mealmatch/features/app/presentation/Model/recipe.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late bool isFavorited;

  @override
  void initState() {
    super.initState();
    isFavorited = widget.recipe.isFavorited;
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorited = prefs.getBool('favorite_${widget.recipe.recipeId}') ?? widget.recipe.isFavorited;
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorited = !isFavorited;
    });
    prefs.setBool('favorite_${widget.recipe.recipeId}', isFavorited);
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Details' , style:TextStyle(color: Colors.white) ,),
        backgroundColor: Color(0xff437069),
        actions: [
          IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                recipe.imageURL,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Recipe Name
            Row(
              children: [
                // Recipe Name
                Expanded(
                  child: Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff00473d),
                    ),
                  ),
                ),
                // Recipe Tags as small tags
                Wrap(
                  spacing: 6.0,  // Spacing between tags
                  runSpacing: 4.0,  // Vertical spacing between lines of tags
                  children: recipe.recipeTags.map((tag) {
                    return Chip(
                      label: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,  // Smaller text size for tags
                          fontWeight: FontWeight.w500,
                          color: Color(0xff9b0707),  // Text color is now white
                        ),
                      ),
                      backgroundColor: Colors.white,  // New background color
                      side: BorderSide(
                        color: Color(0xf3a10404),  // Border color
                        width: 1.5,  // Border width
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),  // Rounded corners for the border
                      ),
                    );
                  }).toList(),
                )

              ],
            ),

            const SizedBox(height: 20),
            // Recipe Description
            Text(
              recipe.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),

            // Additional Recipe Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard('Cuisine', recipe.cuisine),
                _buildInfoCard('Course', recipe.course),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard('Diet', recipe.diet),
                _buildInfoCard('Ingredients', recipe.ingredientCategory),
              ],
            ),




            const SizedBox(height: 30),



            // Recipe Metadata
            Table(
              border: TableBorder.all(
                color: Colors.teal.shade200,
                width: 1.5,
                style: BorderStyle.solid,
              ),
              columnWidths: {
                0: FixedColumnWidth(120),  // Fixed width for the labels
                1: FlexColumnWidth(),      // Flexible width for the values
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Color(0xfff8ebeb), // Background color for the row
                  ),
                  children: [
                    _buildTableCell('Prep Time', isLabel: true),
                    _buildTableCell('${recipe.prepTime} mins'),
                  ],
                ),
                TableRow(
                  decoration: BoxDecoration(
                    color: Color(0xffefdbdb), // Slightly darker background for alternation
                  ),
                  children: [
                    _buildTableCell('Cook Time', isLabel: true),
                    _buildTableCell('${recipe.cookTime} mins'),
                  ],
                ),
                TableRow(
                  decoration: BoxDecoration(
                    color: Color(0xfff8ebeb),
                  ),
                  children: [
                    _buildTableCell('Total Time', isLabel: true),
                    _buildTableCell('${recipe.totalTime} mins'),
                  ],
                ),
              ],
            ),


            const SizedBox(height: 16),

            // Ingredients Section
            const Text(
              'Ingredients:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recipe.ingredientsName.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),  // Increased space for better visual separation
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,  // Align to the start
                    crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
                    children: [
                      // Use a small circle icon for ingredients
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade600,  // Slightly darker teal for the circle
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),  // Space between icon and ingredient text

                      // Ingredient name and quantity displayed with a dash
                      Text(
                        '${recipe.ingredientsName[index]} - ${recipe.ingredientsQuantity[index]}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff0c0c0c),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),





            const SizedBox(height: 16),

            // Instructions Section
            const Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.instructions,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoCard(String title, String value) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        color: Colors.teal.shade50,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0c3934),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff071e1a),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isLabel = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isLabel ? FontWeight.bold : FontWeight.normal,
          color: isLabel ? Color(0xff0c3934) : Color(0xff0c3934),
        ),
      ),
    );
  }



}
