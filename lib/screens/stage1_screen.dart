import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quest_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/relation_dialogs.dart';

class Stage1Screen extends StatefulWidget {
  const Stage1Screen({Key? key}) : super(key: key);

  @override
  _Stage1ScreenState createState() => _Stage1ScreenState();
}

class _Stage1ScreenState extends State<Stage1Screen> {
  late Stopwatch stopwatch;
  Timer? timer;
  int elapsedSeconds = 0;

  static const int threshold = 150; // 2 минуты на размышление
  static const int maxBonus = 20;

  final String encryptedMessage = "qhriohia txhvw";
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
    if (user == "neoflex quest") {
      final bonus = max(0, (threshold - elapsedSeconds) * maxBonus ~/ threshold);
      showRelationDialog(
        context: context,
        title: "NEOFLEX QUEST",
        description:
        "Рады приветствовать вас на нашем квесте. Название квеста напрямую связано с духом компании Neoflex — постоянным стремлением к новым вызовам, обучению и увлекательным задачам!",
        onContinue: () {
          Provider.of<QuestProvider>(context, listen: false)
              .completeStage(awardedPoints: 15 + bonus);
        },
      );
    } else {
      setState(() {
        errorText = "Неверно! Подсказка: буквы сдвинуты на фиксированное значение.";
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
          "Это шифр Цезаря. Сдвиг осуществляется на 3 символа.",
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
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Этап 1: Шифр Цезаря", style: AppTextStyles.subtitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: 0.2,
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
              "Это шифр Цезаря!\nРасшифруйте сообщение:",
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF821363),
                    Color(0xFFD2005A),
                    Color(0xFFE63B31),
                    Color(0xFFFF9F18),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                margin: const EdgeInsets.all(2),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    encryptedMessage,
                    style: AppTextStyles.headline,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF821363),
                    Color(0xFFD2005A),
                    Color(0xFFE63B31),
                    Color(0xFFFF9F18),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                margin: const EdgeInsets.all(2), // толщина рамки 2px
                decoration: BoxDecoration(
                  color: AppColors.dark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: answerController,
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Ваш ответ",
                    labelStyle: AppTextStyles.body.copyWith(color: Colors.white70),
                    errorText: errorText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => _checkAnswer(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color.fromRGBO(130, 19, 99, 0.6),
                          Color.fromRGBO(210, 0, 90, 0.6),
                          Color.fromRGBO(230, 59, 49, 0.6),
                          Color.fromRGBO(255, 159, 24, 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: 56,
                      child: Text(
                        "Проверить",
                        style: AppTextStyles.body.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
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
                          decoration: TextDecoration.underline
                      )),
                ),
                TextButton(
                  onPressed: _showHintDialog,
                  child: Text("Подсказка",
                      style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.cyan,
                          decoration: TextDecoration.underline
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
