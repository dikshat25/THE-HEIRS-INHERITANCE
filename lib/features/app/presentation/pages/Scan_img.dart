import 'package:flutter/material.dart';
class ScanImg extends StatefulWidget {
  const ScanImg({super.key});

  @override
  State<ScanImg> createState() => _ScanImgState();
}

class _ScanImgState extends State<ScanImg> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
    );
  }
}
