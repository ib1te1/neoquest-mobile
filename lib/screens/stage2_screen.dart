import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quest_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/relation_dialogs.dart';

class Stage2Screen extends StatefulWidget {
  const Stage2Screen({Key? key}) : super(key: key);

  @override
  _Stage2ScreenState createState() => _Stage2ScreenState();
}

class _Stage2ScreenState extends State<Stage2Screen> {
  late Stopwatch stopwatch;
  Timer? timer;
  int elapsedSeconds = 0;

  static const int threshold = 150;
  static const int maxBonus = 20;

  final String encryptedWord = "YXZXKT";
  final TextEditingController answerController = TextEditingController();
  String? errorText;

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch()..start();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => elapsedSeconds = stopwatch.elapsed.inSeconds);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    stopwatch.stop();
    answerController.dispose();
    super.dispose();
  }

  void _checkAnswer(BuildContext context) {
    final user = answerController.text.trim().toLowerCase();
    if (user == "future") {
      final bonus = max(0, (threshold - elapsedSeconds) * maxBonus ~/ threshold);
      showRelationDialog(
        context: context,
        title: "FUTURE",
        description:
        "Neoflex — это компания будущего: инновации, цифровая трансформация и амбициозные проекты. Future — напоминание о том, куда мы движемся!",
        onContinue: () {
          Provider.of<QuestProvider>(context, listen: false)
              .completeStage(awardedPoints: 15 + bonus);
        },
      );
    } else {
      setState(() {
        errorText =
        "Неверно! Подсказка: буквы алфавита заменяются на буквы, расположенные по порядку на клавиатуре.";
      });
    }
  }

  void _skipStage(BuildContext context) {
    Provider.of<QuestProvider>(context, listen: false)
        .completeStage(awardedPoints: 0);
  }

  void _showHintDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.dark,
        title: Text("Подсказка", style: AppTextStyles.subtitle),
        content: Text(
          "Это шифр подстановкой. Буквы алфавита заменяются на буквы, расположенные по порядку на клавиатуре.",
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Закрыть",
                style: AppTextStyles.body.copyWith(color: AppColors.cyan)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.violet,
        title: Text("Этап 2: Шифр подстановкой", style: AppTextStyles.subtitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: 0.4,
              backgroundColor: AppColors.grey,
              valueColor: AlwaysStoppedAnimation(AppColors.cyan),
            ),
            const SizedBox(height: 8),
            Text(
              "Время: ${elapsedSeconds}s",
              style: AppTextStyles.body.copyWith(color: AppColors.cyan),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text(
              "Это шифр подстановкой!\nРасшифруйте слово:",
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.purple.withOpacity(0.5)),
              ),
              child: Center(
                child: Text(
                  encryptedWord,
                  style: AppTextStyles.headline,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: answerController,
              style: AppTextStyles.body.copyWith(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Ваш ответ",
                labelStyle: AppTextStyles.body.copyWith(color: Colors.white70),
                errorText: errorText,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _checkAnswer(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Проверить", style: AppTextStyles.body.copyWith(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => _skipStage(context),
                  child: Text("Пропустить",
                      style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.cyan,
                          decoration: TextDecoration.underline)),
                ),
                TextButton(
                  onPressed: _showHintDialog,
                  child: Text("Подсказка",
                      style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.cyan,
                          decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
