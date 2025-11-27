import 'package:another_exam_app/model/category.dart' as model;
import 'package:another_exam_app/service/authenticate.dart';
import 'package:another_exam_app/theme/theme.dart';
import 'package:another_exam_app/views/user/category_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

Map<String, dynamic> safeDoc(DocumentSnapshot snap) =>
    (snap.data() as Map<String, dynamic>?) ?? {};

List<Map<String, dynamic>> safeList(dynamic raw) {
  if (raw is List) {
    return raw.map((e) => (e as Map<String, dynamic>? ?? {})).toList();
  }
  return <Map<String, dynamic>>[];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<model.Category> _allCategories = [];
  List<model.Category> _filteredCategories = [];
  List<String> _categoryFiltters = ['All'];
  String _selectedFiltter = "All";

  // Add size variables
  late double mediumIconSize;
  late double smallIconSize;
  late double titleFontSize;
  late double subtitleFontSize;
  late double bodyFontSize;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _calculateSizes(BuildContext context) {
    final size = MediaQuery.of(context).size;
    mediumIconSize = size.width * 0.06;
    smallIconSize = size.width * 0.04;
    titleFontSize = size.width * 0.06;
    subtitleFontSize = size.width * 0.04;
    bodyFontSize = size.width * 0.035;
  }

  Future<void> _fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('categories')
            .orderBy('createdAt', descending: true)
            .get();

    setState(() {
      _allCategories =
          snapshot.docs
              .map((doc) => model.Category.fromMap(doc.id, doc.data()))
              .toList();

      _categoryFiltters =
          ['All'] +
          _allCategories.map((category) => category.name).toSet().toList();

      _filteredCategories = _allCategories;
    });
  }

  void _filterdCategories(String query, {String? categoryFilter}) {
    setState(() {
      _filteredCategories =
          _allCategories.where((cat) {
            // Changed variable name from Category to cat
            final matchSearch =
                cat.name.toLowerCase().contains(query.toLowerCase()) ||
                cat.description.toLowerCase().contains(query.toLowerCase());
            final matchCategory =
                categoryFilter == null ||
                categoryFilter == "All" ||
                cat.name.toLowerCase() == categoryFilter.toLowerCase();
            return matchSearch && matchCategory;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    _calculateSizes(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            floating: true,
            centerTitle: true,
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            title: Text(
              "Exam App",
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            elevation: 0.0,
            actions: [
              IconButton(
                icon: Icon(Icons.exit_to_app),
                color: AppTheme.backgroundColor,
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final route = MaterialPageRoute(
                    builder: (context) => const Authenticate(),
                  );
                  await FirebaseAuth.instance.signOut();
                  navigator.pushReplacement(route);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: kToolbarHeight + 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Welcome Student!",
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Lets test your knowledge today",
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) => _filterdCategories(value),
                              decoration: InputDecoration(
                                hintText: "search categories....",
                                suffixIcon:
                                    _searchController.text.isNotEmpty
                                        ? IconButton(
                                          onPressed: () {
                                            _searchController.clear();
                                            _filterdCategories('');
                                          },
                                          icon: Icon(Icons.clear),
                                          color: AppTheme.primaryColor,
                                        )
                                        : null,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              collapseMode: CollapseMode.pin,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16),
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categoryFiltters.length,
                itemBuilder: (context, index) {
                  final filter = _categoryFiltters[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color:
                              _selectedFiltter == filter
                                  ? Colors.white
                                  : AppTheme.textPrimaryColor,
                        ),
                      ),
                      selected: _selectedFiltter == filter,
                      selectedColor: AppTheme.primaryColor,
                      backgroundColor: Colors.white,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedFiltter = filter;
                          _filterdCategories(
                            _searchController.text,
                            categoryFilter: filter,
                          );
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver:
                _filteredCategories.isEmpty
                    ? SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          "No categorires found",
                          style: TextStyle(color: AppTheme.textScondaryColor),
                        ),
                      ),
                    )
                    : SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildCategoryCard(
                          _filteredCategories[index],
                          index,
                        ),
                        childCount: _filteredCategories.length,
                      ),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200.0,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(model.Category category, int index) {
    return SingleChildScrollView(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryScreen(category: category),
                  ),
                );
              },
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.quiz,
                          color: AppTheme.primaryColor,
                          size: mediumIconSize,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: titleFontSize * 0.8,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        category.description,
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          color: AppTheme.textScondaryColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * index))
        .slideY(begin: 0.5, end: 0, duration: Duration(milliseconds: 300))
        .fadeIn();
  }
}
