// ignore_for_file: use_build_context_synchronously

import 'dart:math';

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
        create: (_) =>
            HouseWorkModel()..fetchRouletteUserindex(widget.selectkaji),
        child: Consumer<HouseWorkModel>(builder: (context, model, child) {
          final group = RouletteGroup(model.rouletteList);
          final lettecontroller = RouletteController(vsync: this, group: group);

          return Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Roulette(
                        controller: lettecontroller,
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
              ),
              const SizedBox(
                height: 35,
              ),
              ElevatedButton(
                  onPressed: () async {
                    var result = RandomUnion(group.units.length);
                    print(
                        "押下後,グループユニット${group.units}:トータルウェイト${group.totalWeights}:結果の数${result.randomValueInt}:結果の数の少数${result.randomValueUnderPoint}");

                    await lettecontroller
                        .rollTo(
                          result.randomValueInt,
                          clockwise: true,
                          offset: result.randomValueUnderPoint,
                        )
                        .then((_) => {
                              // ルーレットが止まった時の処理
                              debugPrint(result.randomValue.toString())
                              //showdailogで決まった人を表示。その後OKボタンでfirestoreのhistoryに保存。
                            });
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) {
                        return AlertDialog(
                          title: const Text("登録完了"),
                          content: const Text("家事分担の登録できました"),
                          actions: [
                            TextButton(
                                child: const Text("OK"),
                                onPressed: () {
                                  model.registerPIC(
                                      result.randomValueInt, widget.selectkaji);
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                }),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text("開始")),
            ],
          );
        }));
  }
}

class RandomUnion {
  // ランダムな数値 例：最大値＝6 の場合 0.0 <= randomValue < 6.0
  double randomValue = 0.0;

  // ランダムな数値の整数部のみ
  int randomValueInt = 0;
  // ランダムな数値の小数点以下
  double randomValueUnderPoint = 0.0;

  /// コンストラクター
  /// 最大値を渡す。例：最大値＝6 の場合 0.0 <= randomValue < 6.0
  RandomUnion(int lessThanValue) {
    randomValue = lessThanValue * Random().nextDouble();
    randomValueInt = randomValue.toInt();
    randomValueUnderPoint = randomValue - randomValueInt;
  }
}
