import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';


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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),  // Rounded corners for the dialog
        ),
        backgroundColor: Colors.white,  // White background for clarity
        title: Text(
          "Add Meal to $category",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Meal Name Field
              TextField(
                controller: mealController,
                decoration: InputDecoration(
                  hintText: "Enter meal name",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Color(0xfff2f2f2),  // Light background for input field
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),  // Space between fields

              // Meal Time Field
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  hintText: "Enter time (e.g., 8:00 AM)",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Color(0xfff2f2f2),  // Light background for input field
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Cancel Button with style
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,  // Text color
              backgroundColor: Colors.grey[400],  // Background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              "Cancel",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // Add Button with style
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,  // Text color
              backgroundColor: Color(0xff00E390),  // Custom green color for the button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              "Add",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
    final primaryColor = Colors.black;
    final backgroundColor = Color(0xffe7fae4);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: backgroundColor,
            )
          ),
          SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Left align the children
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 30, left: 30 , bottom: 30),
                    child: Text(
                      "Meal Planner",
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  _navigationBox(_dayNavigation(primaryColor)),
                  _mealSection("Today", selectedDate, primaryColor),
                  _navigationBox(_weekNavigation(primaryColor)),
                  _mealSection("This Week", currentWeekStart, primaryColor),
                ],
              )

          ),
        ],
      ),
    );
  }

  Widget _navigationBox(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),  // More rounded corners
        ),
        elevation: 4,  // Subtle shadow for elevation
        child: child,
      ),
    );
  }

  Widget _dayNavigation(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Color(0xfff5fdf1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => _navigateDay(-1),
          ),
          Text(
            "${selectedDate.toLocal()}".split(' ')[0],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: primaryColor),
            onPressed: () => _navigateDay(1),
          ),
        ],
      ),
    );
  }

  Widget _weekNavigation(Color primaryColor) {
    // Format the date properly using DateFormat
    String formattedWeekStart = DateFormat('MMMM dd, yyyy').format(currentWeekStart);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Color(0xfff5fdf1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => _navigateWeek(-1),
          ),
          Text(
            "Week of $formattedWeekStart",  // Display "Week of [formatted date]"
            style: TextStyle(
              fontSize: 18 ,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: primaryColor),
            onPressed: () => _navigateWeek(1),
          ),
        ],
      ),
    );
  }


  Widget _mealSection(String title, dynamic date, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700, color: primaryColor),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            itemCount: mealCategories.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              String category = mealCategories[index]['title'] ?? '';
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: primaryColor),
                            onPressed: () => _addMeal(category),
                          ),
                        ],
                      ),
                      ...meals.map((mealData) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff00E390).withOpacity(.16), // Apply background color with opacity
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          child: ListTile(
                            title: Text(mealData['meal'] ?? '', style: TextStyle(fontSize: 16)),
                            subtitle: Text('Time: ${mealData['time'] ?? ''}', style: TextStyle(color: Colors.grey)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMeal(category, mealData['meal'] ?? '', mealData['time'] ?? ''),
                            ),
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