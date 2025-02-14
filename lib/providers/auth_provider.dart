import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoggedIn = false;
  String? _error;

  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;
  User? get currentUser => _auth.currentUser;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _isLoggedIn = user != null;
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    try {
      _error = null;
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _error = 'No user found for that email.';
          break;
        case 'wrong-password':
          _error = 'Wrong password provided.';
          break;
        case 'invalid-email':
          _error = 'Invalid email address.';
          break;
        default:
          _error = 'An error occurred: ${e.message}';
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      _error = null;
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // // Create user profile in Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'createdAt': Timestamp.now(),
          'healthMetrics': {
            'sleepHours': 8,
            'heartRate': 75,
            'bloodPressure': 120,
            'bloodOxygen': 98,
            'weight': 70.0,
            'stress': 50,
          }
        });
        _isLoggedIn = true;
        notifyListeners();
      }
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _error = 'No user found for that email.';
          break;
        case 'wrong-password':
          _error = 'Wrong password provided.';
          break;
        case 'invalid-email':
          _error = 'Invalid email address.';
          break;
        default:
          _error = 'An error occurred: ${e.message}';
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _isLoggedIn = false;
    notifyListeners();
  }
}
