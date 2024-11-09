import 'package:flutter/material.dart';

    class MealPlanner extends StatefulWidget {
  const MealPlanner({super.key});

  @override
  State<MealPlanner> createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal planner Page'),
      ),
    );
  }
}
