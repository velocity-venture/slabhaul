import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/calculator/widgets/line_angle_diagram.dart';
import 'package:slabhaul/features/calculator/widgets/depth_result_display.dart';
import 'package:slabhaul/features/calculator/widgets/depth_sliders.dart';
import 'package:slabhaul/features/calculator/widgets/preset_chips.dart';
import 'package:slabhaul/features/calculator/providers/calculator_providers.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset('assets/images/slabhaul_icon.png'),
        ),
        title: const Text(
          'Depth Calculator',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            tooltip: 'Reset',
            onPressed: () {
              ref.read(calculatorInputProvider.notifier).reset();
            },
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated line angle diagram.
            LineAngleDiagram(),
            SizedBox(height: 16),

            // Prominent depth result card.
            DepthResultDisplay(),
            SizedBox(height: 20),

            // Input sliders.
            DepthSliders(),
            SizedBox(height: 20),

            // Quick preset chips.
            PresetChips(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
