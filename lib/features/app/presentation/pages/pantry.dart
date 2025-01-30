import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mealmatch/features/app/presentation/pages/pantry_search.dart';
import 'package:image_picker/image_picker.dart';


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
  String sortBy = 'Name';
  File? selectedImage;

  TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChecklistItems();
  }

  @override
  void dispose() {
    quantityController.dispose(); // Dispose the controller
    super.dispose();
  }

  Future<void> _loadChecklistItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? checklistJson = prefs.getString('checklistItems');
    if (checklistJson != null) {
      setState(() {
        checklistItems = List<Map<String, dynamic>>.from(jsonDecode(checklistJson));
      });
    }
  }

  Future<void> _saveChecklistItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('checklistItems', jsonEncode(checklistItems));
  }

  void _addItemToChecklist(String itemName, String itemDescription, String text, File? image) {
    setState(() {
      checklistItems.add({
        'itemName': itemName,
        'itemDescription': itemDescription,
        'isChecked': false,
        'quantity': selectedQuantity,
        'category': selectedCategory,
        'fraction': selectedFraction,
        'unit': selectedUnit,
        'timestamp': DateTime.now().toIso8601String(), // Add timestamp
        'image': image, // Store the image if available
      });
      _saveChecklistItems(); // Save the updated list
    });
  }


  void _toggleChecklistItem(int index) {
    setState(() {
      checklistItems[index]['isChecked'] = !checklistItems[index]['isChecked'];
      _saveChecklistItems(); // Save the updated list
    });
  }

  void _removeChecklistItem(int index) {
    setState(() {
      checklistItems.removeAt(index);
      _saveChecklistItems(); // Save the updated list
    });
  }

  void _sortChecklist() {
    setState(() {
      if (sortBy == 'Name') {
        checklistItems.sort((a, b) => a['itemName'].compareTo(b['itemName']));
      } else if (sortBy == 'Category') {
        checklistItems.sort((a, b) => a['category'].compareTo(b['category']));
      } else if (sortBy == 'Quantity') {
        checklistItems.sort((a, b) => a['quantity'].compareTo(b['quantity']));
      } else if (sortBy == 'Last Added First') {
        checklistItems.sort((a, b) {
          var timeA = DateTime.parse(a['timestamp']);
          var timeB = DateTime.parse(b['timestamp']);
          return timeB.compareTo(timeA); // Last added items come first
        });
      }
      _saveChecklistItems(); // Save the updated list
    });
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();

    // Show dialog to choose between camera and gallery
    final option = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Select Image Source",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Choose where to pick the image from.",
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            // Camera button
            TextButton(
              onPressed: () => Navigator.pop(context, 'camera'),
              child: const Text(
                'Camera',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ),
            // Gallery button
            TextButton(
              onPressed: () => Navigator.pop(context, 'gallery'),
              child: const Text(
                'Gallery',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );

    // If option is selected, proceed with picking the image
    if (option != null) {
      final pickedFile = await picker.pickImage(
        source: option == 'camera' ? ImageSource.camera : ImageSource.gallery,
      );

      // If an image is picked, update the selectedImage
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path); // Store the image file
        });
      }
    }
  }



  Future _acceptInput(BuildContext context) {
    final TextEditingController itemNameController = TextEditingController();
    final TextEditingController itemDescriptionController = TextEditingController();
    String selectedOption = 'Quantity'; // Default selected option
    String? selectedQuantity; // To hold the entered quantity
    String? selectedFraction; // To hold the selected fraction
    String? selectedUnit; // To hold the selected unit

    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        double screenHeight = MediaQuery.of(context).size.height;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: screenHeight * 0.8,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add Item Details",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Item Description",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      controller: itemDescriptionController,
                    ),
                    const SizedBox(height: 20),

                    // Options: Quantity, Category
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedOption = 'Quantity';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                            decoration: BoxDecoration(
                              color: selectedOption == 'Quantity'
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.transparent,
                            ),
                            child: Text(
                              "Quantity",
                              style: TextStyle(
                                color: selectedOption == 'Quantity' ? Colors.green : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedOption = 'Category';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                            decoration: BoxDecoration(
                              color: selectedOption == 'Category'
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.transparent,
                            ),
                            child: Text(
                              "Category",
                              style: TextStyle(
                                color: selectedOption == 'Category' ? Colors.green : Colors.black87,
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
                    selectedOption == 'Quantity'
                        ? _quantityContent(setState)
                        : selectedOption == 'Category'
                        ? _categoryContent(setState)
                        : Container(),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Add Item Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (itemNameController.text.isNotEmpty) {
                                _addItemToChecklist(
                                  itemNameController.text,
                                  itemDescriptionController.text,
                                  "$selectedQuantity $selectedFraction $selectedUnit",
                                  selectedImage, // Pass the selected image as part of the checklist item
                                );

                                // Clear inputs
                                itemNameController.clear();
                                itemDescriptionController.clear();
                                selectedQuantity = null;
                                selectedFraction = null;
                                selectedUnit = null;
                                selectedImage = null; // Clear the selected image after adding

                                Navigator.pop(context); // Close the bottom sheet
                              } else {
                                // Show dialog if the item name is empty
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                        "Error",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      content: const Text("Please input an item name."),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Close the dialog
                                          },
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50), // Full width inside the Expanded
                              backgroundColor: Colors.green, // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero, // Rectangular shape
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

                        // Scan to Add Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _pickImage(context); // Call the function to pick an image
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50), // Full width inside the Expanded
                              backgroundColor: const Color(0xFFB71C1C), // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero, // Rectangular shape
                              ),
                            ),
                            child: const Text(
                              "Add Image",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            Navigator.pop(context); // Handle back navigation
          },
        ),
        backgroundColor: Color(0xffe7fae4), // Set app bar background color
        elevation: 0, // Remove the default shadow of the app bar
      ),
      backgroundColor: const Color(0xffe7fae4),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  padding: const EdgeInsets.only(left: 30, top: 20, bottom: 20),
                  child: Row(
                    children: const [
                      Text(
                        'Pantry',
                        style: TextStyle(
                          color: Color(0xff0c3934) ,
                          fontWeight: FontWeight.w900,
                          fontSize: 40.0,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Container(
                  padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PantrySearchPage(checklistItems: checklistItems),
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
                                  'Search your pantry...',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),




                // Item Count and Sort
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
                              "${checklistItems.length} ${checklistItems.length == 1 ? 'item' : 'items'}",
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff00473d),
                              ),
                            ),
                            SizedBox(width: size.width * .09),
                            const Text(
                              "Sort by :",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff00473d),
                              ),
                            ),
                            DropdownButton<String>(
                              value: sortBy,
                              onChanged: (String? newValue) {
                                setState(() {
                                  sortBy = newValue!;
                                  _sortChecklist(); // Apply sorting when changed
                                });
                              },
                              items: <String>['Name', 'Category', 'Quantity', 'Last Added First']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Add Item Button
                GestureDetector(
                  onTap: () {
                    _acceptInput(context); // Add new item to checklist
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 30, top: 50, bottom: 20),
                    child: Row(
                      children: const [
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
                // Checklist
                Container(
                  padding: const EdgeInsets.all(16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: checklistItems.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff00E390).withOpacity(.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 100.0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 10),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Container(
                                width: 80, // Fixed width
                                height: 80, // Fixed height to make it square
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8), // Optional: rounded corners
                                  border: Border.all(
                                    color: Colors.grey, // Border color (optional)
                                    width: 1, // Border width
                                  ),
                                  color: checklistItems[index]['image'] == null
                                      ? Color(0xffe8bbbb) // Pink box if image is null
                                      : null, // No background color if the image is not null
                                ),
                                child: checklistItems[index]['image'] != null
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8), // Ensures image has rounded corners
                                  child: Image.file(
                                    checklistItems[index]['image']!,
                                    fit: BoxFit.cover, // Ensures image fills the container
                                  ),
                                )
                                    : const Icon(
                                  Icons.image, // Placeholder icon when image is null
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),


                            // Left side of the checklist item
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  checklistItems[index]['itemName']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xff00473d),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      '${checklistItems[index]['quantity']?.toString() ?? ""} ${checklistItems[index]['fraction'] ?? ""} ${checklistItems[index]['unit'] ?? ""}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      checklistItems[index]['category'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  checklistItems[index]['itemDescription']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            // Right side with checkbox and delete button
                            Row(
                              children: [
                                // Display the image on the left side if it's available

                                // Checkbox
                                Checkbox(
                                  value: checklistItems[index]['isChecked'],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checklistItems[index]['isChecked'] = value ?? false;
                                      _saveChecklistItems(); // Save the state after change
                                    });
                                  },
                                  activeColor: Colors.green[900],
                                ),
                                // Delete button
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red[900],
                                  onPressed: () {
                                    setState(() {
                                      checklistItems.removeAt(index);
                                      _saveChecklistItems(); // Save after deletion
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
                )

              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for Quantity Content
  Widget _quantityContent(StateSetter setState) {
    TextEditingController quantityController = TextEditingController(text: selectedQuantity); // Set initial value

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
            Expanded(
              child: TextField(
                controller: quantityController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    selectedQuantity = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedFraction,
                items: [
                  "1/8", "1/4", "3/8", "1/2", "5/8", "3/4", "7/8",
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
                  labelText: "Select Unit",
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
  Widget _categoryContent(StateSetter setState) {
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

}