import 'package:flutter/material.dart';
import 'package:libras/core/app_colors.dart';

class ProgressIndicatorWidget extends StatelessWidget {

  final double value;
  ProgressIndicatorWidget({ this.value });

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      backgroundColor: AppColors.chartSecondary,
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.chartPrimary),
    );
  }
}
