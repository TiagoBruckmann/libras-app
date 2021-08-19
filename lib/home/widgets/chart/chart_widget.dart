import 'package:flutter/material.dart';
import 'package:libras/core/app_colors.dart';
import 'package:libras/core/app_text_styles.dart';

class ChartWidget extends StatelessWidget {

  final double nextLevel;

  ChartWidget({ this.nextLevel });

  @override
  Widget build(BuildContext context) {

    String convertNextLevel = nextLevel.toString()[0];
    double newNextLevel = double.parse(".$convertNextLevel");

    return Container(
      height: 80,
      width: 80,
      child: Stack(
        children: [
          Center(
            child: Container(
              height: 80,
              width: 80,
              child: CircularProgressIndicator(
                strokeWidth: 10,
                value: newNextLevel,
                 backgroundColor: AppColors.chartSecondary,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.chartPrimary,
                ),
              ),
            ),
          ),

          Center(
            child: Text(
              "$nextLevel%",
              style: AppTextStyles.heading,
            ),
          ),
        ],
      ),
    );
  }
}
