import 'package:another_exam_app/firebase_options.dart';
import 'package:another_exam_app/login.dart';
import 'package:another_exam_app/theme/theme.dart';
import 'package:another_exam_app/views/admin/admin_home_screen.dart';
import 'package:another_exam_app/views/user/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(MyApp());
  } catch (e) {
    print("Error initializing Firebase: $e");

    runApp(ErrorApp(error: e));
  }
}

class ErrorApp extends StatelessWidget {
  final Object error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Error: ${error.toString()}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      title: "Exam App",
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  Future<String?> _fetchUserRole(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final Map<String, dynamic>? data = userDoc.data();
      return data?['role'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<auth.User?>(
      stream: auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final auth.User? user = authSnapshot.data;
        if (user == null) {
          return Login(toggleView: () {});
        }

        return FutureBuilder<String?>(
          future: _fetchUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final String? role = roleSnapshot.data;
            if (role == 'Admin') {
              return const AdminHomeScreen();
            }
            if (role == 'User') {
              return const HomeScreen();
            }
            return Login(toggleView: () {});
          },
        );
      },
    );
  }
}
