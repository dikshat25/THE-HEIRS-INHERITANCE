import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'root_page.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



import 'package:cloud_firestore/cloud_firestore.dart';



class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  String username = "John Doe";
  String profileImagePath = ''; // Path to the profile image

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Load profile data from shared preferences
  void _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "John Doe";
      profileImagePath = prefs.getString('profileImagePath') ?? '';
    });
  }



  String _getInitials(String name) {
    List<String> parts = name.split(' ');
    String initials = '';
    for (var part in parts) {
      if (part.isNotEmpty) initials += part[0].toUpperCase();
    }
    return initials;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RootPage()),
              (route) => false, // Remove all routes, leading to the RootPage
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const RootPage()),
                    (route) => false, // Remove all routes, leading to the RootPage
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image Section
                Container(
                  width: 150,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xff00473d).withOpacity(0.2),
                    backgroundImage: profileImagePath.isNotEmpty
                        ? FileImage(File(profileImagePath))
                        : null,
                    child: profileImagePath.isEmpty
                        ? Text(
                      _getInitials(username),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff00473d),
                      ),
                    )
                        : null,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xff00473d).withOpacity(0.5),
                      width: 5.0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // User Name and Email Section
                Center(
                  child: Column(
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'johndoe@gmail.com',
                        style: TextStyle(
                          color: Colors.black.withOpacity(.3),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Options List
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
      ),
    );
  }

  // Modern button style for options
  Widget _buildOption(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
              color: const Color(0xff00473d),
              size: 30,
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
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

  void _onMyAccountTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyAccountPage(
          initialUsername: username,
          initialImagePath: profileImagePath,
          onProfileUpdated: (newUsername, newImagePath) {
            setState(() {
              username = newUsername;
              profileImagePath = newImagePath;  // Update the profile image path
            });
            _saveProfileData(newUsername, newImagePath); // Save updated data to shared preferences
          },
        ),
      ),
    );
  }

  void _saveProfileData(String newUsername, String newImagePath) async {
    // Get current user UID
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // If a new profile image is selected, upload it to Firebase Storage
        String? imageUrl;
        if (newImagePath.isNotEmpty) {
          File imageFile = File(newImagePath);
          UploadTask uploadTask = FirebaseStorage.instance
              .ref()
              .child('profile_images/${user.uid}.jpg')
              .putFile(imageFile);

          TaskSnapshot snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        }

        // Save profile data in Firestore
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': newUsername,
          'profileImage': imageUrl ?? '',
          'email': user.email,
          'uid': user.uid,
        });

        // Also update the local storage
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('username', newUsername);
        prefs.setString('profileImagePath', newImagePath);
      } catch (e) {
        print('Error saving profile data: $e');
      }
    }
  }

  void _onDietaryPreferencesTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DietaryPreferencesPage()),
    );
  }

  void _onAboutMealMatchTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutMealMatchPage()),
    );
  }

  void _onFeedbackSupportTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FeedbackSupportPage()),
    );
  }
}

// AddAccountPage: Page shown after deleting the account
class AddAccountPage extends StatelessWidget {
  const AddAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Account')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Navigate to account creation screen and get the result back
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountCreationPage()),
            );

            // If the result is not null, update the UI or the state with the new account details
            if (result != null) {
              String name = result['name'];
              String email = result['email'];

              // Here you can use a state management solution (like Provider) to update the AccountPage and MyAccountPage
              // For example, you can set these values to be displayed on those pages.
            }
          },
          child: const Text('Add Account to Continue'),
        ),
      ),
    );
  }
}

class AccountCreationPage extends StatefulWidget {
  const AccountCreationPage({super.key});

  @override
  _AccountCreationPageState createState() => _AccountCreationPageState();
}

class _AccountCreationPageState extends State<AccountCreationPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  void _saveAccount() {
    String name = _nameController.text;
    String email = _emailController.text;

    if (name.isNotEmpty && email.isNotEmpty) {
      // Save the name and email
      // You can use a state management solution (Provider, Riverpod, etc.) to update AccountPage and MyAccountPage
      Navigator.pop(context, {'name': name, 'email': email});
    } else {
      // Handle validation or show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both name and email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAccount,
              child: const Text('Save Account'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyAccountPage extends StatefulWidget {
  final String initialUsername;
  final String initialImagePath;
  final Function(String username, String imagePath) onProfileUpdated;

  const MyAccountPage({
    super.key,
    required this.initialUsername,
    required this.initialImagePath,
    required this.onProfileUpdated,
  });

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  late TextEditingController usernameController;
  late String imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usernameController = TextEditingController(text: prefs.getString('username') ?? widget.initialUsername);
      imagePath = prefs.getString('profileImagePath') ?? widget.initialImagePath;
    });
  }

  void _saveProfileData(String newUsername, String newImagePath) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('username', newUsername);
    prefs.setString('profileImagePath', newImagePath);
  }

  Future<void> _selectProfileImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  String _getInitials(String name) {
    List<String> parts = name.split(' ');
    String initials = '';
    for (var part in parts) {
      if (part.isNotEmpty) initials += part[0].toUpperCase();
    }
    return initials;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff437069),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            Container(
              width: 150,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xff00473d).withOpacity(0.2),  // Light green background color
                backgroundImage: imagePath.isNotEmpty
                    ? FileImage(File(imagePath))
                    : null,
                child: imagePath.isEmpty
                    ? Text(
                  _getInitials(usernameController.text),  // Extract initials from the username
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff00473d),  // Dark green color
                  ),
                )
                    : null,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xff00473d).withOpacity(0.5),  // Green border with opacity
                  width: 5.0,
                ),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _selectProfileImage,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text('Change Profile Image', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff00473d), // Primary color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              ),
            ),


            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              style: const TextStyle(color: Colors.black), // White text color for input
              decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Color(0xff00473d)),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff00473d), width: 2),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                widget.onProfileUpdated(usernameController.text, imagePath);
                _saveProfileData(usernameController.text, imagePath);
                Navigator.pop(context);
              },
              child: const Text('Save Changes', style: TextStyle(color: Colors.white)), // White text color for button
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff00473d), // Primary color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 60),
                elevation: 5,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
            ),


          ],
        ),
      ),
    );
  }
}



// Placeholder Pages








class DietaryPreferencesPage extends StatefulWidget {
  const DietaryPreferencesPage({super.key});

  @override
  _DietaryPreferencesPageState createState() => _DietaryPreferencesPageState();
}

class _DietaryPreferencesPageState extends State<DietaryPreferencesPage> {
  final Map<String, List<String>> categories = {
    'Diets': ['Vegetarian', 'Vegan', 'Non vegetarian'],
    'Allergies': ['Dairy', 'Nuts', 'Gluten', 'Eggs', 'Shellfish', 'Soy', 'Sea Food', 'Sesame'],
    'Favorite Cuisines': ['Italian', 'Chinese', 'Indian', 'Mexican', 'Japanese', 'Thai'],
    'Disliked Ingredients': ['Onions', 'Garlic', 'Tomatoes', 'Cilantro', 'Mushrooms'], // Default values for disliked ingredients
  };

  final Map<String, Set<String>> selectedPreferences = {
    'Diets': {},
    'Allergies': {},
    'Favorite Cuisines': {},
    'Disliked Ingredients': {}, // Initialize as an empty set for consistency
  };

  final TextEditingController _ingredientController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('selectedPreferences');
    if (savedData != null) {
      final Map<String, dynamic> loadedPreferences = jsonDecode(savedData);
      setState(() {
        loadedPreferences.forEach((key, value) {
          selectedPreferences[key] = (value as List<dynamic>).map((e) => e.toString()).toSet();
        });
      });
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final dataToSave = selectedPreferences.map((key, value) => MapEntry(key, value.toList()));
    await prefs.setString('selectedPreferences', jsonEncode(dataToSave));
  }

  void _updatePreferences() {
    _savePreferences();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences updated successfully!')),
    );
  }

  void _addDislikedIngredient(String ingredient) {
    if (ingredient.isNotEmpty) {
      setState(() {
        categories['Disliked Ingredients']!.add(ingredient);
        selectedPreferences['Disliked Ingredients']!.add(ingredient);
      });
      _ingredientController.clear();
    }
  }

  void _removeDislikedIngredient(String ingredient) {
    setState(() {
      categories['Disliked Ingredients']!.remove(ingredient);
      selectedPreferences['Disliked Ingredients']!.remove(ingredient);
    });
  }

  Widget _buildPreferenceCategory(String category) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              '${selectedPreferences[category]!.length} selected', // Correct way to show the selected count
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        children: category == 'Disliked Ingredients'
            ? [
          ...categories[category]!.map((item) {
            return ListTile(
              title: Text(item),
              trailing: IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () => _removeDislikedIngredient(item),
              ),
            );
          }).toList(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientController,
                    decoration: const InputDecoration(
                      hintText: 'Add ingredient',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _addDislikedIngredient,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _addDislikedIngredient(_ingredientController.text),
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Color(0xff00473d), fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(color: Color(0xff00473d), width: 3),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    elevation: 0,
                  ),
                )
              ],
            ),
          ),
        ]
            : categories[category]!.map((item) {
          return Theme(
            data: Theme.of(context).copyWith(
              checkboxTheme: CheckboxThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: const BorderSide(color: Colors.grey, width: 1.5),
              ),
            ),
            child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(item),
              value: selectedPreferences[category]!.contains(item),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedPreferences[category]!.add(item);
                  } else {
                    selectedPreferences[category]!.remove(item);
                  }
                });
              },
              activeColor: const Color(0xff00473d),
              checkColor: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dietary Preferences', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff437069),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Dietary Preferences',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: categories.keys.map((category) => _buildPreferenceCategory(category)).toList(),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _updatePreferences,
                child: const Text('Update Preferences', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff00473d),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 60),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}









class AboutMealMatchPage extends StatelessWidget {
  const AboutMealMatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff437069),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            const Text(
              'Welcome to MealMatch!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Description Section
            const Text(
              'MealMatch is a recipe app that connects you with personalized meal ideas based on your dietary preferences and available ingredients. Whether you\'re looking for a healthy breakfast, a quick lunch, or a delicious dinner, MealMatch provides recipes tailored to your needs.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Features Section
            const Text(
              'Features:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildFeatureItem('Personalized Recipe Suggestions', 'MealMatch offers personalized recipes based on your preferences, ingredients on hand, and dietary requirements.'),
            _buildFeatureItem('Ingredient Avoidance', 'Avoid recipes with ingredients you are allergic to or prefer not to use.'),
            _buildFeatureItem('Save and Share Recipes', 'Save your favorite recipes and share them with friends and family.'),
            _buildFeatureItem('Search Functionality', 'Easily search for recipes by meal type, ingredients, or keywords.'),
            const SizedBox(height: 30),

            // Contact Section
            const Text(
              'Contact Us:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Email: meal.match.prachi@gmail.com',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Version Section
            const Text(
              'App Version: 1.0.0',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for creating features list
  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 20, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeedbackSupportPage extends StatefulWidget {
  const FeedbackSupportPage({super.key});

  @override
  _FeedbackSupportPageState createState() => _FeedbackSupportPageState();
}

class _FeedbackSupportPageState extends State<FeedbackSupportPage> {
  // Controller to manage the TextField
  final TextEditingController feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback & Support', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff437069),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feedback Form Section
            const Text(
              'Submit Feedback',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'We value your feedback! Please share your thoughts, issues, or suggestions with us.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: feedbackController, // Connect controller to TextField
              decoration: const InputDecoration(
                labelText: 'Your Feedback',
                hintText: 'Enter your feedback here',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Logic for submitting feedback
                feedbackController.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback submitted!')),
                );
              },
              child: const Text(
                'Submit Feedback',
                style: TextStyle(color: Colors.white), // White text color for button
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff00473d), // Primary color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 60), // Padding for button
                elevation: 5, // Shadow elevation
                shadowColor: Colors.black.withOpacity(0.3), // Shadow color
              ),
            ),

            const SizedBox(height: 30),

            // FAQ Section
            const Text(
              'Frequently Asked Questions (FAQ)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildFAQItem('How can I reset my password?', 'To reset your password, go to the login screen and click "Forgot Password".'),
            _buildFAQItem('How do I change my profile picture?', 'To update your profile image, go to "Account Settings", click on "My Account", then tap Change Profile Image to choose a new photo. After selecting the image, click "Save Changes" to update your profile picture.'),
            _buildFAQItem('How do I change my username?', 'To update your username, go to "Account Settings", click on "My Account", type your new username in the text box, and click "Save Changes" to update it.'),
            _buildFAQItem('Where can I find recipes?', 'You can find recipes by using the search bar on the home page.'),
            const SizedBox(height: 30),

            // Contact Information Section
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Email: meal.match.prachi@gmail.com',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Helper method for creating FAQ items
  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(answer, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}