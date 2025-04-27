
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'shop_screen.dart';

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

final List<ShopItem> _allItems = [
  ShopItem(
    id: 'speaker1',
    title: 'Колонка',
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
    title: 'Портативная мини-колонка',
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
    title: 'Блокнот 1 (логотип + маскот)',
    assetPath: 'assets/shop/notebook1.jpg',
    price: 60,
  ),
  ShopItem(
    id: 'notebook2',
    title: 'Блокнот 2 (логотип)',
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
    title: 'Самоклеящиеся закладки-стикеры',
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
    final ownedItems =
    _allItems.where((item) => _purchased.contains(item.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.violet,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Мои покупки', style: AppTextStyles.subtitle),
        centerTitle: true,
      ),
      body: ownedItems.isEmpty
          ? Center(
        child: Text(
          'Вы ещё ничего не купили',
          style: AppTextStyles.body.copyWith(color: Colors.white70),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: ownedItems.length,
        separatorBuilder: (_, __) => Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF821363),
                Color(0xFFD2005A),
                Color(0xFFE63B31),
                Color(0xFFFF9F18),
              ],
              stops: [0.0, 0.33, 0.66, 1.0],
            ),
          ),
        ),
        itemBuilder: (ctx, i) {
          final item = ownedItems[i];
          return Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    item.assetPath,
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTextStyles.body
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.price} баллов',
                        style: AppTextStyles.body
                            .copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ShopScreen()),
                ),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 200,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Магазин',
                    style: AppTextStyles.body.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
