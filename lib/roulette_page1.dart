import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roulette/roulette.dart';
import 'arrow.dart';
import 'model/houseWork.dart';

class RoulettPage1 extends StatefulWidget {
  const RoulettPage1({Key? key}) : super(key: key);

  @override
  State<RoulettPage1> createState() => _RoulettPageState();
}

class _RoulettPageState extends State<RoulettPage1>
    with TickerProviderStateMixin {
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

  final usersInfo = <List>[];

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
          String? selectKaji = "洗濯";
          List<HouseWork>? housework = model.housework;
          final usersInfo = housework;
          // RouletteGroup group = RouletteGroup(model.rouletteList);
          // _controller = RouletteController(vsync: this, group: group);
          // print("ハウスワーク:$housework");
          RouletteGroup group = RouletteGroup(model.rouletteList);
          if (housework == null) {
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
                  ChangeNotifierProvider<HouseWorkModel>(
                    create: (_) => HouseWorkModel()..fetchHousework(),
                    child: Center(child: Consumer<HouseWorkModel>(
                      builder: (context, model, child) {
                        if (model.housework == null) {
                          return const CircularProgressIndicator();
                        } else {
                          final List<DropdownMenuItem<String>> lists =
                              model.housework!
                                  .map((text) => DropdownMenuItem(
                                        value: text.kajiName,
                                        child: Text(text.kajiName),
                                      ))
                                  .toList();
                          //debugPrint(model.housework.toString());

                          return DropdownButton<String>(
                              items: lists,
                              value: selectKaji,
                              onChanged: (String? value) {
                                model.selectKaji(value);
                                selectKaji = value;
                                model.fetchRouletteUser(value);
                              });
                        }
                      },
                    )),
                  ),
                  const SizedBox(
                    height: 50,
                  ),

                  MyRoulette(
                    controller: RouletteController(vsync: this, group: group),
                    selectkaji: selectKaji,
                  ),

                  const SizedBox(
                    height: 35,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        await RouletteController(group: group, vsync: this)
                            .rollTo(
                          1,
                          clockwise: true,
                          offset: Random().nextDouble(),

                          //結果出力
                        );
                      },
                      child: const Text("開始")),
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    height: 50,
                    width: 250,
                    child: TextField(
                      controller: model.kajiController,
                      decoration: const InputDecoration(
                          labelText: "新しい家事を登録", hintText: "家事名…"),
                      onChanged: (text) {
                        model.setKaji(text);
                        kaji = text;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        model.registerKaji(model.newkaji, model.groupId);
                      },
                      child: const Text("決定"))
                  //処理がうまくいけばshowdialogしてテキストを消す
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

class MyRoulette extends StatefulWidget {
  MyRoulette({
    Key? key,
    required this.controller,
    required this.selectkaji,
  }) : super(key: key);

  final RouletteController controller;
  final String? selectkaji;

  @override
  _MyRouletteState createState() => _MyRouletteState();
}

class _MyRouletteState extends State<MyRoulette> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HouseWorkModel>(
        create: (_) => HouseWorkModel()..fetchRouletteUser(widget.selectkaji),
        child: Consumer<HouseWorkModel>(builder: (context, model, child) {
          //_controller = RouletteController(vsync: this, group: group);
          final group = RouletteGroup(model.rouletteList
              //colorBuilder: model.rouletteList.elementAt(4),
              );

          return Stack(
            alignment: Alignment.topCenter,
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Roulette(
                    // Provide controller to update its state
                    controller: RouletteController(group: group, vsync: this),
                    // Configure roulette's appearance
                    style: const RouletteStyle(
                      dividerThickness: 3,
                      textLayoutBias: 0.9,
                      centerStickerColor: Color(0xFF45A3FA),
                    ),
                  ),
                ),
              ),
              const Arrow(),
            ],
          );
        }));
  }
}
