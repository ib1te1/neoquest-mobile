
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class QuestProvider with ChangeNotifier {
  int currentStage = 1;
  int points = 0;
  bool questAttempted = false;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  StreamSubscription<User?>? _authSub;

  QuestProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _loadState();
      } else {
        _resetLocal();
      }
    });
  }

  void _resetLocal() {
    currentStage = 1;
    points = 0;
    questAttempted = false;
    notifyListeners();
  }

  Future<void> _loadState() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _resetLocal();
      return;
    }
    final userRef = _database.ref('users/$uid');

    final attemptedSnap = await userRef.child('questAttempted').get();
    questAttempted = attemptedSnap.exists && attemptedSnap.value == true;

    final progressSnap = await userRef.child('progress').get();
    if (progressSnap.exists && progressSnap.value is int && (progressSnap.value as int) >= 1) {
      currentStage = progressSnap.value as int;
    } else {
      currentStage = 1;
    }

    final pointsSnap = await userRef.child('points').get();
    points = (pointsSnap.exists && pointsSnap.value is int) ? pointsSnap.value as int : 0;

    if (questAttempted && currentStage <= 5) {
      currentStage = 6;
    }

    notifyListeners();
  }

  Future<void> completeStage({required int awardedPoints}) async {
    if (questAttempted) return;

    points += awardedPoints;
    currentStage++;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userRef = _database.ref('users/$uid');

    final updates = <String, dynamic>{
      'progress': currentStage,
      'points': points,
    };
    if (currentStage > 5) {
      questAttempted = true;
      updates['questAttempted'] = true;
    }

    await userRef.update(updates);
    notifyListeners();
  }

  Future<void> resetQuest() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _resetLocal();
      return;
    }
    final userRef = _database.ref('users/$uid');

    currentStage = 1;
    points = 0;
    questAttempted = false;

    await userRef.update({
      'progress': 1,
      'points': 0,
    });
    await userRef.child('questAttempted').remove();

    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
