import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PantrySearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> checklistItems;  // Declare the type of the checklistItems parameter

  const PantrySearchPage({super.key, required this.checklistItems});

  @override
  State<PantrySearchPage> createState() => _PantrySearchPageState();
}

class _PantrySearchPageState extends State<PantrySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    print(widget.checklistItems); // Print to see if data is passed
    _filteredItems = List.from(widget.checklistItems);
    _loadRecentSearches();
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = List.from(widget.checklistItems); // Show all items if search is cleared
      });
      return;
    }

    List<String> queryWords = query.toLowerCase().split(' ');
    setState(() {
      _filteredItems = widget.checklistItems.where((item) {
        String name = (item['itemName'] ?? '').toLowerCase();
        String description = (item['itemDescription'] ?? '').toLowerCase();
        String category = (item['category'] ?? '').toLowerCase();

        return queryWords.every(
              (word) => name.contains(word) || description.contains(word) || category.contains(word),
        );
      }).toList();
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
      _saveRecentSearches();
    }
    _filterItems(query);
  }

  void _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  void _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
    _saveRecentSearches();
  }

  void _savechecklistItemsp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('checklist_items', _filteredItems.map((item) => item.toString()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Pantry Items',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff437069),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _filterItems(value),
                onSubmitted: _onSearchSubmitted,
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black54),
                    onPressed: () {
                      _searchController.clear();
                      _filterItems('');
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
            if (_recentSearches.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Searches',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentSearches.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_recentSearches[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.cancel_outlined, color: Color(0xFF9B0707)),
                            onPressed: () {
                              setState(() {
                                _recentSearches.removeAt(index);
                              });
                              _saveRecentSearches();
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredItems.length,
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
                              color: _filteredItems[index]['image'] == null
                                  ? Color(0xffe8bbbb) // Pink box if image is null
                                  : null, // No background color if the image is not null
                            ),
                            child: _filteredItems[index]['image'] != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8), // Ensures image has rounded corners
                              child: Image.asset(
                                _filteredItems[index]['image'] ?? 'assets/default_image.jpg',
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
                              _filteredItems[index]['itemName'] ?? '',
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
                                  '${_filteredItems[index]['quantity']?.toString() ?? ""} ${_filteredItems[index]['fraction'] ?? ""} ${_filteredItems[index]['unit'] ?? ""}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _filteredItems[index]['category'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _filteredItems[index]['itemDescription'] ?? '',
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
                            Checkbox(
                              value: _filteredItems[index]['isChecked'],
                              onChanged: (bool? value) {
                                setState(() {
                                  _filteredItems[index]['isChecked'] = value ?? false;
                                  _savechecklistItemsp(); // Save the state after change
                                });
                              },
                              activeColor: Colors.green[900],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red[900],
                              onPressed: () {
                                setState(() {
                                  _filteredItems.removeAt(index);
                                  _savechecklistItemsp(); // Save after deletion
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
    );
  }
}
