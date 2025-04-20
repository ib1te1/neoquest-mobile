// lib/providers/auth_provider.dart
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

  // Регистрация с дополнительными данными: имя и возраст
  Future<bool> register(String email, String password, String name, int age) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    print('⏳ Регистрация началась: $email');

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Успешная регистрация в FirebaseAuth');
      String uid = credential.user!.uid;
      DatabaseReference userRef = _database.ref('users/$uid');
      await userRef.set({
        'email': email,
        'name': name,
        'age': age,
        'registeredAt': DateTime.now().toIso8601String(),
        'progress': 0,
      });
      print('✅ Данные пользователя сохранены в Realtime Database');
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      print('❌ Ошибка регистрации: ${e.message}');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Вход с проверкой существования профиля в Realtime Database
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    print('⏳ Вход начался: $email');

    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Успешный вход в FirebaseAuth');
      String uid = credential.user!.uid;
      DatabaseReference userRef = _database.ref('users/$uid');

      // Если профиль отсутствует — создаем его
      final snapshot = await userRef.get();
      if (!snapshot.exists) {
        print('⚠️ Профиль не найден, создаем новый');
        await userRef.set({
          'email': email,
          'registeredAt': DateTime.now().toIso8601String(),
          'progress': 0,
        });
      }
      else {
        print('✅ Профиль найден в Realtime Database');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Ошибка входа: ${e.message}');
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