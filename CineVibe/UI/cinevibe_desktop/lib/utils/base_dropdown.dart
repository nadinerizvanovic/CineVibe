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
// Modern Input Decoration Helper
// ---------------------------
InputDecoration customTextFieldDecoration(
  String label, {
  IconData? prefixIcon,
  IconData? suffixIcon,
  String? hintText,
  bool isError = false,
  bool isSuccess = false,
  VoidCallback? onSuffixIconPressed,
}) {
  Color borderColor = isError 
      ? CineVibeColors.errorRed 
      : isSuccess 
          ? CineVibeColors.successGreen 
          : CineVibeColors.surfaceMedium;
  
  Color focusedColor = isError 
      ? CineVibeColors.errorRed 
      : isSuccess 
          ? CineVibeColors.successGreen 
          : CineVibeColors.seedBlue;

  return InputDecoration(
    labelText: label,
    hintText: hintText,
    filled: true,
    fillColor: isError 
        ? CineVibeColors.errorRed.withOpacity(0.05)
        : isSuccess 
            ? CineVibeColors.successGreen.withOpacity(0.05)
            : CineVibeColors.surfaceLight,
    
    // Modern spacing and padding
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    
    // Rounded borders with subtle shadows
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(color: borderColor, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(color: borderColor, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(color: focusedColor, width: 2.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(color: CineVibeColors.errorRed, width: 2.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(color: CineVibeColors.errorRed, width: 2.5),
    ),
    
    // Modern icon styling
    prefixIcon: prefixIcon != null
        ? Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              prefixIcon,
              color: isError 
                  ? CineVibeColors.errorRed 
                  : isSuccess 
                      ? CineVibeColors.successGreen 
                      : CineVibeColors.textSecondary,
              size: 22,
            ),
          )
        : null,
    suffixIcon: suffixIcon != null
        ? onSuffixIconPressed != null
            ? Padding(
                padding: const EdgeInsets.only(right: 16, left: 12),
                child: IconButton(
                  icon: Icon(
                    suffixIcon,
                    color: isError 
                        ? CineVibeColors.errorRed 
                        : isSuccess 
                            ? CineVibeColors.successGreen 
                            : CineVibeColors.textSecondary, 
                    size: 22,
                  ),
                  onPressed: onSuffixIconPressed,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(right: 16, left: 12),
                child: Icon(
                  suffixIcon, 
                  color: isError 
                      ? CineVibeColors.errorRed 
                      : isSuccess 
                          ? CineVibeColors.successGreen 
                          : CineVibeColors.textSecondary, 
                  size: 22
                ),
              )
        : null,
    
    // Modern typography
    labelStyle: TextStyle(
      color: isError 
          ? CineVibeColors.errorRed 
          : isSuccess 
              ? CineVibeColors.successGreen 
              : CineVibeColors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
    hintStyle: TextStyle(
      color: CineVibeColors.textTertiary, 
      fontSize: 15,
      fontWeight: FontWeight.w400,
    ),
    
    // Floating label behavior
    floatingLabelStyle: TextStyle(
      color: focusedColor,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
  );
}

// ---------------------------
// Modern Custom Dropdown Helper
// ---------------------------
Widget customDropdownField<T>({
  required String label,
  required T? value,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
  IconData? prefixIcon,
  String? hintText,
  bool isError = false,
  bool isSuccess = false,
  double? width,
  String? errorText,
  String? helperText,
  bool enabled = true,
}) {
  Widget dropdown = DropdownButtonFormField<T>(
    decoration: customTextFieldDecoration(
      label,
      prefixIcon: prefixIcon,
      hintText: hintText,
      isError: isError,
      isSuccess: isSuccess,
    ).copyWith(
      errorText: errorText,
      helperText: helperText,
      helperStyle: TextStyle(
        color: CineVibeColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: TextStyle(
        color: CineVibeColors.errorRed,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
    value: value,
    items: items,
    onChanged: enabled ? onChanged : null,
    style: TextStyle(
      color: enabled ? CineVibeColors.textPrimary : CineVibeColors.textTertiary,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    dropdownColor: CineVibeColors.surfaceLight,
    icon: Icon(
      Icons.keyboard_arrow_down_rounded,
      color: isError 
          ? CineVibeColors.errorRed 
          : isSuccess 
              ? CineVibeColors.successGreen 
              : CineVibeColors.textSecondary,
      size: 24,
    ),
    isExpanded: true,
    menuMaxHeight: 300,
  );

  if (width != null) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(width: width, child: dropdown),
    );
  }

  return dropdown;
}
