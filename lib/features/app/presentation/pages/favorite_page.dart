import 'package:flutter/material.dart';
import 'package:mealmatch/features/app/presentation/Model/recipe.dart';


class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> recipeCategories = [
      {"title": "All Saved Recipes", "count": 14},
      {"title": "All Personal Recipes", "count": 4},
      {"title": "Breakfast", "count": 0},
      {"title": "Lunch", "count": 5},
      {"title": "Dessert", "count": 3},
      {"title": "Drink", "count": 2},
      {"title": "Dinner", "count": 8},
    ];

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'Assets/loginbackground.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Main Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Container
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        width: size.width * .9,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, color: Colors.white.withOpacity(.8)),
                            const Expanded(
                              child: TextField(
                                showCursor: false,
                                decoration: InputDecoration(
                                  hintText: 'Search your collections...',
                                  hintStyle: TextStyle(color: Colors.white70),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                            Icon(Icons.mic, color: Colors.white.withOpacity(.8)),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xff00473d),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                ),

                // Collections Title
                Container(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        width: size.width * .9,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Collections",
                              style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.w900,
                                color: Color(0xff00473d),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // New Collection Button
                Container(
                  padding: const EdgeInsets.only(left: 30, top: 70, bottom: 20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 24.0,
                        color: Colors.black,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'New collection',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),

                // Recipe List
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: size.height * .5,
                  child: ListView.builder(
                    itemCount: recipeCategories.length,
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Color(0xff00E390).withOpacity(.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 80.0,
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        margin: const EdgeInsets.only(bottom: 10, top: 10),
                        width: size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,

                                ),
                                Positioned(
                                  bottom: 5,
                                  left: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recipeCategories[index]['title'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xff00473d),
                                        ),
                                      ),
                                      Text(
                                        "${recipeCategories[index]['count']} recipes",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

