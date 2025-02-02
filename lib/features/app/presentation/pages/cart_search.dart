import 'package:flutter/material.dart';

class CartSearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> checklistItems;

  const CartSearchPage({super.key, required this.checklistItems});

  @override
  State<CartSearchPage> createState() => _CartSearchPageState();
}

class _CartSearchPageState extends State<CartSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    print(widget.checklistItems);
    _filteredItems = List.from(widget.checklistItems); // Initially show all items
  }

  void _filterCartItems(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = List.from(widget.checklistItems); // Reset to all items when query is empty
      });
      return;
    }

    List<String> queryWords = query.toLowerCase().split(' ');

    final results = widget.checklistItems.where((item) {
      String itemName = item['itemName']?.toLowerCase() ?? ''; // Use itemName from checklistItems
      return queryWords.any((word) => itemName.contains(word));
    }).toList();

    setState(() {
      _filteredItems = results;
    });
  }

  void _saveCartItems() async {
    // Code to save the cart items, for example, using SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Cart', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff437069),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _filterCartItems(value),
                decoration: InputDecoration(
                  hintText: 'Search your cart...',
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black54),
                    onPressed: () {
                      _searchController.clear();
                      _filterCartItems('');
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // Cart items list
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Results',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Use ListView.builder inside the Column without shrinkWrap.
                  Container(
                    height: MediaQuery.of(context).size.height - 200, // Adjust the height to fit the remaining screen
                    child: ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
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
                                    color: item['image'] == null
                                        ? Color(0xffe8bbbb) // Pink box if image is null
                                        : null, // No background color if the image is not null
                                  ),
                                  child: item['image'] != null
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8), // Ensures image has rounded corners
                                    child: Image.asset(
                                      item['image'] ?? 'assets/default_image.jpg', // Default image if null
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
                              // Left side of the cart item
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['itemName'] ?? 'No Name', // Use itemName from checklistItems
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
                                        '${item['quantity']?.toString() ?? ""} ${item['fraction'] ?? ""} ${item['unit'] ?? ""}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        item['category'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    item['itemDescription'] ?? 'No Description', // Use itemDescription
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
                                  // Checkbox (if needed for cart items)
                                  Checkbox(
                                    value: item['isChecked'],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        item['isChecked'] = value ?? false;
                                        _saveCartItems(); // Save the state after change
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
                                        _filteredItems.removeAt(index);
                                        _saveCartItems(); // Save after deletion
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
