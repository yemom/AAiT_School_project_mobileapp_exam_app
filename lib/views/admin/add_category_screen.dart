import 'package:another_exam_app/model/category.dart';
import 'package:another_exam_app/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCategoryScreen extends StatefulWidget {
  final Category? category;
  const AddCategoryScreen({super.key, this.category});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController = TextEditingController(
      text: widget.category?.description,
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.category != null) {
        final updatedCategory = widget.category!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );

        await _firestore
            .collection("categories")
            .doc(widget.category!.id)
            .update(updatedCategory.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Category updated successfully!")),
        );
      } else {
        await _firestore
            .collection("categories")
            .add(
              Category(
                id: _firestore.collection("categories").doc().id,
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim(),
                createdAt: DateTime.now(),
              ).toMap(),
            );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Category added successfully!")));
      }
      Navigator.pop(context);
    } catch (e) {
      print(
        "Error: $e",
      ); // Consider using a more robust error handling mechanism
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save category.")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _onWillpop() async {
    if (_nameController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty) {
      return await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text("Discard Change"),
                  content: Text("Are you want to discard changes?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: Text(
                        "Discard",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
          ) ??
          false;
    }
    return true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillpop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          title: Text(
            widget.category != null ? "Edit Category" : "Add Category",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Category Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Create a new category for organixing your exames",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textScondaryColor,
                  ),
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                    fillColor: Colors.white,
                    labelText: "Category Name",
                    hintText: "Enter category name",
                    prefixIcon: Icon(
                      Icons.category_rounded,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  validator:
                      (value) => value!.isEmpty ? "Enter category name" : null,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    labelText: "Description",
                    hintText: "Enter category description",
                    prefixIcon: Icon(
                      Icons.description_rounded,
                      color: AppTheme.primaryColor,
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  validator:
                      (value) =>
                          value!.isEmpty ? "Enter category description" : null,
                  textInputAction: TextInputAction.next,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isLoading ? null : _saveCategory,
          label:
              _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                    widget.category != null
                        ? "Update Category"
                        : "Add Category",
                  ),
          icon: Icon(Icons.save),
          backgroundColor: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
