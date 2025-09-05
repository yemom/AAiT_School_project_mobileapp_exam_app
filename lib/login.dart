import 'package:another_exam_app/service/auth.dart';
import 'package:another_exam_app/signup.dart';
import 'package:another_exam_app/theme/theme.dart';
import 'package:another_exam_app/views/admin/admin_home_screen.dart';
import 'package:another_exam_app/views/user/home_screen.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key, required void Function() toggleView});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool isPasswordHidden = true;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    String? result = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    print('Login result: $result');

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
    } else if (result != null &&
        result.contains('firebase_auth/user-not-found')) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not registered. Please sign up.'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (result != null &&
        result.contains('firebase_auth/wrong-password')) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Failed: $result'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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

      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              children: [
                Image.network(
                  'https://img.freepik.com/premium-vector/login-icon-vector_942802-6305.jpg',
                ),
                SizedBox(height: 10),

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: isPasswordHidden,
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
                ),
                SizedBox(height: 20),

                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        // Call login function
                        child: const Text('Login'),
                      ),
                    ),

                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
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
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
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
      ),
    );
  }
}
