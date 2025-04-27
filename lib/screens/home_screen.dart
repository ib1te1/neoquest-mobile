
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/quest_provider.dart';
import 'auth_screen.dart';
import 'history_screen.dart';
import 'quest_screen.dart';
import 'inventory_screen.dart';
import 'shop_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

void showLogoutDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.dark,
      title: Text('Выход из аккаунта', style: AppTextStyles.subtitle),
      content: Text(
        'Вы уверены, что хотите выйти из аккаунта?',
        style: AppTextStyles.body.copyWith(color: Colors.white),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(
            'Отмена',
            style: AppTextStyles.body.copyWith(color: AppColors.cyan),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            onConfirm();
          },
          child: Text(
            'Выйти',
            style: AppTextStyles.body.copyWith(color: AppColors.cyan),
          ),
        ),
      ],
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? selectedIndex;

  // ╔═══════════════════ НАСТРОЙКИ РАЗМЕРОВ ═══════════════════╗
  final double baseTopOffset = 300;     // регулирует подъём/опуск списка карт
  final double spacing = 60;            // шаг между карточками
  final double popUpOffset = 200;       // подъём выбранной карточки
  final double defaultCardHeight = 300; // высота обычных карточек
  final double shopCardHeight = 370;    // высота «Магазина»
  static const int shopIndex = 3;       // индекс «Магазина»
  // ╚═══════════════════════════════════════════════════════╝

  final LinearGradient _backgroundGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF3C065D),
      Color(0xFF4D137B),
      Color(0xFF5A2189),
      Color(0xFF813FB9),
      Color(0xFFA567DF),
    ],
    stops: [0.0, 0.2933, 0.4375, 0.5769, 1.0],
  );

  final List<_MenuCardData> cards = [
    _MenuCardData(
      title: 'История компании',
      subtitle:
      'Погрузитесь в увлекательную историю развития Neoflex: узнайте, как зарождались идеи, росли проекты и формировался дух нашей команды.',
      onArrowTap: (ctx) =>
          Navigator.push(ctx, MaterialPageRoute(builder: (_) => HistoryScreen())),
    ),
    _MenuCardData(
      title: 'Запустить квест',
      subtitle:
      'Приготовьтесь к серии интригующих испытаний! Каждый этап раскроет тайны компании и проверит ваши способности.',
      onArrowTap: (ctx) =>
          Navigator.push(ctx, MaterialPageRoute(builder: (_) => QuestScreenFull())),
    ),
    _MenuCardData(
      title: 'Мои покупки',
      subtitle:
      'Коллекция наград: в этом разделе представлены все ваши призы и сувениры из квеста. Посмотрите, какие трофеи вы уже завоевали!',
      onArrowTap: (ctx) =>
          Navigator.push(ctx, MaterialPageRoute(builder: (_) => InventoryScreen())),
    ),
    _MenuCardData(
      title: 'Магазин',
      subtitle:
      'Обменивайте накопленные очки на фирменные подарки Neoflex: от блокнотов до портативных колонок. Пора открыть новую коллекцию сувениров!',
      onArrowTap: (ctx) =>
          Navigator.push(ctx, MaterialPageRoute(builder: (_) => ShopScreen())),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final questProvider = Provider.of<QuestProvider>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset(
          'assets/logo2_zero_background.png',
          height: 36,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                showLogoutDialog(
                  context: context,
                  onConfirm: () async {
                    await authProvider.logout();
                    await questProvider.resetQuest();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => AuthScreen()),
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                    stops: [0.0, 0.33, 0.66, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Выйти',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: _backgroundGradient),
        child: Stack(
          children: [
            const Positioned(
              top: kToolbarHeight + 40,
              left: 0,
              right: 0,
              child: Text(
                'Главное меню',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...List.generate(cards.length, (i) {
              final isSelected = selectedIndex == i;
              final top = kToolbarHeight +
                  MediaQuery.of(context).padding.top +
                  baseTopOffset +
                  spacing * i -
                  (selectedIndex != null && i <= selectedIndex! ? popUpOffset : 0);
              final height = i == shopIndex ? shopCardHeight : defaultCardHeight;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: 16,
                right: 16,
                top: top,
                child: GestureDetector(
                  onTap: () {
                    if (i != shopIndex) {
                      setState(() => selectedIndex =
                      selectedIndex == i ? null : i);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: height,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getGradientForIndex(i).colors.first
                          : null,
                      gradient: isSelected ? null : _getGradientForIndex(i),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cards[i].title,
                                style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                              onPressed: () => cards[i].onArrowTap(context),
                            ),
                          ],
                        ),
                        if (i == shopIndex || isSelected)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              cards[i].subtitle,
                              style: AppTextStyles.body.copyWith(color: Colors.white70),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  LinearGradient _getGradientForIndex(int i) {
    switch (i) {
      case 0:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(130, 19, 99, 1.0),
            Color.fromRGBO(130, 19, 99, 0.8),
          ],
        );
      case 1:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(210, 0, 90, 1.0),
            Color.fromRGBO(108, 0, 46, 0.8),
          ],
        );
      case 2:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(230, 59, 49, 1.0),
            Color.fromRGBO(128, 33, 27, 0.8),
          ],
        );
      case 3:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(255, 159, 24, 1.0),
            Color.fromRGBO(153, 95, 14, 0.8),
          ],
        );
      default:
        return AppColors.gradient;
    }
  }
}

class _MenuCardData {
  final String title;
  final String subtitle;
  final void Function(BuildContext) onArrowTap;

  _MenuCardData({
    required this.title,
    required this.subtitle,
    required this.onArrowTap,
  });
}
