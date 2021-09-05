// imports nativos do flutter
import 'package:flutter/material.dart';

// imports core
import 'package:libras/home/widgets/score_card/score_card_widget.dart';
import 'package:libras/core/app_text_styles.dart';
import 'package:libras/core/app_gradients.dart';

class AppBarWidget extends PreferredSize {

  final String name;
  final String photo;
  final int level;
  final double nextLevel;

  AppBarWidget({ this.name, this.photo, this.level, this.nextLevel })
  : super(
    preferredSize: Size.fromHeight(250),
    child: Container(
      height: 250,
      child: Stack(
        children: [
          Container(
            height: 161,
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric( horizontal: 20 ),
            decoration: BoxDecoration( gradient: AppGradients.linear ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                      text: "Olá, ",
                      style: AppTextStyles.title,
                      children: [
                        TextSpan(
                          text: "$name",
                          style: AppTextStyles.titleBold,
                        ),
                      ]
                  ),
                ),

                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(
                        "$photo",
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment(0.0, 1.0),
            child: ScoreCardWidget(
              level: level,
              nextLevel: nextLevel,
            ),
          ),
        ],
      )
    )
  );

}
