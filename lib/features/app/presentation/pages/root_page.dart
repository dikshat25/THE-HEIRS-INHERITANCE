import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:mealmatch/features/app/presentation/pages/favorite_page.dart';
import 'package:mealmatch/features/app/presentation/pages/home_page.dart';
import 'package:mealmatch/features/app/presentation/pages/meal_planner.dart';
import 'package:mealmatch/features/app/presentation/pages/shopping_cart.dart';
import 'package:mealmatch/features/app/presentation/pages/Scan_img.dart';
import 'package:mealmatch/features/app/presentation/pages/pantry.dart'; // Added PantryPage import
import 'package:mealmatch/features/app/presentation/pages/accounts.dart';
import 'package:mealmatch/features/app/presentation/Model/recipe.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  // Bottom Navigation index
  int _bottomNavIndex = 0;

  // Colors for the theme
  static const Color primaryColor = Color(0xff1b534c);
  static const Color blackColor = Colors.black;

  // Bottom nav icons list
  List<IconData> iconList = [
    Icons.home,
    Icons.favorite,
    Icons.calendar_today,
    Icons.shopping_cart,
  ];

  // Bottom nav titles list
  List<String> titleList = [
    'Home',
    'Favorite',
    'Meal Planner',
    'Cart',
  ];

  // Pages corresponding to bottom navigation items
  List<Widget> pages = [

    Homepage(), // Home page
    FavouritePage(), // Favorite page
    MealPlanner(), // Meal Planner page
    cartPage(), // Cart page
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "MealMatch",
              style: TextStyle(
                color: Color(0xff00473d),
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PantryPage()),
                );
              },
              child: Tooltip(
                message: 'Pantry',
                child: Icon(
                  Icons.food_bank_outlined,
                  color: Color(0xff00473d),
                  size: 40.0,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.01,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountsPage()),
                );
              },
              child: Tooltip(
                message: 'Account',
                child: Icon(
                  Icons.account_circle,
                  color: Color(0xff00473d),
                  size: 40.0,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xffffffff),
        elevation: 0.0,
      ),

      body: IndexedStack(
        index: _bottomNavIndex,
        children: pages, // The list of pages
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              child: const ScanImg(), // Navigate to ScanImg page
              type: PageTransitionType.bottomToTop,
            ),
          );
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.camera_alt, color: Colors.white, size: 20.0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: AnimatedBottomNavigationBar(
        splashColor: primaryColor,
        activeColor: primaryColor,
        inactiveColor: Colors.black.withOpacity(.5),
        icons: iconList,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
      ),
    );
  }
}
