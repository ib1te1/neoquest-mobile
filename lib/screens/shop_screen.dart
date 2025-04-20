// lib/screens/shop_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class ShopItem {
  final String id;
  final String title;
  final String assetPath;
  final int price;
  final String description;

  ShopItem({
    required this.id,
    required this.title,
    required this.assetPath,
    required this.price,
    required this.description,
  });
}

class ShopScreen extends StatefulWidget {
  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _db = FirebaseDatabase.instance;
  late DatabaseReference _userRef;
  int _points = 0;
  Set<String> _purchased = {};

  // Список товаров (уже отсортирован по убыванию цены)
  final List<ShopItem> _items = [
    ShopItem(
      id: 'speaker1',
      title: 'Колонка (дороже)',
      assetPath: 'assets/shop/speaker1.jpg',
      price: 120,
      description: 'Мощная колонка Neoflex с чистым звуком для ваших проектов.',
    ),
    ShopItem(
      id: 'powerbank',
      title: 'Повербанк',
      assetPath: 'assets/shop/powerbank.jpg',
      price: 110,
      description: 'Повербанк Neoflex — никогда не останетесь без энергии.',
    ),
    ShopItem(
      id: 'speaker2',
      title: 'Колонка (дешевле)',
      assetPath: 'assets/shop/speaker2.jpg',
      price: 100,
      description: 'Компактная колонка Neoflex для общения и музыки.',
    ),
    ShopItem(
      id: 'thermo',
      title: 'Термокружка',
      assetPath: 'assets/shop/thermo.jpg',
      price: 85,
      description: 'Термокружка Neoflex сохранит напиток тёплым весь день.',
    ),
    ShopItem(
      id: 'bottle',
      title: 'Бутылка спортивная',
      assetPath: 'assets/shop/bottle.jpg',
      price: 80,
      description: 'Спортивная бутылка Neoflex для активного образа жизни.',
    ),
    ShopItem(
      id: 'notebook1',
      title: 'Блокнот (1 расцветка)',
      assetPath: 'assets/shop/notebook1.jpg',
      price: 60,
      description: 'Стильный блокнот Neoflex для ваших идей.',
    ),
    ShopItem(
      id: 'notebook2',
      title: 'Блокнот (2 расцветка)',
      assetPath: 'assets/shop/notebook2.jpg',
      price: 60,
      description: 'Альтернативная расцветка блокнота Neoflex.',
    ),
    ShopItem(
      id: 'plush',
      title: 'Плюшевая игрушка антистресс',
      assetPath: 'assets/shop/plush.jpg',
      price: 45,
      description: 'Мягкая игрушка Neoflex с разноцветными шариками.',
    ),
    ShopItem(
      id: 'stickers',
      title: 'Стикеры',
      assetPath: 'assets/shop/stickers.jpg',
      price: 40,
      description: 'Набор фирменных стикеров Neoflex для ноутбука и тетрадей.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _userRef = _db.ref('users/$uid');
    // Подписываемся на изменения данных пользователя
    _userRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      setState(() {
        _points = (data['points'] as int?) ?? 0;
        final purchases = data['purchases'] as Map<dynamic, dynamic>? ?? {};
        _purchased = purchases.keys.map((k) => k.toString()).toSet();
      });
    });
  }

  void _showImageDialog(ShopItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.dark,
        title: Text(item.title, style: AppTextStyles.subtitle),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(item.assetPath, fit: BoxFit.contain),
              const SizedBox(height: 12),
              Text(item.description,
                  style: AppTextStyles.body.copyWith(color: Colors.white)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Закрыть',
                style: AppTextStyles.body.copyWith(color: AppColors.cyan)),
          )
        ],
      ),
    );
  }

  void _attemptPurchase(ShopItem item) {
    if (_purchased.contains(item.id)) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.dark,
        title: Text('Подтвердите покупку', style: AppTextStyles.subtitle),
        content: Text(
          'Купить "${item.title}" за ${item.price} баллов?',
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Отмена',
                style: AppTextStyles.body.copyWith(color: AppColors.cyan)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (_points < item.price) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Недостаточно баллов для покупки')),
                );
              } else {
                final newPoints = _points - item.price;
                _userRef.update({
                  'points': newPoints,
                  'purchases/${item.id}': true,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Вы купили "${item.title}"')),
                );
              }
            },
            child: Text('Купить',
                style: AppTextStyles.body.copyWith(color: AppColors.cyan)),
          ),
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
        title: Text('Магазин', style: AppTextStyles.subtitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.cyan.withOpacity(0.1),
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: Text(
              'Ваш баланс: $_points баллов',
              style: AppTextStyles.body.copyWith(color: Colors.black),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => Divider(color: AppColors.grey),
              itemBuilder: (ctx, i) {
                final item = _items[i];
                final bought = _purchased.contains(item.id);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: GestureDetector(
                    onTap: () => _showImageDialog(item),
                    child: Image.asset(item.assetPath, width: 60, height: 60),
                  ),
                  title: Text(item.title, style: AppTextStyles.body.copyWith(color: Colors.white)),
                  subtitle: Text('${item.price} баллов', style: AppTextStyles.body.copyWith(color: Colors.white70)),
                  trailing: bought
                      ? Text('Куплено', style: AppTextStyles.body.copyWith(color: AppColors.grey))
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _attemptPurchase(item),
                    child: Text('Купить', style: AppTextStyles.body.copyWith(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
