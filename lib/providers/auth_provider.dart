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

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'createdAt': Timestamp.now(),
          'profile': {
            'name': 'User',
            'email': email,
            'phone': '',
            'age': '25',
            'weight': '70 kg',
            'height': '170 cm',
          }
          // Xóa healthMetrics khỏi đây vì sẽ được lấy từ device
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

  Future<bool> logout() async {
    try {
      await _auth.signOut();
      _isLoggedIn = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // 1. Re-authenticate user with password
        try {
          final credentials = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await user.reauthenticateWithCredential(credentials);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'wrong-password') {
            _error = 'Please type "Delete" to confirm';
            notifyListeners();
            return false;
          }
          _error = e.message ?? 'Authentication failed';
          notifyListeners();
          return false;
        }

        // 2. Delete Firestore data
        await _firestore.collection('users').doc(user.uid).delete();

        // 3. Delete authentication account
        await user.delete();

        // 4. Update state
        _isLoggedIn = false;
        notifyListeners();
        return true;
      }
      _error = 'No user found';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Please type "Delete" to confirm';
      notifyListeners();
      return false;
    }
  }
}
