import 'package:flutter/material.dart';

// Modern color scheme based on main.dart seed colors
class CineVibeColors {
  static const Color seedBlue = Color(0xFF004AAD);
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color successGreen = Color(0xFF38A169);
  static const Color warningOrange = Color(0xFFED8936);
  
  // Neutral colors
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceMedium = Color(0xFFE2E8F0);
  static const Color surfaceDark = Color(0xFF64748B);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
}

// ---------------------------
// Modern Range Slider Helper
// ---------------------------
Widget customRangeSlider({
  required BuildContext context,
  required String label,
  required double minValue,
  required double maxValue,
  required double currentMin,
  required double currentMax,
  required ValueChanged<double> onMinChanged,
  required ValueChanged<double> onMaxChanged,
  double? width,
  int? divisions,
}) {
  return _RangeSliderWidget(
    label: label,
    minValue: minValue,
    maxValue: maxValue,
    currentMin: currentMin,
    currentMax: currentMax,
    onMinChanged: onMinChanged,
    onMaxChanged: onMaxChanged,
    width: width,
    divisions: divisions,
  );
}

class _RangeSliderWidget extends StatefulWidget {
  final String label;
  final double minValue;
  final double maxValue;
  final double currentMin;
  final double currentMax;
  final ValueChanged<double> onMinChanged;
  final ValueChanged<double> onMaxChanged;
  final double? width;
  final int? divisions;

  const _RangeSliderWidget({
    required this.label,
    required this.minValue,
    required this.maxValue,
    required this.currentMin,
    required this.currentMax,
    required this.onMinChanged,
    required this.onMaxChanged,
    this.width,
    this.divisions,
  });

  @override
  State<_RangeSliderWidget> createState() => _RangeSliderWidgetState();
}

class _RangeSliderWidgetState extends State<_RangeSliderWidget> {
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    Widget rangeSlider = GestureDetector(
      onTap: () {
        setState(() {
          isFocused = !isFocused;
        });
      },
      child: Container(
        height: 50, // Match textfield height
        decoration: BoxDecoration(
          color: CineVibeColors.surfaceLight,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isFocused ? CineVibeColors.seedBlue : CineVibeColors.surfaceMedium,
            width: isFocused ? 2.5 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Slider container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: RangeSlider(
                values: RangeValues(
                  widget.currentMin.clamp(widget.minValue, widget.maxValue),
                  widget.currentMax.clamp(widget.minValue, widget.maxValue),
                ),
                min: widget.minValue,
                max: widget.maxValue,
                divisions: widget.divisions,
                onChanged: (values) {
                  widget.onMinChanged(values.start);
                  widget.onMaxChanged(values.end);
                  setState(() {
                    isFocused = true;
                  });
                },
                activeColor: CineVibeColors.seedBlue,
                inactiveColor: CineVibeColors.surfaceMedium,
              ),
            ),
            // Floating label - matching textfield style with price range
            Positioned(
              left: 130,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: CineVibeColors.surfaceLight,
                ),
                child: Text(
                  '${widget.label} • \$${widget.currentMin.toStringAsFixed(0)} - \$${widget.currentMax.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: isFocused ? CineVibeColors.seedBlue : CineVibeColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.width != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(width: widget.width, child: rangeSlider),
      );
    }

    return rangeSlider;
  }
}