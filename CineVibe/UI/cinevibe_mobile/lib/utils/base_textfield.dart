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
// Modern Custom Text Field Helper
// ---------------------------
Widget customTextField({
  required String label,
  required TextEditingController controller,
  IconData? prefixIcon,
  IconData? suffixIcon,
  String? hintText,
  bool isError = false,
  bool isSuccess = false,
  double? width,
  VoidCallback? onSubmitted,
  VoidCallback? onChanged,
  bool enabled = true,
  bool obscureText = false,
  TextInputType? keyboardType,
  int? maxLines,
  int? maxLength,
  TextInputAction? textInputAction,
  FocusNode? focusNode,
  bool autofocus = false,
  String? errorText,
  String? helperText,
  VoidCallback? onSuffixIconPressed,
}) {
  Widget textField = TextField(
    controller: controller,
    focusNode: focusNode,
    autofocus: autofocus,
    decoration: customTextFieldDecoration(
      label,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      hintText: hintText,
      isError: isError,
      isSuccess: isSuccess,
      onSuffixIconPressed: onSuffixIconPressed,
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
    onSubmitted: (_) {
      if (onSubmitted != null) {
        onSubmitted();
      }
    },
    onChanged: (_) {
      if (onChanged != null) {
        onChanged();
      }
    },
    enabled: enabled,
    obscureText: obscureText,
    keyboardType: keyboardType,
    textInputAction: textInputAction ?? (maxLines == null ? TextInputAction.done : TextInputAction.newline),
    maxLines: maxLines ?? 1,
    maxLength: maxLength,
    style: TextStyle(
      color: CineVibeColors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    cursorColor: CineVibeColors.seedBlue,
  );

  // Force width if provided, even inside Expanded/Flexible
  if (width != null) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(width: width, child: textField),
    );
  }

  return textField;
}


// ---------------------------
// Modern Button Helpers
// ---------------------------
Widget customElevatedButton({
  required String text,
  required VoidCallback? onPressed,
  Color? backgroundColor,
  Color? foregroundColor,
  double? width,
  double? height,
  bool isLoading = false,
  IconData? icon,
  bool isOutlined = false,
}) {
  final Color bgColor = backgroundColor ?? CineVibeColors.seedBlue;
  final Color fgColor = foregroundColor ?? Colors.white;
  
  Widget button = SizedBox(
    width: width,
    height: height ?? 50,
    child: isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: bgColor,
              side: BorderSide(color: bgColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _buildButtonContent(text, isLoading, icon, fgColor),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              elevation: 4,
              shadowColor: bgColor.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _buildButtonContent(text, isLoading, icon, fgColor),
          ),
  );

  return button;
}

Widget _buildButtonContent(String text, bool isLoading, IconData? icon, Color color) {
  if (isLoading) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  if (icon != null) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  return Text(
    text,
    style: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  );
}


// ---------------------------
// Modern Card Helper
// ---------------------------
Widget customCard({
  required Widget child,
  EdgeInsetsGeometry? padding,
  Color? backgroundColor,
  double? elevation,
  double borderRadius = 16.0,
  Color? borderColor,
}) {
  return Container(
    decoration: BoxDecoration(
      color: backgroundColor ?? CineVibeColors.surfaceLight,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? const Color(0xFFE2E8F0),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: CineVibeColors.textPrimary.withOpacity(0.1),
          blurRadius: elevation ?? 8,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ],
    ),
    child: Padding(
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    ),
  );
}
