import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/dice_controller.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize controller and load data immediately
  final diceController = DiceController();
  await diceController.loadState();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: diceController),
      ],
      child: const DiceApp(),
    ),
  );
}

class DiceApp extends StatelessWidget {
  const DiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch for theme changes
    final seedColor = context.select((DiceController c) => c.seedColor);

    return MaterialApp(
      title: 'FateForged',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        splashFactory: InkSparkle.splashFactory,
      ),
      home: const DiceRollerScreen(),
    );
  }
}