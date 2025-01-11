import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:mealmatch/features/app/presentation/pages/favorite_page.dart';
import 'package:mealmatch/features/app/presentation/pages/home_page.dart';
import 'package:mealmatch/features/app/presentation/pages/meal_planner.dart';
import 'package:mealmatch/features/app/presentation/pages/shopping_cart.dart';
import 'package:mealmatch/features/app/presentation/pages/Scan_img.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  // Bottom Navigation index
  int _bottomNavIndex = 0;

  // Colors for the theme
  static const Color primaryColor = Color(0xff319788);
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
    Homepage(),         // This is your Home page
    FavoritePage(),     // Favorite page
    MealPlanner(),      // Meal Planner page
    ShoppingCart(),     // Shopping Cart page
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
              titleList[_bottomNavIndex],
              style: TextStyle(
                color: blackColor,
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
            ),
            Icon(Icons.notifications, color: blackColor, size: 30.0),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              child: const ScanImg(),  // Navigate to ScanImg page
              type: PageTransitionType.bottomToTop,
            ),
          );
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.camera_alt, size: 20.0),
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
