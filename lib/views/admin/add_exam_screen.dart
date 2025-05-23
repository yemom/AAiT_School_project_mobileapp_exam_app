import 'package:another_exam_app/model/category.dart';
import 'package:another_exam_app/model/exam.dart';
import 'package:another_exam_app/model/question.dart';
import 'package:another_exam_app/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddExamScreen extends StatefulWidget {
  final String? categoryId;
  const AddExamScreen({super.key, required this.categoryId});

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class QuestionFormItem {
  final TextEditingController questionController;
  final List<TextEditingController> optionController;
  int correctOptionIndex;

  QuestionFormItem({
    required this.questionController,
    required this.optionController,
    required this.correctOptionIndex,
  });

  void dispose() {
    questionController.dispose();
    optionController.forEach((element) {
      element.dispose();
    });
  }
}

class _AddExamScreenState extends State<AddExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeLimitCOntroller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedCategoryId;
  List<QuestionFormItem> _questionItems = [];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _addQuestion();
  }

  @override
  void dispose() {
    _timeLimitCOntroller.dispose();
    for (var item in _questionItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questionItems.add(
        QuestionFormItem(
          questionController: TextEditingController(),
          optionController: List.generate(4, (_) => TextEditingController()),
          correctOptionIndex: 0,
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questionItems[index].dispose();
      _questionItems.removeAt(index);
    });
  }

  Future<void> _saveExam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please select a category")));
      return;
    }

    try {
      final question =
          _questionItems
              .map(
                (item) => Question(
                  text: item.questionController.text.trim(),
                  options:
                      item.optionController.map((e) => e.text.trim()).toList(),
                  correctOptionIndex: item.correctOptionIndex,
                ),
              )
              .toList();

      await _firestore
          .collection("exames")
          .doc()
          .set(
            Exam(
              id: _firestore.collection("exames").doc().id,
              title: _titleController.text.trim(),
              category: _selectedCategoryId!,
              timeLimit: int.parse(_timeLimitCOntroller.text),
              questions: question,
              createdAt: DateTime.now(),
              updatedAt: null,
            ).toMap(),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Exam added successfully",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to add exam",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Exam',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Exam Detail",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _timeLimitCOntroller,
                  decoration: InputDecoration(
                    labelText: "Exam Title",
                    hintText: "Enter exam title",
                    prefixIcon: Icon(Icons.title, color: AppTheme.primaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter exam title";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                if (widget.categoryId == null)
                  StreamBuilder(
                    stream:
                        _firestore
                            .collection("categories")
                            .orderBy("name")
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text("Error");
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        // Changed to !snapshot.hasData || snapshot.data!.docs.isEmpty for better handling
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        );
                      }
                      final categories =
                          snapshot.data!.docs
                              .map(
                                (doc) => Category.fromMap(doc.id, doc.data()),
                              )
                              .toList();
                      return DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: "Category",
                          hintText: "Select category",
                          prefixIcon: Icon(
                            Icons.category,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        items:
                            categories
                                .map(
                                  (cat) => DropdownMenuItem(
                                    child: Text(cat.name),
                                    value: cat.id,
                                  ),
                                )
                                .toList(), // Fixed typo here
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
