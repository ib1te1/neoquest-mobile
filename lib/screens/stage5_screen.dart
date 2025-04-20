
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
    "P": "assets/stage5_images/pear.png",
    "R1": "assets/stage5_images/raspberry.png",
    "R2": "assets/stage5_images/radish.png",
    "O": "assets/stage5_images/orange.png",
    "G": "assets/stage5_images/grapefruit.png",
    "E": "assets/stage5_images/eggplant.png",
    "S1": "assets/stage5_images/strawberry.png",
    "S2": "assets/stage5_images/sunflower.png",
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
        content: Text("Сгенерированный 4‑значный код: $secretCode",
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
          "Двойной тап по логотипу, чтобы увидеть 4‑значный код.",
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
      setState(() => errorText = "Неверный код‑пароль, проверьте обе части.");
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
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(8)),
    child: Text(l.toUpperCase(),
        style: AppTextStyles.headline.copyWith(color: Colors.white)),
  );

  Widget _buildAssemblyZone() => DragTarget<String>(
    onWillAccept: (_) => true,
    onAccept: (data) {
      setState(() {
        assemblyLetters.add(data);
        letterPool.remove(data);
      });
    },
    builder: (_, __, ___) => Container(
      height: 70,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.purple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.purple.withOpacity(0.5)),
      ),
      child: Row(
        children: assemblyLetters
            .map((l) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(6)),
          child: Text(l.toUpperCase(),
              style: AppTextStyles.headline
                  .copyWith(color: Colors.white)),
        ))
            .toList(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.violet,
        title: Text("Этап 5: Код‑пароль", style: AppTextStyles.subtitle),
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
              Text("1) Найдите все пары",
                  style: AppTextStyles.subtitle),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
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
                      child: memoryCards[i].isFlipped || memoryCards[i].isMatched
                          ? Image.asset(memoryCards[i].imageAsset,
                          fit: BoxFit.cover)
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
                        decoration: TextDecoration.underline)),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Найдите 4 цифры для пароля, они располагаются не совсем на самой картинке",
                      style: AppTextStyles.body,
                    ),
                  ),
                  TextButton(
                    onPressed: _showHintDialog,
                    child: Text("Подсказка",
                        style: AppTextStyles.subtitle
                            .copyWith(color: AppColors.cyan)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onDoubleTap: _revealSecretCode,
                child: Image.asset("assets/logo.jpg", height: 100),
              ),
              const SizedBox(height: 20),
              Text("Соберите слово",
                  style: AppTextStyles.subtitle),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: letterPool.map((l) {
                  return Draggable<String>(
                    data: l,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _letterTile(l),
                    ),
                    childWhenDragging:
                    Opacity(opacity: 0.5, child: _letterTile(l)),
                    child: _letterTile(l),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              _buildAssemblyZone(),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _resetAssemblyZone,
                  child: Text("Очистить зону сборки",
                      style: AppTextStyles.body.copyWith(
                          color: AppColors.cyan,
                          decoration: TextDecoration.underline)),
                ),
              ),
              const SizedBox(height: 20),
              Text("Теперь введите единый код‑пароль:",
                  style: AppTextStyles.subtitle),
              const SizedBox(height: 10),
              TextField(
                controller: codeController,
                style: AppTextStyles.body.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Код‑пароль",
                  hintText: "",
                  errorText: errorText,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text("Готово",
                    style:
                    AppTextStyles.body.copyWith(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _skipLevel,
                child: Text("Пропустить уровень",
                    style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.cyan,
                        decoration: TextDecoration.underline)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
