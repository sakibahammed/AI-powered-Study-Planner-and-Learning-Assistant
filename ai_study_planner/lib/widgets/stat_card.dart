import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final double percentage;
  final String percentageText;

  const StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.percentage,
    required this.percentageText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.primaryGradient),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: AppColors.statText, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.statText,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitle, style: TextStyle(color: AppColors.statSubText)),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 48,
                width: 48,
                child: CircularProgressIndicator(
                  value: percentage,
                  color: Colors.yellow,
                  backgroundColor: Colors.white30,
                  strokeWidth: 6,
                ),
              ),
              Text(
                percentageText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
