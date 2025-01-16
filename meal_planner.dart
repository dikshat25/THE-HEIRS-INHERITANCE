import 'package:flutter/material.dart';

class MealPlanner extends StatefulWidget {
  const MealPlanner({super.key});

  @override
  State<MealPlanner> createState() => _MealPlannerState();
}
class _MealPlannerState extends State<MealPlanner> {
  DateTime selectedDate = DateTime.now();
  DateTime currentWeekStart =
  DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  final Map<DateTime, Map<String, List<String>>> mealsByDate = {};


  static const Color primaryColor = Color(0xff00473d);
  static const Color greenBackground = Color(0xff00E390);
  static const Color inactiveColor = Colors.black54;

  void _navigateDay(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
  }

  void _navigateWeek(int weeks) {
    setState(() {
      currentWeekStart = currentWeekStart.add(Duration(days: weeks * 7));
    });
  }

  void _addMeal(String category) {
    TextEditingController mealController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Meal to $category"),
        content: TextField(
          controller: mealController,
          decoration: const InputDecoration(hintText: "Enter meal name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (mealController.text.isNotEmpty) {
                setState(() {
                  mealsByDate.putIfAbsent(selectedDate, () => {});
                  mealsByDate[selectedDate]!.putIfAbsent(category, () => []);
                  mealsByDate[selectedDate]![category]!.add(mealController.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _deleteMeal(String category, String meal) {
    setState(() {
      mealsByDate[selectedDate]?[category]?.remove(meal);
      if (mealsByDate[selectedDate]?[category]?.isEmpty ?? true) {
        mealsByDate[selectedDate]?.remove(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'Assets/loginbackground.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Meal Planner",
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                _navigationBox(_dayNavigation()),
                _mealSection("Today", selectedDate),
                _navigationBox(_weekNavigation()),
                _mealSection("This Week", currentWeekStart),
                _unscheduledMealsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navigationBox(Widget navigationWidget) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: navigationWidget,
    );
  }

  Widget _dayNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _navigateDay(-1),
          icon: const Icon(Icons.chevron_left, size: 24, color: Colors.white),
        ),
        Text(
          "${selectedDate.day.toString().padLeft(2, '0')}-"
              "${selectedDate.month.toString().padLeft(2, '0')}-"
              "${selectedDate.year.toString().substring(2)}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        IconButton(
          onPressed: () => _navigateDay(1),
          icon: const Icon(Icons.chevron_right, size: 24, color: Colors.white),
        ),
      ],
    );
  }

  Widget _weekNavigation() {
    DateTime weekEnd = currentWeekStart.add(Duration(days: 6));

    String startDate = "${currentWeekStart.day.toString().padLeft(2, '0')}-"
        "${currentWeekStart.month.toString().padLeft(2, '0')}-"
        "${currentWeekStart.year.toString().substring(2)}";

    String endDate = "${weekEnd.day.toString().padLeft(2, '0')}-"
        "${weekEnd.month.toString().padLeft(2, '0')}-"
        "${weekEnd.year.toString()}";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _navigateWeek(-1),
          icon: const Icon(Icons.chevron_left, size: 24, color: Colors.white),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "$startDate to $endDate",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        IconButton(
          onPressed: () => _navigateWeek(1),
          icon: const Icon(Icons.chevron_right, size: 24, color: Colors.white),
        ),
      ],
    );
  }

  Widget _mealSection(String title, dynamic date) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            itemCount: mealCategories.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              String category = mealCategories[index]['title'];
              List<String> meals = mealsByDate[date]?[category] ?? [];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: primaryColor,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: primaryColor),
                            onPressed: () => _addMeal(category),
                          ),
                        ],
                      ),
                      ...meals.map((meal) {
                        return ListTile(
                          title: Text(meal),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMeal(category, meal),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _unscheduledMealsSection() {
    return _mealSection("Unscheduled Meals", null);
  }
}

final List<Map<String, dynamic>> mealCategories = [
  {"title": "Breakfast", "meals": <String>[]},
  {"title": "Lunch", "meals": <String>[]},
  {"title": "Dinner", "meals": <String>[]},
  {"title": "Snacks", "meals": <String>[]},
];