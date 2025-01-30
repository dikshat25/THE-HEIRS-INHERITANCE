import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class cartSearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> checklistItems;

  const cartSearchPage({super.key, required this.checklistItems});

  @override
  State<cartSearchPage> createState() => _cartSearchPageState();
}

class _cartSearchPageState extends State<cartSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.checklistItems); // Initially show all items
  }

  void _filtercartItems(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = List.from(widget.checklistItems); // Reset to all items when query is empty
      });
      return;
    }

    List<String> queryWords = query.toLowerCase().split(' ');

    final results = widget.checklistItems.where((item) {
      String itemName = item['name']?.toLowerCase() ?? ''; // Safely handle null values
      return queryWords.any((word) => itemName.contains(word));
    }).toList();

    setState(() {
      _filteredItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search cart' , style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xff437069),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _filtercartItems(value),
                decoration: InputDecoration(
                  hintText: 'Search your cart...',
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black54),
                    onPressed: () {
                      _searchController.clear();
                      _filtercartItems('');
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
            // cart items list
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
                        return GestureDetector(
                          onTap: () {
                            // Handle item tap, navigate to detailed page if needed
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      item['image'] ?? 'assets/default_image.jpg', // Default image if null
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'] ?? 'No Name', // Fallback to 'No Name' if null
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          item['description'] ?? 'No Description', // Fallback to 'No Description' if null
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
