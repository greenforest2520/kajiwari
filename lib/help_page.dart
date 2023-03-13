import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:profiele_web/roulette_page.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "使い方",
              style: TextStyle(
                fontSize: 35,
              ),
            ),
            SizedBox(
              height: 35,
            ),
            Text("家事分担をルーレットで決める「kajiwari」"),
            Text("家事をする人をルーレットで決めます"),
            // Text("家事をルーレットで決めずに率先して登録した場合"),
            // Text("そのアカウントに「率先チケット」が与えられます"),
            // Text("そのチケットが3枚溜まるとひとつの家事をスキップできます!")
          ],
        ),
      ),
    );
  }
}
