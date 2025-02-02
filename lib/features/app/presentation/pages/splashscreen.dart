import 'package:flutter/material.dart';
import 'package:mealmatch/features/app/presentation/pages/root_page.dart';
import 'package:mealmatch/features/app/presentation/pages/onboarding_intro.dart';
import 'package:mealmatch/features/app/presentation/pages/onboarding.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({super.key, this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    // Define the fade animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Define the scale animation
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // Start the fade-in animation and scaling animation
    _controller.forward();

    // Navigate after a delay
    Future.delayed(
      Duration(seconds: 4),
          () {
        if (widget.child != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => widget.child!),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => widget.child ?? OnboardingScreen()),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFBEF2D0), Color(0xFFEDF1EF)], // Green gradient
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                'Assets/logoandslogan.png', // Replace with your logo image path
                width: 500.0, // Adjust the size of the logo
                height: 500.0, // Adjust the size of the logo
              ),
            ),
          ),
        ),
      ),
    );
  }
}