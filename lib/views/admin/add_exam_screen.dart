import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AddExamScreen extends StatefulWidget {
  final Category? category;
  const AddExamScreen({super.key, this.category});

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Exam')),
      body: const Center(child: Text('Add Exam Screen Placeholder')),
    );
  }
}
