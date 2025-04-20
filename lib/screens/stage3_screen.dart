import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quest_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/relation_dialogs.dart';

class DragItem {
  final String id;
  final String assetPath;
  DragItem({required this.id, required this.assetPath});
}

class Stage3Screen extends StatefulWidget {
  const Stage3Screen({Key? key}) : super(key: key);

  @override
  _Stage3ScreenState createState() => _Stage3ScreenState();
}

class _Stage3ScreenState extends State<Stage3Screen> {
  late Stopwatch stopwatch;
  Timer? timer;
  int elapsedSeconds = 0;

  static const int threshold = 80;
  static const int maxBonus = 20;

  final List<DragItem> availableItems = [
    DragItem(id: "20", assetPath: "assets/stage3_images/image_20.jpg"),
    DragItem(id: "05", assetPath: "assets/stage3_images/image_05.jpg"),
    DragItem(id: "distractor1", assetPath: "assets/stage3_images/distractor1.jpg"),
    DragItem(id: "distractor2", assetPath: "assets/stage3_images/distractor2.jpg"),
    DragItem(id: "distractor3", assetPath: "assets/stage3_images/distractor3.jpg"),
  ];
  List<DragItem?> selectedItems = [null, null];
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
    super.dispose();
  }

  void _checkAnswer(BuildContext context) {
    if (selectedItems[0]?.id == "20" && selectedItems[1]?.id == "05") {
      final bonus = max(0, (threshold - elapsedSeconds) * maxBonus ~/ threshold);
      showRelationDialog(
        context: context,
        title: "2005",
        description:
        "Именно в 2005 году была основана компания Neoflex. С тех пор мы уверенно растём, развиваемся и создаём крутые IT‑продукты!",
        onContinue: () {
          Provider.of<QuestProvider>(context, listen: false)
              .completeStage(awardedPoints: 20 + bonus);
        },
      );
    } else {
      setState(() {
        errorText = "Неверный порядок. Перетащите изображения в нужном порядке.";
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
          "Верные картинки как-то связаны с компанией, посмотрите внимательно.",
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
        title: Text("Этап 3: Визуальная головоломка", style: AppTextStyles.subtitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: 0.6,
              backgroundColor: AppColors.grey,
              valueColor: AlwaysStoppedAnimation(AppColors.cyan),
            ),
            const SizedBox(height: 8),
            Text(
              "Время: ${elapsedSeconds}s",
              style: AppTextStyles.body.copyWith(color: AppColors.cyan),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              "Соберите число — год основания компании Neoflex,\nперетаскивая картинки в правильном порядке.",
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTargetSlot(0),
                _buildTargetSlot(1),
              ],
            ),
            if (errorText != null) ...[
              const SizedBox(height: 12),
              Text(errorText!,
                  style: AppTextStyles.body.copyWith(color: AppColors.orange)),
            ],
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: availableItems
                  .where((item) => !selectedItems.contains(item))
                  .map(_buildDraggableItem)
                  .toList(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: (selectedItems[0] != null && selectedItems[1] != null)
                  ? () => _checkAnswer(context)
                  : null,
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

  Widget _buildTargetSlot(int index) {
    return DragTarget<DragItem>(
      onWillAccept: (data) => true,
      onAccept: (data) {
        setState(() {
          selectedItems[index] = data;
          errorText = null;
        });
      },
      builder: (context, candidateData, rejectedData) {
        Widget content;
        if (selectedItems[index] != null) {
          content = GestureDetector(
            onTap: () {
              setState(() {
                selectedItems[index] = null;
                errorText = null;
              });
            },
            child: Image.asset(
              selectedItems[index]!.assetPath,
              fit: BoxFit.contain,
            ),
          );
        } else {
          content = Center(
            child: Text("Slot ${index + 1}",
                style: AppTextStyles.body.copyWith(color: Colors.white70)),
          );
        }

        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty
                ? AppColors.purple.withOpacity(0.4)
                : AppColors.purple.withOpacity(0.2),
            border:
            Border.all(color: AppColors.purple.withOpacity(0.5), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: content,
        );
      },
    );
  }

  Widget _buildDraggableItem(DragItem item) {
    return Draggable<DragItem>(
      data: item,
      feedback: Opacity(
        opacity: 0.8,
        child: _buildItemImage(item),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildItemImage(item),
      ),
      child: _buildItemImage(item),
    );
  }

  Widget _buildItemImage(DragItem item) {
    return Container(
      width: 100,
      height: 100,
      decoration:
      BoxDecoration(border: Border.all(color: AppColors.grey, width: 2), borderRadius: BorderRadius.circular(8)),
      child: Image.asset(item.assetPath, fit: BoxFit.cover),
    );
  }
}
