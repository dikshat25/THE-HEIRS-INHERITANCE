import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mealmatch/features/app/presentation/pages/login.dart';
import 'package:mealmatch/features/app/presentation/pages/register.dart';
import 'package:mealmatch/features/app/presentation/pages/root_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: 'login',
      routes: {
        'login': (context) => MyLogin(),
        'register': (context) => MyRegister(),
        'root': (context) => const RootPage(),
      },
    );
  }
}
