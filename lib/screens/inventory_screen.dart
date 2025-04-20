// lib/screens/inventory_screen.dart

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

  ShopItem({
    required this.id,
    required this.title,
    required this.assetPath,
    required this.price,
  });
}

// Список всех товаров (дублируем из ShopScreen)
final List<ShopItem> _allItems = [
  ShopItem(
    id: 'speaker1',
    title: 'Колонка (дороже)',
    assetPath: 'assets/shop/speaker1.jpg',
    price: 120,
  ),
  ShopItem(
    id: 'powerbank',
    title: 'Повербанк',
    assetPath: 'assets/shop/powerbank.jpg',
    price: 110,
  ),
  ShopItem(
    id: 'speaker2',
    title: 'Колонка (дешевле)',
    assetPath: 'assets/shop/speaker2.jpg',
    price: 100,
  ),
  ShopItem(
    id: 'thermo',
    title: 'Термокружка',
    assetPath: 'assets/shop/thermo.jpg',
    price: 85,
  ),
  ShopItem(
    id: 'bottle',
    title: 'Бутылка спортивная',
    assetPath: 'assets/shop/bottle.jpg',
    price: 80,
  ),
  ShopItem(
    id: 'notebook1',
    title: 'Блокнот (1 расцветка)',
    assetPath: 'assets/shop/notebook1.jpg',
    price: 60,
  ),
  ShopItem(
    id: 'notebook2',
    title: 'Блокнот (2 расцветка)',
    assetPath: 'assets/shop/notebook2.jpg',
    price: 60,
  ),
  ShopItem(
    id: 'plush',
    title: 'Плюшевая игрушка антистресс',
    assetPath: 'assets/shop/plush.jpg',
    price: 45,
  ),
  ShopItem(
    id: 'stickers',
    title: 'Стикеры',
    assetPath: 'assets/shop/stickers.jpg',
    price: 40,
  ),
];

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _db = FirebaseDatabase.instance;
  late DatabaseReference _userRef;
  Set<String> _purchased = {};

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _userRef = _db.ref('users/$uid/purchases');
    _userRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      setState(() {
        _purchased = data.keys.map((k) => k.toString()).toSet();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ownedItems = _allItems.where((item) => _purchased.contains(item.id)).toList();
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.violet,
        title: Text('Мои покупки', style: AppTextStyles.subtitle),
        centerTitle: true,
      ),
      body: ownedItems.isEmpty
          ? Center(
        child: Text('Вы ещё ничего не купили',
            style: AppTextStyles.body.copyWith(color: Colors.white70)),
      )
          : ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: ownedItems.length,
        separatorBuilder: (_, __) => Divider(color: AppColors.grey),
        itemBuilder: (ctx, i) {
          final item = ownedItems[i];
          return ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Image.asset(item.assetPath, width: 60, height: 60),
            title: Text(item.title,
                style: AppTextStyles.body.copyWith(color: Colors.white)),
            subtitle: Text('${item.price} баллов',
                style: AppTextStyles.body.copyWith(color: Colors.white70)),
          );
        },
      ),
    );
  }
}
