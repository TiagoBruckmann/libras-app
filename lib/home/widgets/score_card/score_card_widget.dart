import 'package:flutter/material.dart';
import 'package:libras/core/app_colors.dart';
import 'package:libras/core/app_text_styles.dart';
import 'package:libras/home/widgets/chart/chart_widget.dart';

class ScoreCardWidget extends StatelessWidget {

  final double nextLevel;
  ScoreCardWidget({ this.nextLevel });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only( left: 20, right: 20 ),
      child: Container(
        height: 136,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 1,
                  child: ChartWidget(
                    nextLevel: nextLevel,
                  ),
              ),

              Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only( left: 24 ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vamos Começar",
                          style: AppTextStyles.heading,
                        ),
                        Text(
                          "Complete os desafios e avance em conhecimento",
                          style: AppTextStyles.body,
                        )
                      ],
                    ),
                  )
              ),
            ],
          ),
        )
      ),
    );
  }
}
