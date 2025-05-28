import 'package:another_exam_app/service/auth.dart';
import 'package:another_exam_app/signup.dart';
import 'package:another_exam_app/theme/theme.dart';
import 'package:another_exam_app/views/admin/admin_home_screen.dart';
import 'package:another_exam_app/views/user/home_screen.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _authService = AuthService(); // Instance of AuthService
  // Controller for email input
  final _emailController = TextEditingController();
  // Controller for password input
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true; // Show spinner
    });

    String? result = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false; // Hide spinner
    });

    // Navigate based on role or show error message
    if (result == 'Admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminHomeScreen()),
      );
    } else if (result == 'User') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login Failed: $result')));
    }
  }

  bool isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          "Exam App",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(18), // Add padding
          child: Column(
            children: [
              Image.asset("lib/assets/login-icon-vector_942802-6305.avif"),
              const SizedBox(height: 50),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Input for password
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                    icon: Icon(
                      isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                obscureText: true, // Hide password
              ),
              const SizedBox(height: 30),
              // Login button or spinner
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login, // Call login function
                      child: const Text('Login'),
                    ),
                  ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 18),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => Signup()),
                      );
                    },
                    child: const Text(
                      "Signup here",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
