import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quest_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/relation_dialogs.dart';

class MemoryCard {
  final String id;
  final String letter;
  final String imageAsset;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.imageAsset,
    this.isFlipped = false,
    this.isMatched = false,
  }) : letter = id[0].toLowerCase();
}

class Stage5Screen extends StatefulWidget {
  const Stage5Screen({Key? key}) : super(key: key);

  @override
  _Stage5ScreenState createState() => _Stage5ScreenState();
}

class _Stage5ScreenState extends State<Stage5Screen> {
  late Stopwatch stopwatch;
  Timer? timer;
  int elapsedSeconds = 0;
  static const int threshold = 180;
  static const int maxBonus = 20;

  final List<String> letters = ["P", "R", "O", "G", "R", "E", "S", "S"];
  final Map<String, String> letterToAsset = {
    "P": "assets/stage5_images/comp.jpg",
    "R1": "assets/stage5_images/flash.jpg",
    "R2": "assets/stage5_images/gamepad.jpg",
    "O": "assets/stage5_images/home_audio_speakers.jpg",
    "G": "assets/stage5_images/keyboard.jpg",
    "E": "assets/stage5_images/monitor.jpg",
    "S1": "assets/stage5_images/mouse.jpg",
    "S2": "assets/stage5_images/printer.jpg",
  };
  late List<MemoryCard> memoryCards;
  List<MemoryCard> flippedCards = [];
  bool memoryGameCompleted = false;

  List<String> letterPool = [];
  List<String> assemblyLetters = [];
  final String targetWord = "progress";

  late String secretCode;
  final TextEditingController codeController = TextEditingController();
  String? errorText;

  final Gradient _borderGradientVertical = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF821363),
      Color(0xFFD2005A),
      Color(0xFFE63B31),
      Color(0xFFFF9F18),
    ],
    stops: [0, 0.33, 0.66, 1],
  );
  final Gradient _borderGradientHorizontal = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF821363),
      Color(0xFFD2005A),
      Color(0xFFE63B31),
      Color(0xFFFF9F18),
    ],
    stops: [0, 0.33, 0.66, 1],
  );
  final Gradient _buttonGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.fromRGBO(130, 19, 99, 0.6),
      Color.fromRGBO(210, 0, 90, 0.6),
      Color.fromRGBO(230, 59, 49, 0.6),
      Color.fromRGBO(255, 159, 24, 0.6),
    ],
    stops: [0, 0.33, 0.66, 1],
  );

  @override
  void initState() {
    super.initState();
    _initMemoryCards();
    memoryCards.shuffle(Random());
    secretCode = List.generate(4, (_) => Random().nextInt(10).toString()).join();
    stopwatch = Stopwatch()..start();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        elapsedSeconds = stopwatch.elapsed.inSeconds;
      });
    });
  }

  void _initMemoryCards() {
    memoryCards = [];
    letterPool = [];
    final occ = <String, int>{};
    for (var l in letters) {
      occ[l] = (occ[l] ?? 0) + 1;
      final key = (l == "R" || l == "S") ? "$l${occ[l]}" : l;
      memoryCards.addAll([
        MemoryCard(id: key, imageAsset: letterToAsset[key]!),
        MemoryCard(id: key, imageAsset: letterToAsset[key]!),
      ]);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    stopwatch.stop();
    codeController.dispose();
    super.dispose();
  }

  void _onCardTapped(int idx) {
    final card = memoryCards[idx];
    if (card.isFlipped || card.isMatched || flippedCards.length == 2) return;
    setState(() {
      card.isFlipped = true;
      flippedCards.add(card);
    });
    if (flippedCards.length == 2) {
      if (flippedCards[0].id == flippedCards[1].id) {
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            flippedCards[0].isMatched = true;
            flippedCards[1].isMatched = true;
            letterPool.add(flippedCards[0].letter);
            flippedCards.clear();
            if (memoryCards.every((c) => c.isMatched)) {
              memoryGameCompleted = true;
            }
          });
        });
      } else {
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            flippedCards[0].isFlipped = false;
            flippedCards[1].isFlipped = false;
            flippedCards.clear();
          });
        });
      }
    }
  }

  void _revealSecretCode() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.dark,
        title: Text("Часть кода", style: AppTextStyles.subtitle),
        content: Text("Сгенерированный 4-значный код: $secretCode",
            style: AppTextStyles.body.copyWith(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Закрыть",
                style: AppTextStyles.body.copyWith(color: AppColors.cyan)),
          )
        ],
      ),
    );
  }

  void _showHintDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.dark,
        title: Text("Подсказка", style: AppTextStyles.subtitle),
        content: Text(
          "Двойной тап по логотипу, чтобы увидеть 4-значный код.",
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Закрыть",
                style: AppTextStyles.body.copyWith(color: AppColors.cyan)),
          )
        ],
      ),
    );
  }

  void _onSubmit() {
    final assembled = assemblyLetters.join().toLowerCase();
    final entered = codeController.text.trim().toLowerCase();
    final expected = "$targetWord$secretCode";
    if (assembled == targetWord && entered == expected) {
      final bonus = max(0, (threshold - elapsedSeconds) * maxBonus ~/ threshold);
      showRelationDialog(
        context: context,
        title: "Квест пройден!",
        description:
        "Вы успешно собрали слово \"$targetWord\" и ввели правильный код \"$secretCode\".\nБонус за скорость: $bonus.",
        onContinue: () {
          Provider.of<QuestProvider>(context, listen: false)
              .completeStage(awardedPoints: 10 + bonus);
        },
      );
    } else {
      setState(() => errorText = "Неверный код-пароль, проверьте обе части.");
    }
  }

  void _skipLevel() {
    Provider.of<QuestProvider>(context, listen: false)
        .completeStage(awardedPoints: 0);
  }

  void _resetAssemblyZone() {
    setState(() {
      letterPool.addAll(assemblyLetters);
      assemblyLetters.clear();
    });
  }

  Widget _letterTile(String l) => Container(
    width: 48,
    height: 48,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFF962F29),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      l.toUpperCase(),
      style: AppTextStyles.headline.copyWith(color: Colors.white),
    ),
  );

  Widget _buildAssemblyZone() {
    return Container(
      height: 68, // было 65
      decoration: BoxDecoration(
        gradient: _borderGradientVertical,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.dark.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: List.generate(targetWord.length, (i) {
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (i < assemblyLetters.length)
                    _letterTile(assemblyLetters[i])
                  else
                    const SizedBox(height: 38),
                  const SizedBox(height: 6),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Container(
                      height: 4,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double hintFontSize =
        (AppTextStyles.subtitle.fontSize ?? 16) - 2;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.violet,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Этап 5: Код-пароль", style: AppTextStyles.subtitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: 1.0,
              backgroundColor: AppColors.grey,
              valueColor: AlwaysStoppedAnimation(AppColors.cyan),
            ),
            const SizedBox(height: 8),
            Text("Время: ${elapsedSeconds}s",
                style: AppTextStyles.body.copyWith(color: AppColors.cyan)),
            const SizedBox(height: 20),

            if (!memoryGameCompleted) ...[
              Text("1) Найдите все пары", style: AppTextStyles.subtitle),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: memoryCards.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _onCardTapped(i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cyan, width: 2),
                    ),
                    child: Center(
                      child: memoryCards[i].isFlipped ||
                          memoryCards[i].isMatched
                          ? Image.asset(
                        memoryCards[i].imageAsset,
                        fit: BoxFit.cover,
                      )
                          : Container(color: AppColors.violet),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _skipLevel,
                child: Text("Пропустить уровень",
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.cyan,
                      decoration: TextDecoration.underline,
                    )),
              ),
            ] else ...[
              Text("Найдите 4 цифры для пароля",
                  style: AppTextStyles.subtitle),
              const SizedBox(height: 12),

              GestureDetector(
                onDoubleTap: _revealSecretCode,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _borderGradientVertical,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset(
                      "assets/logo.jpg",
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Text("Составьте слово", style: AppTextStyles.subtitle),
              const SizedBox(height: 10),

              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.75,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 1,
                    ),
                    itemCount: letterPool.length,
                    itemBuilder: (_, i) {
                      final l = letterPool[i];
                      return GestureDetector(
                        onTap: () {
                          if (assemblyLetters.length <
                              targetWord.length) {
                            setState(() {
                              assemblyLetters.add(l);
                              letterPool.removeAt(i);
                            });
                          }
                        },
                        child: _letterTile(l),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),
              _buildAssemblyZone(),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _resetAssemblyZone,
                child: Text("Очистить поле",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.cyan,
                      decoration: TextDecoration.underline,
                    )),
              ),

              const SizedBox(height: 20),
              Text(
                "Теперь введите единый код-пароль (сначала слово, потом цифры, без разделителей):",
                style: AppTextStyles.subtitle
                    .copyWith(fontSize: hintFontSize),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: 300,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _borderGradientHorizontal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.dark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: codeController,
                      style: AppTextStyles.body
                          .copyWith(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        labelText: "Код-пароль",
                        labelStyle: AppTextStyles.body
                            .copyWith(color: Colors.white54),
                        errorText: errorText,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: _onSubmit,
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: _buttonGradient,
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: Text("Готово",
                      style: AppTextStyles.body
                          .copyWith(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _showHintDialog,
                child: Text("Подсказка",
                    style: AppTextStyles.subtitle
                        .copyWith(color: AppColors.cyan)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
