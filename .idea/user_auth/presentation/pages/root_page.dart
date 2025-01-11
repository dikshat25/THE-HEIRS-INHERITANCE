import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:mealmatch/features/user_auth/presentation/pages/home_page_user.dart';
import 'package:mealmatch/features/user_auth/presentation/pages/cart_page.dart';
import 'package:mealmatch/features/user_auth/presentation/pages/favourite_page.dart';
import 'package:mealmatch/features/user_auth/presentation/pages/meal_planner_page.dart';
import 'package:mealmatch/features/user_auth/presentation/pages/scanner_page.dart';

class Rootpage extends StatefulWidget {
  const Rootpage({super.key});

  @override
  State<Rootpage> createState() => _RootpageState();
}

class _RootpageState extends State<Rootpage> {
  int bottomNavIndex = 0;

  // List of the pages
  List<Widget> pages = const [
    Homepage(),
    FavouritePage(),
    CartPage(),
    ScannerPage(),
    ProfilePage(),
  ];


  // List of the pages icons
  List<IconData> iconList = [
    Icons.home,
    Icons.favorite,
    Icons.shopping_cart,
    Icons.person,
  ];

  // List of the pages titles
  List<String> titleList = [
    'Home',
    'Favourite',
    'Scanner',
    'Cart',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titleList[bottomNavIndex],
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
            ),
            Icon(Icons.notifications, color: Colors.black, size: 30),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: IndexedStack(
        index: bottomNavIndex,
        children: pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              child: const ScannerPage(),
              type: PageTransitionType.bottomToTop,
            ),
          );
        },
        child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 30),
        backgroundColor: const Color(0xff00473d),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(

        splashColor: Color(0xff00473d),
        activeColor: Color(0xff00473d),
        inactiveColor: Colors.black.withOpacity(.5),
        icons: iconList,
        activeIndex: bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: (index) {
          setState(() {
            bottomNavIndex = index;
          });
        },
      ),
    );
  }
}
