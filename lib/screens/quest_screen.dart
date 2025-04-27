import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quest_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

import 'home_screen.dart';
import 'shop_screen.dart';
import 'stage1_screen.dart';
import 'stage2_screen.dart';
import 'stage3_screen.dart';
import 'stage4_screen.dart';
import 'stage5_screen.dart';

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
            return Scaffold(
              backgroundColor: AppColors.dark,
              appBar: AppBar(
                backgroundColor: AppColors.violet,
                centerTitle: true,
                iconTheme: const IconThemeData(color: Colors.white),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  "Квест завершен!",
                  style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                ),
              ),
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 120),
                      Text(
                        "Поздравляем!",
                        style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          text: "Вы набрали ",
                          style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                          children: [
                            TextSpan(
                              text: "${questProvider.points}",
                              style: AppTextStyles.subtitle.copyWith(
                                  color: const Color(0xFFD2005A)),
                            ),
                            const TextSpan(text: " баллов."),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 90),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          "Перейдите в раздел «Магазин»,\n"
                              "чтобы посмотреть, какие товары\n"
                              "доступны к покупке.",
                          style: AppTextStyles.body.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ShopScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 75, vertical: 14),
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
                              stops: [0, 0.33, 0.66, 1],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "Магазин",
                            style: AppTextStyles.body.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 300),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen()),
                                (route) => false,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
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
                              stops: [0, 0.33, 0.66, 1],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "Вернуться на главный экран",
                            style: AppTextStyles.body.copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}
