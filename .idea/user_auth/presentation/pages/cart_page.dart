import 'package:flutter/material.dart';

import '../../../../models/recipe.dart';


class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  Future _acceptInpute(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        double screenHeight = MediaQuery.of(context).size.height;
        return Container(
          height: screenHeight * 0.8,

        );
      },
    );
  }

  Future _acceptInput(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        double screenHeight = MediaQuery.of(context).size.height; // Get screen height
        String selectedOption = "Quantity"; // Default selected option
        DateTime? selectedDate; // Declare selectedDate variable

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: screenHeight * 0.8, // Set height to 80% of the screen height
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(
                        Icons.horizontal_rule_rounded,
                        color: const Color(0xff00473d),
                        size: 50.0,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Item Name
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Item Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Item Description
                    SizedBox(
                      height: 40,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Item Description",
                          border: OutlineInputBorder(),
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Options: Quantity, Category, Expiry Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedOption = "Quantity";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedOption == "Quantity"
                                ? Colors.green
                                : Colors.grey,
                          ),
                          child: const Text("Quantity"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedOption = "Category";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedOption == "Category"
                                ? Colors.green
                                : Colors.grey,
                          ),
                          child: const Text("Category"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedOption = "Expiry Date";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedOption == "Expiry Date"
                                ? Colors.green
                                : Colors.grey,
                          ),
                          child: const Text("Expiry Date"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Content Below Based on Selected Option
                    selectedOption == "Quantity"
                        ? _quantityContent()
                        : selectedOption == "Category"
                        ? _categoryContent()
                        : _expiryDateContent(context, selectedDate, setState),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }



// Widget for Quantity Content
  Widget _quantityContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enter Quantity:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Whole Numbers
            Expanded(
              child: Slider(
                min: 0,
                max: 10,
                value: 5,
                onChanged: (double value) {},
              ),
            ),
            // Fractions
            Expanded(
              child: Slider(
                min: 0,
                max: 1,
                divisions: 8,
                value: 0.5,
                onChanged: (double value) {},
              ),
            ),
            // Unit
            Expanded(
              child: DropdownButtonFormField<String>(
                items: ["kg", "g", "lb", "oz"]
                    .map((unit) => DropdownMenuItem(
                  value: unit,
                  child: Text(unit),
                ))
                    .toList(),
                onChanged: (value) {},
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

// Widget for Category Content
  Widget _categoryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Category:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          items: ["Fruit", "Vegetable", "Dairy", "Meat"]
              .map((category) => DropdownMenuItem(
            value: category,
            child: Text(category),
          ))
              .toList(),
          onChanged: (value) {
            print("Selected category: $value");
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // Declare the function only once
  Widget _expiryDateContent(BuildContext context, DateTime? selectedDate, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Expiry Date:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                selectedDate = pickedDate;
              });
            }
          },
          child: const Text(
            "Pick Date",
            style: TextStyle(fontSize: 16, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 10),
        // Display the selected date if available
        if (selectedDate != null)
          Text(
            "Selected Date: ${selectedDate?.toLocal().toString().split(' ')[0]}", // Format the date to show only the date (no time)
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
      ],
    );
  }















  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> recipeCategories = [
      {"title": "All Saved Recipes", "count": 14},
      {"title": "All Personal Recipes", "count": 4},
      {"title": "Breakfast", "count": 0},
      {"title": "Lunch", "count": 5},
      {"title": "Dessert", "count": 3},
      {"title": "Drink", "count": 2},
      {"title": "Dinner", "count": 8},
    ];

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/Shoppinglist.png',
              fit: BoxFit.cover,
            ),
          ),

          // Main Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Container
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        width: size.width * .9,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu, color: Colors.white.withOpacity(.8)),

                            const Expanded(
                              child: TextField(
                                showCursor: false,
                                decoration: InputDecoration(
                                  hintText: '   Search your shopping list...',
                                  hintStyle: TextStyle(color: Colors.white70),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                            Icon(Icons.search, color: Colors.white.withOpacity(.8)),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xff00473d),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                ),


                Container(
                  padding: const EdgeInsets.only(top: 50),
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
                              "Shopping List",
                              style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.w900,
                                color: Color(0xff00473d),
                              ),
                            ),
                            const SizedBox(width: 20.0), // Add some spacing between icon and text
                            Icon(
                              Icons.share_outlined, // Share icon
                              color: Color(0xff00473d), // Match the color of the text
                              size: 30.0, // Same size as the text font
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),


                Container(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        width: size.width * .9,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [

                            Text(
                              "3 items",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff00473d),
                              ),
                            ),
                            SizedBox(width: size.width * .4),
                            Text(
                              "Sort by",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff00473d),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xff00473d),
                              size: 30.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),



                //ITEM ADD BUTTON

                GestureDetector(
                  onTap: () {
                    _acceptInput(context); // Call the function when the button is clicked
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 30, top: 50, bottom: 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          size: 26.0,
                          color: Colors.black,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Add item',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


                // Recipe List
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: size.height * .5,
                  child: ListView.builder(
                    itemCount: recipeCategories.length,
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Color(0xff00E390).withOpacity(.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 80.0,
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        margin: const EdgeInsets.only(bottom: 10, top: 10),
                        width: size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,

                                ),
                                Positioned(
                                  bottom: 5,
                                  left: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
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