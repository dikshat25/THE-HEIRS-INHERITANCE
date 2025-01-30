import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mealmatch/features/app/presentation/pages/accounts.dart';
import 'package:mealmatch/features/app/presentation/pages/add_recipe.dart';
import 'package:mealmatch/features/app/presentation/pages/login.dart';
import 'package:mealmatch/features/app/presentation/pages/onboarding.dart';
import 'package:mealmatch/features/app/presentation/pages/order_ingredients.dart';
import 'package:mealmatch/features/app/presentation/pages/register.dart';
import 'package:mealmatch/features/app/presentation/pages/root_page.dart';
import 'package:mealmatch/features/app/presentation/pages/favorite_page.dart';
import 'package:mealmatch/features/app/presentation/pages/shopping_cart.dart';
import 'package:mealmatch/features/app/presentation/pages/meal_planner.dart';
import 'package:mealmatch/features/app/presentation/pages/Scan_img.dart';
import 'package:mealmatch/features/app/presentation/pages/splashscreen.dart';
import 'package:mealmatch/recipe_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request permission for exact alarms
  await requestExactAlarmPermission();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Timezone
  tz.initializeTimeZones();

  // Initialize Flutter Local Notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('ic_notification'),
    iOS: DarwinInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap
      print('Notification tapped: ${response.payload}');
    },
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => RecipeProvider(),
      child: MyApp(flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin),
    ),
  );
}

Future<void> requestExactAlarmPermission() async {
  if (Platform.isAndroid) {
    var status = await Permission.scheduleExactAlarm.status;
    print("Exact alarm permission status: $status");

    if (!status.isGranted) {
      var requestStatus = await Permission.scheduleExactAlarm.request();
      print("Permission request status: $requestStatus");
      if (requestStatus.isGranted) {
        print("Exact alarm permission granted!");
      } else {
        print("Permission denied");
      }
    } else {
      print("Exact alarm permission already granted");
    }
  }
}



class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const MyApp({super.key, required this.flutterLocalNotificationsPlugin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: 'root',
      routes: {
        'login': (context) => MyLogin(),
        'register': (context) => MyRegister(),
        'root': (context) => RootPage(),
        'accounts': (context) => AccountsPage(),
        'onboarding': (context) => OnboardingPage(),
        'splashscreen': (context) => SplashScreen(),
        '/add_recipe': (context) => AddRecipePage(),
        'order': (context) => OrderIngredients(),
        'cart': (context) => cartPage(),
        'meal_planner': (context) => MealPlanner(),
      },
    );
  }
}
