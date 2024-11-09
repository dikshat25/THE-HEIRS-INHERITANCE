import 'package:flutter/material.dart';
import 'package:recipe_app/features/app/presentation/Model/recipe.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {

    int selectedIndex = 0;
    Size size = MediaQuery.of(context).size;

    List<Recipe> _recipelist = Recipe.fetchRecipes();

    //recipe category
    List<String> _recipeTypes = [
      'Recommended',
      'Courses',
      'Cuisines',
      'Dietary Preferences',
      'Occasion-Based Recipes',
    ];

    //Toggle favourite button
    bool toggleIsFavorated(bool isFavorited) {
      return !isFavorited;
    }

    return Scaffold(
      backgroundColor: Color(0xFFD5ECCE),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(top:30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                      width: size.width * .9,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Good Morning !",
                            style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff00473d)
                            ),
                          ),
                        ],
                      ),
                    )

                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top:50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                      width: size.width* .9,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center ,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, color: Colors.black54.withOpacity(.6)),
                          const Expanded(child: TextField(
                            showCursor: false,
                            decoration: InputDecoration(
                              hintText: 'Search Recipes',
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          )),
                          Icon(Icons.mic, color: Colors.black54.withOpacity(.6),),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)

                      ),
                    )
                  ],
                ),
              ),
              Container(

                padding: const EdgeInsets.symmetric(horizontal: 12),
                //padding: const EdgeInsets.only(top:10),
                height: 50.0,
                width: size.width,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _recipeTypes.length,
                    itemBuilder: (BuildContext context , int index){
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: (){
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Text(
                            _recipeTypes[index],
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: selectedIndex== index? FontWeight.bold : FontWeight.w300,
                              color: selectedIndex == index? Color(0xff00473d) : Colors.grey,
                            ),
                          ),
                        ),

                      );
                    }
                ),
              ),
              SizedBox(
                height: size.height*.3,
                child: ListView.builder(
                    itemCount: _recipelist.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context , int index) {
                      return Container(
                        width: 300,
                        margin: const EdgeInsets.symmetric(horizontal: 10 ),
                        child: Stack(
                          children: [
                            Positioned(
                                top: 10,
                                right: 20,
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  child: IconButton(
                                    onPressed: null,
                                    icon: Icon(_recipelist[index].isFavorated == true ? Icons.favorite :Icons.favorite_outline_rounded),
                                    color: Colors.redAccent,
                                    iconSize: 30,
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(50)
                                  ),
                                )
                            ),
                            Positioned(
                                left: 50,
                                right: 50,
                                top: 50,
                                bottom: 50,
                                child: Image.asset(_recipelist[index].imageURL)
                            ),
                            Positioned(
                                bottom: 15,
                                left: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_recipelist[index].category,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(_recipelist[index].recipeName , style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,

                                    ),)

                                  ],
                                )
                            ),
                            Positioned(
                              bottom: 15,
                              right: 20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(r'' + _recipelist[index].rating.toString() , style: TextStyle(
                                  color: Color(0xff00473d),
                                  fontSize: 16,
                                ),),
                              ),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xff00473d).withOpacity(.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 16, top: 20, bottom:20) ,
                child: const Text('Our latest articles' , style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: size.height*.5,
                child: ListView.builder(
                    itemCount: _recipelist.length,
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context , int index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade300.withOpacity(.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 80.0,
                        padding: const EdgeInsets.only(left: 10,top: 10),
                        margin: const EdgeInsets.only(bottom: 10,top: 10),
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
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(.8),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  left: 0,
                                  right: 0,
                                  child: SizedBox(
                                    height: 80.0,
                                    child: Image.asset(_recipelist[index].imageURL),
                                  ),
                                ),
                                Positioned(
                                    bottom: 5,
                                    left: 80,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_recipelist[index].category),
                                        Text(_recipelist[index].recipeName, style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xff00473d),
                                        ),)
                                      ],
                                    )
                                ),
                              ],
                            ),
                          ],
                        ),
                      );

                    }
                ),
              ),



            ],
          ) ,
        )
    );
  }
}