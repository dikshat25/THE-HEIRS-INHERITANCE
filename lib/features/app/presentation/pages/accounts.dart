import 'package:flutter/material.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Pops the current screen and returns to the previous one
          },
        ),
      ),
      body: SingleChildScrollView( // Allow scrolling for the entire page
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image Section
              Container(
                width: 150,
                child: const CircleAvatar(
                  radius: 60,
                  backgroundImage: ExactAssetImage('assets/images/profile.jpg'),
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue.withOpacity(.5), // Primary color for border
                    width: 5.0,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // User Name and Email Section
              SizedBox(
                width: size.width * .3,
                child: Row(
                  children: [
                    Text(
                      'John Doe',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'johndoe@gmail.com',
                style: TextStyle(
                  color: Colors.black.withOpacity(.3),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              // Options List (Profile, Settings, etc.)
              SizedBox(
                width: size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildOption(Icons.account_circle, 'My Account', _onMyAccountTap),
                    _buildOption(Icons.restaurant_menu, 'Dietary Preferences', _onDietaryPreferencesTap),
                    _buildOption(Icons.info, 'About MealMatch', _onAboutMealMatchTap),
                    _buildOption(Icons.feedback, 'Feedback & Support', _onFeedbackSupportTap),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create profile options (like Profile, Settings, etc.)
  Widget _buildOption(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.blue,
              size: 30,
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Option handlers
  void _onMyAccountTap() {
    // Navigate to My Account page
    print('My Account tapped');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyAccountPage()),
    );
  }

  void _onDietaryPreferencesTap() {
    // Navigate to Dietary Preferences page
    print('Dietary Preferences tapped');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DietaryPreferencesPage()),
    );
  }

  void _onAboutMealMatchTap() {
    // Navigate to About MealMatch page
    print('About MealMatch tapped');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AboutMealMatchPage()),
    );
  }

  void _onFeedbackSupportTap() {
    // Navigate to Feedback & Support page
    print('Feedback & Support tapped');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeedbackSupportPage()),
    );
  }
}

// Placeholder pages for the navigations (replace with actual pages)
class MyAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Account'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Pops the current screen and returns to the previous one
          },
        ),
      ),
      body: Center(child: Text('My Account Page')),
    );
  }
}

class DietaryPreferencesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dietary Preferences'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Pops the current screen and returns to the previous one
          },
        ),
      ),
      body: Center(child: Text('Dietary Preferences Page')),
    );
  }
}

class AboutMealMatchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About MealMatch'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Pops the current screen and returns to the previous one
          },
        ),
      ),
      body: Center(child: Text('About MealMatch Page')),
    );
  }
}

class FeedbackSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback & Support'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Pops the current screen and returns to the previous one
          },
        ),
      ),
      body: Center(child: Text('Feedback & Support Page')),
    );
  }
}
