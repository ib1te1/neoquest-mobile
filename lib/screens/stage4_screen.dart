import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quest_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/relation_dialogs.dart';

class Stage4Screen extends StatefulWidget {
  const Stage4Screen({Key? key}) : super(key: key);

  @override
  _Stage4ScreenState createState() => _Stage4ScreenState();
}

class _Stage4ScreenState extends State<Stage4Screen> {
  late Stopwatch stopwatch;
  Timer? timer;
  int elapsedSeconds = 0;

  static const int threshold = 120;
  static const int maxBonus = 20;

  final String secretWord = "development";
  final Set<String> guessedLetters = {};
  int mistakes = 0;
  final int maxMistakes = 7;
  final List<String> alphabet =
  List.generate(26, (i) => String.fromCharCode(97 + i));
  final List<String> hangmanParts = [
    "assets/hangman_base.png",
    "assets/hangman_head.png",
    "assets/hangman_body.png",
    "assets/hangman_right_arm.png",
    "assets/hangman_left_arm.png",
    "assets/hangman_right_leg.png",
    "assets/hangman_left_leg.png",
  ];

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
    super.dispose();
  }

  bool get isWordGuessed =>
      secretWord.split('').every((ch) => guessedLetters.contains(ch));

  void _onLetterSelected(String letter) {
    if (guessedLetters.contains(letter)) return;
    setState(() {
      guessedLetters.add(letter);
      if (!secretWord.contains(letter)) mistakes++;
    });

    if (isWordGuessed) {
      final bonus = max(0, (threshold - elapsedSeconds) * maxBonus ~/ threshold);
      showRelationDialog(
        context: context,
        title: "DEVELOPMENT",
        description:
        "Развитие — ключевое слово для Neoflex. Мы вкладываемся в развитие сотрудников, продуктов и технологий каждый день!",
        onContinue: () {
          Provider.of<QuestProvider>(context, listen: false)
              .completeStage(awardedPoints: 20 + bonus);
        },
      );
    } else if (mistakes >= maxMistakes) {
      _showGameOverDialog();
    }
  }

  void _showHintDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.dark,
        title: Text("Подсказка", style: AppTextStyles.subtitle),
        content: Text(
          "Это слово отражает постоянное стремление к развитию и совершенствованию.",
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

  void _showGameOverDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.dark,
        title: Text("Вы проиграли!", style: AppTextStyles.subtitle),
        content: Text(
          "Вы допустили слишком много ошибок. Этап завершен без начисления очков.",
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Provider.of<QuestProvider>(context, listen: false)
                  .completeStage(awardedPoints: 0);
            },
            child: Text("Пропустить",
                style: AppTextStyles.body.copyWith(color: AppColors.cyan)),
          )
        ],
      ),
    );
  }

  void _skipStage() {
    Provider.of<QuestProvider>(context, listen: false)
        .completeStage(awardedPoints: 0);
  }

  @override
  Widget build(BuildContext context) {
    String displayWord = secretWord
        .split('')
        .map((l) => guessedLetters.contains(l) ? "$l " : "_ ")
        .join();
    Widget hangmanDisplay = Container();
    if (mistakes > 0 && mistakes <= hangmanParts.length) {
      hangmanDisplay = Image.asset(hangmanParts[mistakes - 1], height: 150);
    }

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.violet,
        title: Text("Этап 4: Виселица", style: AppTextStyles.subtitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LinearProgressIndicator(
              value: 0.8,
              backgroundColor: AppColors.grey,
              valueColor: AlwaysStoppedAnimation(AppColors.cyan),
            ),
            const SizedBox(height: 8),
            Text("Время: ${elapsedSeconds}s",
                style: AppTextStyles.body.copyWith(color: AppColors.cyan)),
            const SizedBox(height: 20),
            hangmanDisplay,
            const SizedBox(height: 20),
            Text("Отгадайте слово:", style: AppTextStyles.subtitle),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.purple.withOpacity(0.5)),
              ),
              child: Text(displayWord,
                  style: AppTextStyles.headline, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 20),
            Text("Ошибок: $mistakes/$maxMistakes",
                style: AppTextStyles.body.copyWith(color: AppColors.orange)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: alphabet.map((letter) {
                final used = guessedLetters.contains(letter);
                return ElevatedButton(
                  onPressed: used ? null : () => _onLetterSelected(letter),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: used ? AppColors.grey : AppColors.orange,
                    minimumSize: const Size(40, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(letter.toUpperCase(),
                      style: AppTextStyles.body.copyWith(
                          color: used ? Colors.black38 : Colors.white)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _skipStage,
              child: Text("Пропустить",
                  style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.cyan,
                      decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ),
    );
  }
}