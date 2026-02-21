import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/constants.dart';

class WaterTempInput extends StatefulWidget {
  final double? value;
  final ValueChanged<double> onChanged;

  const WaterTempInput({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<WaterTempInput> createState() => _WaterTempInputState();
}

class _WaterTempInputState extends State<WaterTempInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value?.round().toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(WaterTempInput old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      final text = widget.value?.round().toString() ?? '';
      if (_controller.text != text) {
        _controller.text = text;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _step(int delta) {
    final current = widget.value ?? 65;
    final next = (current + delta).clamp(32.0, 95.0);
    widget.onChanged(next);
  }

  String _seasonBadge(double? temp) {
    if (temp == null) return '';
    if (temp < 50) return 'Winter';
    if (temp < 60) return 'Pre-Spawn';
    if (temp < 68) return 'Spawn';
    if (temp < 75) return 'Post-Spawn';
    return 'Summer';
  }

  Color _seasonColor(double? temp) {
    if (temp == null) return AppColors.textMuted;
    if (temp < 50) return const Color(0xFF60A5FA);
    if (temp < 60) return const Color(0xFF34D399);
    if (temp < 68) return const Color(0xFFFBBF24);
    if (temp < 75) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Water Temperature',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _stepButton(Icons.remove, () => _step(-1)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: InputDecoration(
                  suffixText: '°F',
                  hintText: '65',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.teal, width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null && parsed >= 32 && parsed <= 95) {
                    widget.onChanged(parsed);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            _stepButton(Icons.add, () => _step(1)),
          ],
        ),
        if (widget.value != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _seasonColor(widget.value).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _seasonBadge(widget.value),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _seasonColor(widget.value),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: AppColors.teal),
        ),
      ),
    );
  }
}
