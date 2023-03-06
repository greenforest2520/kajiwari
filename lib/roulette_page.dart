import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roulette/roulette.dart';
import 'arrow.dart';
import 'model/houseWork.dart';

class RoulettPage extends StatefulWidget {
  const RoulettPage({Key? key}) : super(key: key);

  @override
  State<RoulettPage> createState() => _RoulettPageState();
}

class _RoulettPageState extends State<RoulettPage>
    with SingleTickerProviderStateMixin {
  static final _random = Random();

  late RouletteController _controller;
  bool _clockwise = true;

  int index = 1;
  String? kaji;
  final colors = <Color>[
    Colors.red.withAlpha(50),
    Colors.green.withAlpha(30),
    Colors.blue.withAlpha(70),
    Colors.yellow.withAlpha(90),
    Colors.amber.withAlpha(50),
    Colors.indigo.withAlpha(70),
  ];

  @override
  void initState() {
    final group = RouletteGroup.uniform(
      colors.length,
      colorBuilder: colors.elementAt,
    );
    _controller = RouletteController(vsync: this, group: group);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HouseWorkModel>(
        create: (_) => HouseWorkModel()..fetchHousework(),
        child: Consumer<HouseWorkModel>(builder: (context, model, child) {
          List<HouseWork>? housework = model.housework;
          print("ハウスワーク:$housework");

          if (model.housework == null) {
            return const Padding(
              padding: EdgeInsets.all(50),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "家事選択",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CupertinoButton.filled(
                    child: Text("${model.kajiName}"),
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (_) => SizedBox(
                          height: 250,
                          width: double.infinity,
                          child: CupertinoPicker(
                            backgroundColor: Colors.white,
                            itemExtent: model.housework!.length.toDouble(),
                            scrollController:
                                FixedExtentScrollController(initialItem: 1),
                            children: housework!
                                .map((kaji) => Text(kaji.kajiName))
                                .toList(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                this.index = index;
                                final selectKaji = housework[index];
                                print("kajiindex$selectKaji");
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  MyRoulette(controller: _controller),
                  const SizedBox(
                    height: 45,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        var result = _controller.rollTo(
                          1,
                          clockwise: _clockwise,
                          offset: Random().nextDouble(),

                          //結果出力
                        );
                      },
                      child: const Text("開始")),
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    height: 250,
                    width: 250,
                    child: TextField(
                      controller: model.kajiController,
                      decoration: const InputDecoration(
                          labelText: "新しい家事を登録", hintText: "家事名…"),
                      onChanged: (text) {
                        model.setKaji(text);
                        kaji = text;
                      },
                      onTap: () {
                        model.registerKaji();
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        }));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class MyRoulette extends StatelessWidget {
  const MyRoulette({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final RouletteController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Roulette(
              // Provide controller to update its state
              controller: controller,
              // Configure roulette's appearance
              style: const RouletteStyle(
                dividerThickness: 4,
                textLayoutBias: .8,
                centerStickerColor: Color(0xFF45A3FA),
              ),
            ),
          ),
        ),
        const Arrow(),
      ],
    );
  }
}
