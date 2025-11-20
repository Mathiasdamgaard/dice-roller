import 'package:dice_roller/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/dice_controller.dart';
import 'providers/character_controller.dart'; // Import new provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final diceController = DiceController();
  await diceController.loadState();

  final charController = CharacterController(); // Initialize character
  await charController.loadCharacter();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: diceController),
        ChangeNotifierProvider.value(
          value: charController,
        ), // Register provider
      ],
      child: const DiceApp(),
    ),
  );
}

class DiceApp extends StatelessWidget {
  const DiceApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        // Customizing Navigation Bar Theme to match our dark look
        navigationBarTheme: NavigationBarThemeData(
          iconTheme: WidgetStateProperty.all(
            const IconThemeData(color: Colors.white70),
          ),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const MainNavigator(), // Point to the tab wrapper
    );
  }
}
