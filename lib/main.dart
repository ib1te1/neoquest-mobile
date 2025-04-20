
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/quest_provider.dart'; // <-- Импортируем QuestProvider
import 'screens/splash_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/inventory_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuestProvider()), // <-- Добавляем QuestProvider
      ],
      child: NeoflexQuestApp(),
    ),
  );
}

class NeoflexQuestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neoflex Quest',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      routes: {
        '/shop': (context) => ShopScreen(),
        '/inventory': (context) => InventoryScreen(),// добавили маршрут магазина
      },
    );
  }
}
