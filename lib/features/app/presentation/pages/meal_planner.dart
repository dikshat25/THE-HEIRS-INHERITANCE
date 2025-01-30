import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MealPlanner extends StatefulWidget {
  const MealPlanner({super.key});

  @override
  State<MealPlanner> createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  DateTime selectedDate = DateTime.now();
  DateTime currentWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  final Map<DateTime, Map<String, List<Map<String, dynamic>>>> mealsByDate = {};
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
    tz.initializeTimeZones();
  }

  void _initializeNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

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
    TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Meal to $category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: mealController,
              decoration: const InputDecoration(hintText: "Enter meal name"),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(hintText: "Enter time (e.g., 8:00 AM)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (mealController.text.isNotEmpty && timeController.text.isNotEmpty) {
                String mealTime = timeController.text;
                setState(() {
                  mealsByDate.putIfAbsent(selectedDate, () => {});
                  mealsByDate[selectedDate]!.putIfAbsent(category, () => []);
                  mealsByDate[selectedDate]![category]!.add({
                    'meal': mealController.text,
                    'time': mealTime,
                  });

                  _scheduleMealNotification(mealController.text, mealTime);
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

  void _deleteMeal(String category, String meal, String time) {
    setState(() {
      mealsByDate[selectedDate]?[category]?.removeWhere((mealData) =>
      mealData['meal'] == meal && mealData['time'] == time);
      if (mealsByDate[selectedDate]?[category]?.isEmpty ?? true) {
        mealsByDate[selectedDate]?.remove(category);
      }
    });
  }

  void _scheduleMealNotification(String meal, String time) async {
    try {
      List<String> timeParts = time.split(' ');
      List<String> hourMinute = timeParts[0].split(':');
      int hour = int.parse(hourMinute[0]);
      int minute = int.parse(hourMinute[1]);
      if (timeParts[1].toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      }
      if (timeParts[1].toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }

      final notificationTime = tz.TZDateTime.from(selectedDate, tz.local).add(
        Duration(hours: hour, minutes: minute),
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch.remainder(100000), // Unique ID
        'Meal Reminder',
        '$meal is scheduled for $time',
        notificationTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_channel',
            'Meal Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Ensure notification shows in idle state
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue;

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
                  child: Center(
                    child: Text(
                      "Meal Planner",
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                _navigationBox(_dayNavigation(primaryColor)),
                _mealSection("Today", selectedDate, primaryColor),
                _navigationBox(_weekNavigation(primaryColor)),
                _mealSection("This Week", currentWeekStart, primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navigationBox(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
    );
  }

  Widget _dayNavigation(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => _navigateDay(-1),
        ),
        Text(
          "${selectedDate.toLocal()}".split(' ')[0],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward, color: primaryColor),
          onPressed: () => _navigateDay(1),
        ),
      ],
    );
  }

  Widget _weekNavigation(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => _navigateWeek(-1),
        ),
        Text(
          "Week of ${currentWeekStart.toLocal()}".split(' ')[0],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward, color: primaryColor),
          onPressed: () => _navigateWeek(1),
        ),
      ],
    );
  }

  Widget _mealSection(String title, dynamic date, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
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
              String category = mealCategories[index]['title']?? '';
              List<Map<String, dynamic>> meals = mealsByDate[date]?[category] ?? [];

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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: primaryColor,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: primaryColor),
                            onPressed: () => _addMeal(category),
                          ),
                        ],
                      ),
                      ...meals.map((mealData) {
                        return ListTile(
                          title: Text(mealData['meal'] ?? ''),
                          subtitle: Text('Time: ${mealData['time'] ?? ''}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMeal(category, mealData['meal'] ?? '', mealData['time'] ?? ''),
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
}

const List<Map<String, String>> mealCategories = [
  {'title': 'Breakfast'},
  {'title': 'Lunch'},
  {'title': 'Dinner'},
  {'title': 'Snack'},
];
