import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class PantryPage extends StatefulWidget {
  const PantryPage({super.key});

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {



  List<Map<String, dynamic>> checklistItems = [];

  final List<Map<String, dynamic>> shoppingList = [];



  String selectedQuantity = '';
  String? selectedFraction;
  String? selectedUnit = 'unit';
  String selectedCategory = 'None';

  TextEditingController quantityController = TextEditingController();

  // FUNCTION TO ADD ITEMS TO CHECKLIST
  void _addItemToChecklist(String itemName, String itemDescription) {
    setState(() {
      checklistItems.add({
        'itemName': itemName,
        'itemDescription': itemDescription,
        'isChecked': false,
        'quantity': selectedQuantity,
        'category': selectedCategory,
        'fraction': selectedFraction,  // Save selected fraction
        'unit': selectedUnit,
      });
    });
  }


  //ACCEPT USER INPUT TO ADD ITEM
  Future _acceptInput(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    TextEditingController itemNameController = TextEditingController();
    TextEditingController itemDescriptionController = TextEditingController();


    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        double screenHeight =
            MediaQuery
                .of(context)
                .size
                .height; // Get screen height
        String selectedOption = "Quantity"; // Default selected option
        DateTime? selectedDate; // Declare selectedDate variable

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: screenHeight * 0.8,
              // Set height to 80% of the screen height
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Add Item Details",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Item Name
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Item Name",
                        border: OutlineInputBorder(),
                      ),
                      controller: itemNameController,
                    ),

                    const SizedBox(height: 15),

                    // Item Description
                    SizedBox(
                      height: 40,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Item Description",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                        ),
                        controller: itemDescriptionController,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Options: Quantity, Category
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedOption = "Quantity";
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 25),
                            decoration: BoxDecoration(
                              color: selectedOption == "Quantity"
                                  ? Colors.green.withOpacity(
                                  0.2) // Light blue for selected
                                  : Colors
                                  .transparent, // Transparent background for unselected
                            ),
                            child: Text(
                              "Quantity",
                              style: TextStyle(
                                color: selectedOption == "Quantity"
                                    ? Colors.green
                                    : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedOption = "Category";
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 25),
                            decoration: BoxDecoration(
                              color: selectedOption == "Category"
                                  ? Colors.green.withOpacity(
                                  0.2) // Light green for selected
                                  : Colors
                                  .transparent, // Transparent background for unselected
                            ),
                            child: Text(
                              "Category",
                              style: TextStyle(
                                color: selectedOption == "Category"
                                    ? Colors.green
                                    : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    // Content Below Based on Selected Option
                    selectedOption == "Quantity"
                        ? _quantityContent()
                        : selectedOption == "Category"
                        ? _categoryContent()
                        : _expiryDateContent(
                        context, selectedDate, setState),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      // Space the buttons evenly
                      children: [
                        // Add Item Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _addItemToChecklist(
                                  itemNameController.text,
                                  itemDescriptionController.text,
                                );
                              });
                              itemNameController.clear();
                              itemDescriptionController.clear();
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              // Full width inside the Expanded
                              backgroundColor: Colors.green,
                              // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius
                                    .zero, // Rectangular shape
                              ),
                            ),
                            child: const Text(
                              "Add Item",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),
                        // Add space between the buttons

                        // Done Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Done button functionality
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              // Full width inside the Expanded
                              backgroundColor: Color(0xFFB71C1C),
                              // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius
                                    .zero, // Rectangular shape
                              ),
                            ),
                            child: const Text(
                              "Scan to Add",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )

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
              child: TextField(
                controller: quantityController,
                // Attach controller to retain value
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    selectedQuantity = value; // Update the selected quantity
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // Fractions
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedFraction,
                items: [
                  "1/8",
                  "1/4",
                  "3/8",
                  "1/2",
                  "5/8",
                  "3/4",
                  "7/8",
                ].map((fraction) {
                  return DropdownMenuItem<String>(
                    value: fraction,
                    child: Text(fraction),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFraction = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Select Fraction",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // Unit
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedUnit,
                items: ["unit", "kg", "g", "lb", "oz"]
                    .map((unit) =>
                    DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUnit = value;
                  });
                },
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
          value: selectedCategory, // Set the selected category value
          items: ["None", "Fruit", "Vegetable", "Dairy", "Meat"]
              .map((category) =>
              DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              ))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedCategory = value!; // Update the selected category
            });
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _expiryDateContent(BuildContext context, DateTime? selectedDate,
      StateSetter setState) {
    // Create a TextEditingController that holds the selected date
    TextEditingController dateController = TextEditingController(
      text: selectedDate != null
          ? "${selectedDate.toLocal().toString().split(
          ' ')[0]}" // Format the date
          : "",
    );

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
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                selectedDate = pickedDate;
                // Update the TextEditingController text with the new selected date
                dateController.text =
                "${pickedDate.toLocal().toString().split(' ')[0]}";
              });
            }
          },
          child: const Text(
            "Pick Date",
            style: TextStyle(fontSize: 16, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 10),
        // Display the selected date in a text field
        TextField(
          controller: dateController,
          decoration: const InputDecoration(
            labelText: "Expiry Date",
            border: OutlineInputBorder(),
          ),
          readOnly:
          true, // Make it read-only so that the user cannot manually type
        ),
      ],
    );
  }

  // Function to add a new item to Firestore
  Future<void> _addItemToFirestore(String itemName, String itemDescription,
      String quantity, String category, DateTime expiryDate) async {
    try {
      await _firestore.collection('shopping_cart').add({
        'itemName': itemName,
        'itemDescription': itemDescription,
        'quantity': quantity,
        'category': category,
        'expiryDate': expiryDate,
      });
      print("Item added to Firestore");
    } catch (e) {
      print("Error adding item: $e");
    }
  }








  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      backgroundColor: Color(0xffe7fae4),


      body: Stack(
        children: [


          // Main Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

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
                            Icon(Icons.menu,
                                color: Colors.white.withOpacity(.8)),
                            Expanded(
                              child: TextField(
                                showCursor: false,
                                decoration: InputDecoration(
                                  hintText: '   Search your pantry...',
                                  hintStyle: TextStyle(color: Colors.white70),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                            Icon(Icons.search,
                                color: Colors.white.withOpacity(.8)),
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

                //SHARE FUNCTIONALITY
                Container(
                  padding: const EdgeInsets.only(top: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        width: MediaQuery.of(context).size.width * .9,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Pantry",
                              style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.w900,
                                color: Color(0xff00473d),
                              ),
                            ),
                            const SizedBox(width: 13.0),
                            // Dropdown menu for sharing options



                          ],
                        ),
                      ),
                    ],
                  ),
                ),





                //ITEM COUNT AND SORT
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
                              "${checklistItems.length} ${checklistItems
                                  .length == 1 ? 'item' : 'items'}",
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
                    _acceptInput(
                        context); // Call the function when the button is clicked
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.only(left: 30, top: 50, bottom: 20),
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




                // CHECKLIST
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checklist Items List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: checklistItems.length,
                        // Using checklistItems instead of searchResults
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Color(0xff00E390).withOpacity(.16),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 100.0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            margin: const EdgeInsets.only(bottom: 10),
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Left side of the checklist item
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
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Text(
                                            checklistItems[index]['itemName']!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Color(0xff00473d),
                                            ),
                                          ),
                                          const SizedBox(height: 5), // Add space between item name and description
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              // Display Quantity, Fraction, and Unit
                                              Text(
                                                '${checklistItems[index]['quantity']?.toString() ?? ""} ${checklistItems[index]['fraction'] ?? ""} ${checklistItems[index]['unit'] ?? ""}',                                       style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                              ),
                                              const SizedBox(width: 10), // Add space between quantity and category
                                              // Display Category
                                              Text(
                                                ' ${checklistItems[index]['category'] ?? ' '}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),

                                          // Add space between quantity/category and description

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(

                                                checklistItems[index]['itemDescription']!,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Checkbox(
                                      value: checklistItems[index]['isChecked'],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          checklistItems[index]['isChecked'] =
                                              value ?? false;
                                        });
                                      },
                                      activeColor: Colors.green[900],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red[900],
                                      onPressed: () {
                                        setState(() {
                                          checklistItems.removeAt(
                                              index); // Remove item from list
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
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














