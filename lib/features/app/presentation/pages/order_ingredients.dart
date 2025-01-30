import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class OrderIngredients extends StatefulWidget {
  @override
  _OrderIngredientsState createState() => _OrderIngredientsState();
}

class _OrderIngredientsState extends State<OrderIngredients> {
  String pincode = "";
  int total = 0;
  List<Map<String, dynamic>> ingredients = [];

  @override
  void initState() {
    super.initState();
    loadCSVData();
  }

  Future<void> loadCSVData() async {
    final csvData = await rootBundle.loadString('Assets/food_products.csv');
    List<List<dynamic>> data = CsvToListConverter().convert(csvData);

    // Skip the header row and create ingredients list
    List<Map<String, dynamic>> loadedIngredients = [];
    for (int i = 1; i < data.length; i++) {
      loadedIngredients.add({
        'name': data[i][0],
        'description': data[i][1],
        'quantity': int.parse(data[i][2].toString().replaceAll(RegExp(r'[^0-9]'), '')),
        'price': int.parse(data[i][3].toString()),
        'pincode': data[i][4].toString(),
        'image': 'assets/images/default.png',  // You can set an appropriate image path here
      });
    }

    setState(() {
      ingredients = loadedIngredients;
      total = ingredients.fold<int>(0, (sum, item) {
        return sum + (item['price'] as int) * (item['quantity'] as int);
      });


    });
  }

  void updateQuantity(int id, int newQuantity) {
    setState(() {
      ingredients = ingredients.map((item) {
        if (item['id'] == id) {
          return {
            ...item,
            'quantity': newQuantity > 0 ? newQuantity : 1,
          };
        }
        return item;
      }).toList();
    });
  }

  void handlePincodeUpdate() {
    print("Pincode updated to: $pincode");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Ingredients"),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {},
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.green.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Enter pincode",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          pincode = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: handlePincodeUpdate,
                    child: Text("Update"),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset('assets/logos/dunzo.png', height: 40),
                  Image.asset('assets/logos/bigbasket.png', height: 40),
                  Image.asset('assets/logos/zappfresh.png', height: 40),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = ingredients[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Image.asset(
                              ingredient['image'],
                              width: 60,
                              height: 60,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ingredient['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    ingredient['description'],
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    "₹ ${ingredient['price']}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () => updateQuantity(
                                    ingredient['id'],
                                    ingredient['quantity'] - 1,
                                  ),
                                ),
                                Text("${ingredient['quantity']}",
                                    style: TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () => updateQuantity(
                                    ingredient['id'],
                                    ingredient['quantity'] + 1,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text("Swap"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total: ₹ $total",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Share"),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Add to Cart"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
