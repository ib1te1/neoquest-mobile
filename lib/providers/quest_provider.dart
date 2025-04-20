// lib/providers/quest_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class QuestProvider with ChangeNotifier {
  int currentStage = 1;
  int points = 0;
  final _db = FirebaseDatabase.instance;

  Future<void> completeStage({required int awardedPoints}) async {
    points += awardedPoints;
    currentStage++;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _db.ref('users/$uid').update({
      'progress': currentStage,
      'points': points,
    });
    notifyListeners();
  }

  void resetQuest() {
    currentStage = 1;
    points = 0;
    notifyListeners();
  }
}
