import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mealmatch/features/app/presentation/pages/accounts.dart';
import 'package:mealmatch/features/app/presentation/pages/login.dart';
import 'package:mealmatch/features/app/presentation/pages/onboarding.dart';
import 'package:mealmatch/features/app/presentation/pages/register.dart';
import 'package:mealmatch/features/app/presentation/pages/root_page.dart';
import 'package:mealmatch/features/app/presentation/pages/favorite_page.dart';
import 'package:mealmatch/features/app/presentation/pages/shopping_cart.dart';
import 'package:mealmatch/features/app/presentation/pages/meal_planner.dart';
import 'package:mealmatch/features/app/presentation/pages/Scan_img.dart';
import 'package:mealmatch/features/app/presentation/pages/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: 'onboarding',
      routes: {
        'login': (context) => MyLogin(),
        'register': (context) => MyRegister(),
        'root': (context) => const RootPage(),
        'onboarding': (context) => OnboardingPage(),
        'register': (context) => MyRegister(),
        'accounts' : (context) => AccountsPage(),
      },
    );
  }
}
