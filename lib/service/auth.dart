import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_functions/cloud_functions.dart';

class AuthService {
  // Firebase Authentication instance
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to handle user signup
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Create user in Firebase Authentication with email and password
      auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      // Save additional user data (name, role) in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': role, // Role determines if user is Admin or User
      });

      return null; // Success: no error message
    } catch (e) {
      return e.toString(); // Error: return the exception message
    }
  }

  // Function to handle user login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in the user using Firebase Authentication
      auth.UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      // Fetch the user's role from Firestore to determine access level
      DocumentSnapshot userDoc =
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      // Return based on role
      if (role == "admin") {
        return "Admin";
      } else if (role == "super_admin") {
        return "Admin"; // optional: separate SuperAdmin screen
      } else {
        return "User";
      }
    } on FirebaseAuthException catch (e) {
      return e.code; // like 'firebase_auth/wrong-password'
    } catch (e) {
      return e.toString(); // Error: return the exception message
    }
  }

  // for user log out
  signOut() async {
    _auth.signOut();
  }

  // Claims helpers
  Future<bool> isSuperAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final idTokenResult = await user.getIdTokenResult(true);
    final claims = idTokenResult.claims;
    return claims != null && claims['superAdmin'] == true;
  }

  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final idTokenResult = await user.getIdTokenResult(true);
    final claims = idTokenResult.claims;
    return claims != null &&
        (claims['admin'] == true || claims['superAdmin'] == true);
  }

  // Super-admin only: promote a user to admin via callable function
  Future<void> promoteUserToAdmin({required String targetUid}) async {
    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    final callable = functions.httpsCallable('promoteToAdmin');
    await callable.call(<String, dynamic>{'uid': targetUid});
  }
}
