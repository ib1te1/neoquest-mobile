
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  User? get currentUser => _auth.currentUser;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> register(
      String email,
      String password,
      String name,
      int age,
      ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now().toIso8601String();
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final userRef = _database.ref('users/$uid');

      await userRef.set({
        'email': email,
        'name': name,
        'age': age,
        'registeredAt': now,
        'progress': 1,
        'points': 0,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential credential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = credential.user!.uid;
      final userRef = _database.ref('users/$uid');

      final snapshot = await userRef.get();
      if (!snapshot.exists) {
        final now = DateTime.now().toIso8601String();
        await userRef.set({
          'email': email,
          'registeredAt': now,
          'progress': 1,
          'points': 0,
        });
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
