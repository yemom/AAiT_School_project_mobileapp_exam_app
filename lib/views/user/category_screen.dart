import 'package:another_exam_app/model/category.dart' as model; // Add prefix
import 'package:another_exam_app/model/exam.dart';
import 'package:another_exam_app/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  final model.Category category; // Use the prefixed type
  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Exam> _exames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExames();
  }

  Future<void> _fetchExames() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection("exames")
              .where('category', isEqualTo: widget.category.id)
              .get();
      setState(() {
        _exames =
            snapshot.docs
                .map((doc) => Exam.fromMap(doc.id, doc.data()))
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Faild to load exames")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
              : _exames.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 64,
                      color: AppTheme.textScondaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No exams available in this category",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textScondaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Go Back"),
                    ),
                  ],
                ),
              )
              : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    foregroundColor: Colors.white,
                    backgroundColor: AppTheme.primaryColor,
                    expandedHeight: 230,
                    floating: false,
                    pinned: true,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.category.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                      background: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_rounded,
                              size: 64,
                              color: Colors.white,
                            ),
                            SizedBox(height: 16),
                            Text(
                              widget.category.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _exames.length,
                        itemBuilder: (context, index) {
                          final exam = _exames[index];
                          return _buildExamCard(exam, index);
                        },
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildExamCard(Exam exam, int index) {
    return Card();
  }
}
