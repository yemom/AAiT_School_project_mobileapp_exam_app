import 'package:another_exam_app/model/category.dart';
import 'package:another_exam_app/theme/theme.dart';
import 'package:flutter/material.dart';

class AddCategoryScreen extends StatefulWidget {
  final Category? category;
  const AddCategoryScreen({super.key, this.category});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text('Add Category'),
      ),
      body: Center(child: Text('Add Category Screen')),
    );
  }
}
