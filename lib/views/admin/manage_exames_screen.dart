import 'package:another_exam_app/model/category.dart';
import 'package:another_exam_app/model/exam.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:another_exam_app/theme/theme.dart';
import 'package:another_exam_app/views/admin/add_exam_screen.dart';
import 'package:retry/retry.dart';

class ManageExamesScreen extends StatefulWidget {
  final String? categoryId;
  final VoidCallback? onExamAdded;
  const ManageExamesScreen({Key? key, this.categoryId, this.onExamAdded})
    : super(key: key);

  @override
  State<ManageExamesScreen> createState() => _ManageExamesScreenState();
}

class _ManageExamesScreenState extends State<ManageExamesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _searchQuery = "";
  String? _selectedCategoryId;
  List<Category> _categories = [];
  Category? _initialCategory;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final QuerySnapshot categoriesSnapshot = await retry(
        () => _firestore.collection("categories").get(),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 2),
      );

      final categories =
          categoriesSnapshot.docs
              .map(
                (doc) => Category.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();

      setState(() {
        _categories = categories;
        if (widget.categoryId != null) {
          _initialCategory = _categories.firstWhere(
            (category) => category.id == widget.categoryId,
            orElse:
                () => Category(
                  id: widget.categoryId!,
                  name: "Unknown",
                  description: '',
                ),
          );

          _selectedCategoryId = _initialCategory!.id;
        }
      });
    } catch (e) {
      print("Error Fetching Categories: $e");
    }
  }

  Stream<QuerySnapshot> _getExamStream() {
    Query query = _firestore.collection("exames");

    String? filterCategoryId = _selectedCategoryId ?? widget.categoryId;

    if (filterCategoryId != null) {
      query = query.where("category", isEqualTo: filterCategoryId);
    }

    return query.snapshots();
  }

  Widget _buildAppBarTitle() {
    String? selectedCategoryId = _selectedCategoryId ?? widget.categoryId;
    if (selectedCategoryId == null) {
      return const Text(
        "All Exames",
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    } else {
      final selectedCategory = _categories.firstWhere(
        (category) => category.id == selectedCategoryId,
        orElse:
            () => Category(
              id: selectedCategoryId,
              name: "Unknown Category",
              description: '',
            ),
      );
      return Text(
        "Exams in ${selectedCategory.name}",
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: _buildAppBarTitle(),
        actions: [
          IconButton(
            onPressed: () {
              if (_selectedCategoryId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please select a category to add an exam."),
                  ),
                );
              } else {
                final selectedCategory = _categories.firstWhere(
                  (category) => category.id == _selectedCategoryId,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AddExamScreen(
                          categoryId: widget.categoryId,
                          onExamAdded: widget.onExamAdded,
                        ),
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: "Search Exams",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 18.0,
                ),
                border: const OutlineInputBorder(),
                hintText: "Category",
              ),
              value: _selectedCategoryId,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text("All Categories"),
                ),
                if (_initialCategory != null &&
                    !_categories.any((c) => c.id == _initialCategory!.id))
                  DropdownMenuItem(
                    value: _initialCategory!.id,
                    child: Text(_initialCategory!.name),
                  ),
                ..._categories.map(
                  (category) => DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getExamStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print("Error fetching exams: ${snapshot.error}");
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: AppTheme.textScondaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No exams found",
                          style: TextStyle(
                            color: AppTheme.textScondaryColor,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_selectedCategoryId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select a category to add an exam.",
                                  ),
                                ),
                              );
                            } else {
                              final selectedCategory = _categories.firstWhere(
                                (category) =>
                                    category.id == _selectedCategoryId,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AddExamScreen(
                                        categoryId: widget.categoryId,
                                        onExamAdded: widget.onExamAdded,
                                      ),
                                ),
                              );
                            }
                          },
                          child: const Text("Add Exam"),
                        ),
                      ],
                    ),
                  );
                }

                final exams =
                    snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Exam.fromMap(doc.id, data);
                    }).toList();

                List<Exam> filteredExams =
                    exams
                        .where(
                          (exam) => exam.title.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                        )
                        .toList();

                if (filteredExams.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: AppTheme.textScondaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No exams found",
                          style: TextStyle(
                            color: AppTheme.textScondaryColor,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_selectedCategoryId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select a category to add an exam.",
                                  ),
                                ),
                              );
                            } else {
                              final selectedCategory = _categories.firstWhere(
                                (category) =>
                                    category.id == _selectedCategoryId,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AddExamScreen(
                                        categoryId: widget.categoryId,
                                        onExamAdded: widget.onExamAdded,
                                      ),
                                ),
                              );
                            }
                          },
                          child: const Text("Add Exam"),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredExams.length,
                  itemBuilder: (context, index) {
                    final Exam exam = filteredExams[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.assignment_outlined,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        title: Text(
                          exam.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.question_answer_outlined,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    "${exam.questions.length} Questions",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.timer_outlined, size: 16),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    "${exam.timeLimit} Minutes",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (String item) {
                            _handleExamAction(context, item, exam);
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.redAccent,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                        onTap: () {
                          // TODO: Implement navigation to ExamDetailScreen
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExamAction(
    BuildContext context,
    String value,
    Exam exam,
  ) async {
    if (value == "edit") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => AddExamScreen(
                categoryId: exam.category,
                examId: exam.id,
                onExamAdded: widget.onExamAdded,
              ),
        ),
      );
    } else if (value == "delete") {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete Exam"),
            content: const Text("Are you sure you want to delete this exam?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        try {
          await _firestore.collection("exames").doc(exam.id).delete();
        } catch (e) {
          print("Error deleting exam: $e");
          // Handle the error appropriately, e.g., show a snackbar
        }
      }
    }
  }
}
