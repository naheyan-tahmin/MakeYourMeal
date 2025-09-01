import 'package:flutter/material.dart';

class MakeYourMealLogo extends StatelessWidget {
  final double fontSize;
  final Color? color;
  final bool showIcon;

  const MakeYourMealLogo({
    super.key,
    this.fontSize = 24.0,
    this.color,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: logoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.restaurant_menu,
              color: logoColor,
              size: fontSize * 0.8,
            ),
          ),
          const SizedBox(width: 8),
        ],
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Make',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: logoColor,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                ),
              ),
              TextSpan(
                text: 'Your',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                  color: logoColor.withOpacity(0.8),
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                ),
              ),
              TextSpan(
                text: 'Meal',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: logoColor,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}