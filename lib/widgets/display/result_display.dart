import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dice_controller.dart';
import '../../models/roll_result.dart';
import 'shake_widget.dart';

class ResultDisplay extends StatelessWidget {
  const ResultDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DiceController>();
    final result = state.lastResult;
    final isRolling = state.isRolling;
    final shakeIntensity = state.shakeIntensity;

    if (isRolling) {
      // Show different text based on intensity
      String statusText = "Rolling...";
      if (shakeIntensity > 1.5) statusText = "ROLLING HARD!";
      if (shakeIntensity > 2.5) statusText = "EXPLODING!!!";

      return ShakeWidget(
        isShaking: true,
        intensity: shakeIntensity, // DYNAMIC INTENSITY
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.casino_outlined, size: 80, color: Colors.white24),
              SizedBox(height: 16),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (result == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app,
              size: 64,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 16),
            Text(
              "Tap Roll to Start",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.white24),
            ),
          ],
        ),
      );
    }

    final rawSum = result.individualRolls.reduce((a, b) => a + b);
    final minPossible = result.individualRolls.length;
    final maxPossible = result.individualRolls.length * result.dieSides;

    // Adjusted luck percentage for Exploding Dice
    final percentage = (maxPossible == minPossible)
        ? 1.0
        : (rawSum - minPossible) / (maxPossible - minPossible);

    final (textColor, shadows) = _calculateRollStyle(
      percentage,
      result.explosionCount,
    );

    return ShakeWidget(
      isShaking: false,
      // ADDED: Center + SingleChildScrollView to handle overflow while keeping small rolls centered
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ), // Add padding for scroll spacing
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Shrink to fit content
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: result.total.toDouble()),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutQuart,
                builder: (context, value, child) {
                  return Text(
                    "${value.toInt()}",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      fontSize: 100,
                      shadows: shadows,
                    ),
                  );
                },
              ),

              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Explosion Indicator
              if (result.explosionCount > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.orange, width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${result.explosionCount} Explosion${result.explosionCount > 1 ? 's' : ''}",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ...result.individualRolls.map((roll) {
                    // Logic: If roll > sides, it definitely exploded
                    final exploded = roll > result.dieSides;
                    final isDieCrit = roll >= result.dieSides; // Crit if >= max
                    final isDieFail = roll == 1;

                    Color dieColor = const Color(0xFF334155);
                    Color dieText = Colors.white;
                    BoxBorder? border;

                    if (exploded) {
                      dieColor = Colors.orange.shade900; // Exploded color
                      dieText = Colors.white;
                      border = Border.all(color: Colors.orangeAccent, width: 1);
                    } else if (isDieCrit) {
                      dieColor = const Color(0xFFCA8A04);
                      dieText = Colors.black;
                    } else if (isDieFail) {
                      dieColor = const Color(0xFF7F1D1D);
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: dieColor,
                        borderRadius: BorderRadius.circular(8),
                        border: border,
                      ),
                      child: Text(
                        "$roll",
                        style: TextStyle(
                          color: dieText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),

                  if (result.modifier != 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        result.modifier > 0
                            ? "+${result.modifier}"
                            : "${result.modifier}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),

                  if (result.mode != RollMode.normal)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: result.mode == RollMode.advantage
                            ? const Color(0xFF064E3B)
                            : const Color(0xFF881337),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: result.mode == RollMode.advantage
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            result.mode == RollMode.advantage
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            result.mode == RollMode.advantage ? "ADV" : "DIS",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              if (result.discardedRolls != null) ...[
                const SizedBox(height: 16),
                Text(
                  "Discarded: [${result.discardedRolls!.join(', ')}] + ${result.modifier} = ${result.discardedRolls!.reduce((a, b) => a + b) + result.modifier}",
                  style: const TextStyle(
                    color: Colors.white24,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  (Color, List<Shadow>) _calculateRollStyle(
    double percentage,
    int explosionCount,
  ) {
    // If it exploded, it's automatically AMAZING
    if (explosionCount > 0) {
      return (
        const Color(0xFFFF6D00), // Orange-Red
        [
          const Shadow(color: Colors.orangeAccent, blurRadius: 25),
          const Shadow(color: Colors.redAccent, blurRadius: 10),
        ],
      );
    }

    if (percentage < 0.5) {
      final color = Color.lerp(
        const Color(0xFFEF4444),
        Colors.white,
        percentage * 2,
      )!;

      final shadows = percentage < 0.15
          ? [const Shadow(color: Colors.redAccent, blurRadius: 15)]
          : <Shadow>[];

      return (color, shadows);
    } else {
      final color = Color.lerp(
        Colors.white,
        const Color(0xFFFFD700),
        (percentage - 0.5) * 2,
      )!;

      final shadows = percentage > 0.85
          ? [const Shadow(color: Colors.orangeAccent, blurRadius: 20)]
          : <Shadow>[];

      return (color, shadows);
    }
  }
}
