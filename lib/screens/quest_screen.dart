import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quest_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

import 'stage1_screen.dart';
import 'stage2_screen.dart';
import 'stage3_screen.dart';
import 'stage4_screen.dart';
import 'stage5_screen.dart';
import 'home_screen.dart';

class QuestScreenFull extends StatelessWidget {
  const QuestScreenFull({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestProvider>(
      builder: (context, questProvider, child) {
        switch (questProvider.currentStage) {
          case 1:
            return const Stage1Screen();
          case 2:
            return const Stage2Screen();
          case 3:
            return const Stage3Screen();
          case 4:
            return const Stage4Screen();
          case 5:
            return const Stage5Screen();
          default:
          // После 5-го этапа currentStage станет 6 и попадем сюда
            return Scaffold(
              backgroundColor: AppColors.dark,
              appBar: AppBar(
                backgroundColor: AppColors.violet,
                title: Text(
                  "Квест завершен!",
                  style: AppTextStyles.subtitle,
                ),
                centerTitle: true,
              ),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Поздравляем! Вы набрали ${questProvider.points} очков.",
                      style: AppTextStyles.body.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HomeScreen()),
                              (route) => false,
                        );
                      },
                      child: Text(
                        "На главный экран",
                        style: AppTextStyles.body.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
        }
      },
    );
  }
}
