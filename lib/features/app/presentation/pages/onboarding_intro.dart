import 'package:flutter/material.dart';
//import 'package:mealmatch/features/app/presentation/pages/root_page.dart'; // Your root page
import 'package:mealmatch/features/app/presentation/pages/login.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 20),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => const MyLogin())); // Navigate to home screen
              },
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Color(0xff1b534c),
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            onPageChanged: (int page) {
              setState(() {
                currentIndex = page;
              });
            },
            controller: _pageController,
            children: [
              createPage(
                image: 'Assets/meal3.jpg', // Replace with meal variety image
                title: 'Welcome to MealMatch',
                description: 'Find the best recipes tailored to your taste!',
              ),
              createPage(
                image: 'Assets/meal4.jpg', // Replace with saved recipes or favorites image
                title: 'Save Your Favorites',
                description: 'Save the meals you love and keep them in one place.',
              ),
              createPage(
                image: 'Assets/meal6.png', // Replace with meal planner image
                title: 'Plan Your Meals',
                description: 'Plan your meals for the week and stay organized.',
              ),
              createPage(
                image: 'Assets/meal7.webp', // Replace with pantry and shopping cart image
                title: 'Your Pantry & Cart',
                description: 'Track ingredients in your pantry and shop for what you need!',
              ),
              createPage(
                image: 'Assets/meal8.png', // Replace with a personalized meal suggestion image
                title: 'Get Personalized Recommendations',
                description: 'Get meal suggestions based on your preferences.',
              ),
            ],
          ),

          Positioned(
            bottom: 80,
            left: 30,
            child: Row(
              children: _buildIndicator(),
            ),
          ),
          Positioned(
            bottom: 60,
            right: 30,
            child: Container(
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (currentIndex < 2) {
                        currentIndex++;
                        if (currentIndex < 3) {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn);
                        }
                      } else {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => const MyLogin()));
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 24,
                    color: Colors.white,
                  )),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xff1b534c), // Adjust the color to match your branding
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Create the indicator decorations widget
  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 10.0,
      width: isActive ? 20 : 8,
      margin: const EdgeInsets.only(right: 5.0),
      decoration: BoxDecoration(
        color:Color(0xff1b534c), // Adjust the color to match your branding
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  //Create the indicator list
  List<Widget> _buildIndicator() {
    List<Widget> indicators = [];

    for (int i = 0; i < 5; i++) {
      if (currentIndex == i) {
        indicators.add(_indicator(true));
      } else {
        indicators.add(_indicator(false));
      }
    }

    return indicators;
  }
}

class createPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const createPage({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 350,
            child: Image.asset(image),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff1b534c), // Match with your branding
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}