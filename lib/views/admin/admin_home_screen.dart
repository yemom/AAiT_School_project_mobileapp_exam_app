import 'package:another_exam_app/service/authenticate.dart';
import 'package:another_exam_app/theme/theme.dart';
import 'package:another_exam_app/views/admin/adminSignupForm.dart';
import 'package:another_exam_app/views/admin/manage_categories_screen.dart';
import 'package:another_exam_app/views/admin/manage_exames_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:another_exam_app/service/auth.dart' as app_auth;

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final app_auth.AuthService _authService = app_auth.AuthService();
  bool _isSuperAdmin = false;

  // Add size variables with constraints
  late double mediumIconSize;
  late double smallIconSize;
  late double titleFontSize;
  late double subtitleFontSize;
  late double bodyFontSize;

  void _calculateSizes(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    // Add constraints to prevent too large or too small sizes
    mediumIconSize = (width * 0.06).clamp(24.0, 40.0);
    smallIconSize = (width * 0.04).clamp(16.0, 28.0);
    titleFontSize = (width * 0.06).clamp(20.0, 32.0);
    subtitleFontSize = (width * 0.04).clamp(14.0, 24.0);
    bodyFontSize = (width * 0.035).clamp(12.0, 18.0);
  }

  void _refreshData() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _checkSuperAdmin();
  }

  Future<void> _checkSuperAdmin() async {
    final isSuper = await _authService.isSuperAdmin();
    if (mounted) {
      setState(() {
        _isSuperAdmin = isSuper;
      });
    }
  }

  // Removed unused: _showPromoteDialog
  /*Future<void> _showPromoteDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Promote to Admin'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Target User UID',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final uid = controller.text.trim();
                if (uid.isEmpty) return;
                try {
                  await _authService.promoteUserToAdmin(targetUid: uid);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User promoted to admin')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                  }
                }
              },
              child: const Text('Promote'),
            ),
          ],
        );
      },
    );
  }*/

  Future<Map<String, dynamic>> _ftechStatistics() async {
    final categoriesCount =
        await _firestore.collection('categories').count().get();

    final examesCount = await _firestore.collection('exames').count().get();

    final latestExames =
        await _firestore
            .collection('exames')
            .orderBy('createdAt', descending: true)
            .limit(5)
            .get();

    final categories = await _firestore.collection('categories').get();
    final categoryData = await Future.wait(
      categories.docs.map((category) async {
        final exameCount =
            await _firestore
                .collection('exames')
                .where('category', isEqualTo: category.id)
                .count()
                .get();
        final categoryName =
            (category.data() as Map<String, dynamic>?)?['name'] as String? ??
            'Unknown Category';
        final examCountValue = exameCount.count;
        return {
          'name': categoryName,
          'count': examCountValue is int ? examCountValue : 0,
        };
      }),
    );

    return {
      'totalCategories': categoriesCount.count,
      'totalExames': examesCount.count,
      'latestExames': latestExames.docs,
      'categoryData': categoryData,
    };
  }

  String _formatData(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStateCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: mediumIconSize),
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: titleFontSize * 0.9,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: subtitleFontSize * 0.9,
                color: AppTheme.textScondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: mediumIconSize,
                ),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _calculateSizes(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: titleFontSize * 0.9,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, size: mediumIconSize),
            color: AppTheme.textPrimaryColor,
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Authenticate()),
              );
            },
          ),
        ],
      ),
      floatingActionButton:
          _isSuperAdmin
              ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminSignupForm()),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Register Admin'),
              )
              : null,

      body: FutureBuilder<Map<String, dynamic>>(
        future: _ftechStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final Map<String, dynamic> stats = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Admin",
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Here's you'r exam application overview",
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: AppTheme.textScondaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStateCard(
                          'Total Categories',
                          stats['totalCategories'].toString(),
                          Icons.category_rounded,
                          AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStateCard(
                          'Total Exam',
                          stats['totalExames'].toString(),
                          Icons.assignment_rounded,
                          AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pie_chart_rounded,
                                color: AppTheme.primaryColor,
                                size: mediumIconSize,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Category Statistics',
                                style: TextStyle(
                                  fontSize: titleFontSize * 0.8,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: stats['categoryData'].length,
                            itemBuilder: (context, index) {
                              final data = stats['categoryData'][index];
                              final totalExames = stats['categoryData']
                                  .fold<int>(
                                    0,
                                    (int sum, Map<String, dynamic> item) =>
                                        sum + ((item['count'] as int?) ?? 0),
                                  );
                              final percentage =
                                  totalExames > 0
                                      ? (data['count'] as int) /
                                          totalExames *
                                          100
                                      : 0.0;

                              return Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name'] as String,
                                            style: TextStyle(
                                              fontSize: subtitleFontSize * 0.9,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textPrimaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            "${data['count']} ${(data['count'] as int) == 1 ? 'exam' : 'exames'}",
                                            style: TextStyle(
                                              fontSize: bodyFontSize,
                                              color: AppTheme.textScondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${percentage.toStringAsExponential(1)}%',
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                color: AppTheme.primaryColor,
                                size: mediumIconSize,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Recent Activity',
                                style: TextStyle(
                                  fontSize: titleFontSize * 0.8,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: stats['latestExames'].length,
                            itemBuilder: (context, index) {
                              final examData =
                                  stats['latestExames'][index].data()
                                      as Map<String, dynamic>;

                              return Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.assignment_rounded,
                                        color: AppTheme.primaryColor,
                                        size: smallIconSize,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            examData['title'],
                                            style: TextStyle(
                                              fontSize: subtitleFontSize * 0.9,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Created on ${_formatData(examData['createdAt'].toDate())}',
                                            style: TextStyle(
                                              color: AppTheme.textScondaryColor,
                                              fontSize: bodyFontSize,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.speed_rounded,
                                color: AppTheme.primaryColor,
                                size: mediumIconSize,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Exam Action',
                                style: TextStyle(
                                  fontSize: titleFontSize * 0.8,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,

                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                            crossAxisSpacing: 16,
                            children: [
                              _buildNavigationCard(
                                'Manage Exames',
                                Icons.assignment_turned_in_rounded,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ManageExamesScreen(
                                            onExamAdded: _refreshData,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              _buildNavigationCard(
                                'Manage Categories',
                                Icons.category_rounded,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ManageCategoriesScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
