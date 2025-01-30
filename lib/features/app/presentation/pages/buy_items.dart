import 'package:flutter/material.dart';

class BuyItemsPage extends StatefulWidget {
  // Declare a final field to accept the items
  final List<Map<String, dynamic>> items;

  // Constructor to accept the items
  const BuyItemsPage({Key? key, required this.items}) : super(key: key);

  @override
  _BuyItemsPageState createState() => _BuyItemsPageState();
}

class _BuyItemsPageState extends State<BuyItemsPage> {
  // Text controller for the pincode input
  TextEditingController pincodeController = TextEditingController();
  String? filteredPincode;

  // Filter items based on the pincode
  List<Map<String, dynamic>> getFilteredItems() {
    if (filteredPincode == null || filteredPincode!.isEmpty) {
      return widget.items;  // No filter, show all items
    }
    return widget.items.where((item) {
      return item['pincode'] == filteredPincode; // Match the pincode
    }).toList();
  }

  // Check if all items are unavailable for the given pincode
  bool areAllItemsUnavailable() {
    return getFilteredItems().isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    double calculateTotalPrice(List<Map<String, dynamic>> items) {
      return items.fold(0.0, (sum, item) {
        double price = double.tryParse(item['price'].toString()) ?? 0.0;
        int quantity = int.tryParse(item['quantity'].toString()) ?? 0;
        return sum + price * quantity;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Items', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff437069),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pincode Input Field
            TextField(
              controller: pincodeController,
              decoration: InputDecoration(
                labelText: 'Enter Pincode',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  filteredPincode = value; // Update filter on pincode input
                });
              },
            ),
            const SizedBox(height: 16),

            // Check if all items are unavailable for the entered pincode
            if (areAllItemsUnavailable())
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No items available at this pincode location.',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),

            // Display filtered items
            Expanded(
              child: ListView.builder(
                itemCount: getFilteredItems().length,
                itemBuilder: (context, index) {
                  final item = getFilteredItems()[index];
                  final itemName = item['itemName'] ?? 'No name provided';
                  final quantity = int.tryParse(item['quantity'].toString()) ?? 0;
                  final unit = item['unit'] ?? 'Unit not specified';
                  final price = double.tryParse(item['price'].toString()) ?? 0.0;
                  final image = item['image'];

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff00E390).withOpacity(.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Item Image or Placeholder
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                            color: image == null
                                ? const Color(0xffe8bbbb)
                                : null,
                          ),
                          child: image != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              image,
                              fit: BoxFit.cover,
                            ),
                          )
                              : const Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Item Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff00473d),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '$quantity $unit',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Price: ₹$price',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Total Price for this item
                        Text(
                          '₹${(price * quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Total Price Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff00473d),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '₹${calculateTotalPrice(getFilteredItems()).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Place Order Button
            ElevatedButton(
              onPressed: () {
                // Add your order placement logic here
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Order Confirmation'),
                    content: const Text('Your order has been placed successfully!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xff437069),
              ),
              child: const Center(
                child: Text(
                  'Place Order',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
