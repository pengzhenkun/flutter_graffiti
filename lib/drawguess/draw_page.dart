import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_draw/drawguess/draw_provider.dart';
import 'package:flutter_draw/drawguess/widget/signature_painter.dart';
import 'package:provider/provider.dart';

//绘制布局页面 （ pengzhenkun - 2020.04.30 ）
class DrawPage extends StatefulWidget {
  @override
  _DrawPageState createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  DrawProvider _provider = DrawProvider();

  @override
  void initState() {
    super.initState();
    _provider.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("WebSocket Draw"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.call_missed_outgoing),
              onPressed: () {
                //撤销一步
                _provider.undoDate();
              },
            ),
            IconButton(
              icon: Icon(Icons.call_missed),
              onPressed: () {
                //反撤销
                _provider.reverseUndoDate();
              },
            ),
          ],
        ),
        body: ChangeNotifierProvider.value(
          value: _provider,
          child: Consumer<DrawProvider>(
            builder: (context, drawProvider, _) {
              return Container(
                color: Color(0x18262B33),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.white,
                          ),
                          Text(drawProvider.points.length.toString()),
                          GestureDetector(
                            //手势探测器，一个特殊的widget，想要给一个widge添加手势，直接用这货包裹起来
                            onPanUpdate: (DragUpdateDetails details) {
                              //按下
                              RenderBox referenceBox =
                                  context.findRenderObject();
                              Offset localPosition = referenceBox
                                  .globalToLocal(details.globalPosition);
                              drawProvider.sendDraw(localPosition);
                            },
                            onPanEnd: (DragEndDetails details) {
                              drawProvider.sendDrawNull();
                            }, //抬起来
                          ),
                          CustomPaint(
                              painter:
                                  SignaturePainter(drawProvider.pointsList)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 80, bottom: 20),
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          buildInkWell(drawProvider, 5),
                          buildInkWell(drawProvider, 8),
                          buildInkWell(drawProvider, 10),
                          buildInkWell(drawProvider, 15),
                          buildInkWell(drawProvider, 17),
                          buildInkWell(drawProvider, 20),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 80, bottom: 20),
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: pintColor.keys.map((key) {
                          Color value = pintColor[key];
                          return InkWell(
                            onTap: () {
//                          setColor(context, key);
                              drawProvider.pentColor = key;
                              drawProvider.notifyListeners();
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              color: value,
                              child: drawProvider.pentColor == key
                                  ? Icon(
                                      Icons.done,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _provider.clear,
          tooltip: '',
          child: Icon(Icons.clear),
        ));
  }

  InkWell buildInkWell(DrawProvider drawProvider, double size) {
    return InkWell(
      onTap: () {
        drawProvider.pentSize = size;
        drawProvider.notifyListeners();
      },
      child: Container(
        width: 40,
        height: 40,
        child: Center(
          child: Container(
            decoration: new BoxDecoration(
              color: pintColor[drawProvider.pentColor],
              //设置四周圆角 角度
              borderRadius: BorderRadius.all(Radius.circular(size / 2)),
              //设置四周边框
              border: drawProvider.pentSize == size
                  ? Border.all(width: 1, color: Colors.black)
                  : null,
            ),
            width: size,
            height: size,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }
}
