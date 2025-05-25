import 'package:another_exam_app/model/exam.dart';
import 'package:flutter/material.dart';

class ExamPlayScreen extends StatefulWidget {
  final Exam exam;
  const ExamPlayScreen({super.key, required this.exam});

  @override
  State<ExamPlayScreen> createState() => _ExamPlayScreenState();
}

class _ExamPlayScreenState extends State<ExamPlayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
