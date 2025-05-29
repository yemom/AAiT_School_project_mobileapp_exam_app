import 'package:another_exam_app/model/category.dart' as model; // Add prefix
import 'package:another_exam_app/model/exam.dart';
import 'package:another_exam_app/theme/theme.dart';
import 'package:another_exam_app/views/user/exam_play_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
      print('Fetching exams for category ID: ${widget.category.id}');
      final snapshot =
          await FirebaseFirestore.instance
              .collection("exames")
              .where('category', isEqualTo: widget.category.id)
              .get();

      print('Number of documents found: ${snapshot.docs.length}');

      for (var doc in snapshot.docs) {
        print('Found exam document ID: ${doc.id}');
      }

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
                    expandedHeight: 200,
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
                      padding: EdgeInsets.symmetric(horizontal: 16),
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
    // Add this print statement:
    print('Debugging exam title: ${exam.title}');
    return Card(
          margin: EdgeInsets.only(bottom: 16),
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExamPlayScreen(exam: exam),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.quiz_rounded,
                      color: AppTheme.primaryColor,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.question_answer_outlined, size: 16),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${exam.questions.length} Questions',
                                  ),
                                ),

                                Icon(Icons.timer_outlined, size: 16),
                                SizedBox(width: 4),
                                Expanded(child: Text('${exam.timeLimit} mins')),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 30,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.5, end: 0, duration: Duration(milliseconds: 300))
        .fadeIn();
  }
}
