import 'package:another_exam_app/model/category.dart';
import 'package:another_exam_app/model/exam.dart';
import 'package:another_exam_app/model/question.dart';
import 'package:another_exam_app/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddExamScreen extends StatefulWidget {
  final String? categoryId;
  final String? examId;
  final VoidCallback? onExamAdded;
  const AddExamScreen({
    super.key,
    required this.categoryId,
    this.examId,
    this.onExamAdded,
  });

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
    for (var element in optionController) {
      element.dispose();
    }
  }
}

class _AddExamScreenState extends State<AddExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeLimitController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedCategoryId;
  final List<QuestionFormItem> _questionItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    if (widget.examId != null) {
      _loadExamData();
    } else {
      _addQuestion(); // Add initial question only for new exams
    }
  }

  Future<void> _loadExamData() async {
    try {
      final examDoc =
          await _firestore.collection("exames").doc(widget.examId).get();
      if (examDoc.exists) {
        final exam = Exam.fromMap(
          examDoc.id,
          examDoc.data() as Map<String, dynamic>,
        );
        _titleController.text = exam.title;
        _timeLimitController.text = exam.timeLimit.toString();
        _selectedCategoryId = exam.category;

        // Clear existing questions and add questions from the loaded exam
        _questionItems.clear();
        for (var question in exam.questions) {
          _questionItems.add(
            QuestionFormItem(
              questionController: TextEditingController(text: question.text),
              optionController:
                  question.options
                      .map((option) => TextEditingController(text: option))
                      .toList(),
              correctOptionIndex: question.correctOptionIndex,
            ),
          );
        }
        setState(() {}); // Update UI after loading data
      }
    } catch (e) {
      print("Error loading exam data: $e");
      // Handle error, maybe show a snackbar
    }
  }

  @override
  void dispose() {
    _timeLimitController.dispose();
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
    setState(() {
      _isLoading = true;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please select a category")));
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!mounted) return;

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

      final exam =
          Exam(
            id: widget.examId ?? _firestore.collection("exames").doc().id,
            title: _titleController.text.trim(),
            category: _selectedCategoryId!,
            timeLimit: int.parse(_timeLimitController.text),
            questions: question,
            createdAt: DateTime.now(),
            updatedAt: null,
          ).toMap();

      await _firestore
          .collection("exames")
          .doc(widget.examId ?? _firestore.collection("exames").doc().id)
          .set(exam);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Exam saved successfully",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (widget.onExamAdded != null) {
        widget.onExamAdded!();
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to save exam",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.examId == null ? "Add ${widget.examId} Exam" : 'Edit Exam',
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
                  controller: _titleController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
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
                  StreamBuilder<QuerySnapshot>(
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
                                (doc) => Category.fromMap(
                                  doc.id,
                                  doc.data() as Map<String, dynamic>? ?? {},
                                ),
                              )
                              .toList();
                      return DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(vertical: 20),
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
                                    value: cat.id,
                                    child: Text(cat.name),
                                  ),
                                )
                                .toList(), // Fixed typo here
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        validator: (value) {
                          return value == null
                              ? "Please select a category"
                              : null;
                        },
                      );
                    },
                  ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _timeLimitController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                    labelText: "Time Limit (in minutes)",
                    hintText: "Enter time limit",
                    prefixIcon: Icon(Icons.timer, color: AppTheme.primaryColor),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter time limit";
                    }
                    final number = int.tryParse(value);
                    if (number == null || number <= 0) {
                      return "Please enter a valid time limit";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Questions",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addQuestion,
                          label: Text("Add Question"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ..._questionItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final QuestionFormItem question = entry.value;

                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Question ${index + 1}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  if (_questionItems.length > 1)
                                    IconButton(
                                      onPressed: () {
                                        _removeQuestion(index);
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 16),

                              TextFormField(
                                controller: question.questionController,
                                decoration: InputDecoration(
                                  labelText: "Question Title",
                                  hintText: "Enter question",
                                  prefixIcon: Icon(
                                    Icons.question_answer,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter question";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              ...question.optionController.asMap().entries.map((
                                entry,
                              ) {
                                final optionIndex = entry.key;
                                final controller = entry.value;

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Radio<int>(
                                        activeColor: AppTheme.primaryColor,
                                        value: optionIndex,
                                        groupValue: question.correctOptionIndex,
                                        onChanged: (value) {
                                          setState(() {
                                            question.correctOptionIndex =
                                                value!;
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: controller,
                                          decoration: InputDecoration(
                                            labelText:
                                                "Option ${optionIndex + 1}",
                                            hintText: "Enter option",
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Please enter option";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 32),
                    Center(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveExam,
                          child:
                              _isLoading
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    "Save Exam",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
