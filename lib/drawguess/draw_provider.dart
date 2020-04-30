import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_draw/drawguess/draw_entity.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

//画板颜色
Map<String, Color> pintColor = {
  'default': Color(0xFFB275F5),
  'black': Colors.black,
  'brown': Colors.brown,
  'gray': Colors.grey,
  'blueGrey': Colors.blueGrey,
  'blue': Colors.blue,
  'cyan': Colors.cyan,
  'deepPurple': Colors.deepPurple,
  'orange': Colors.orange,
  'green': Colors.green,
  'indigo': Colors.indigo,
  'pink': Colors.pink,
  'teal': Colors.teal,
  'red': Colors.red,
//  'yellow': Colors.yellow,
  'purple': Colors.purple,
  'blueAccent': Colors.blueAccent,
  'white': Colors.white,
};

//数据管理 WebSocket，基础数据，通讯，连接维护等（ pengzhenkun - 2020.04.30 ）
class DrawProvider with ChangeNotifier {
  final String _URL = 'ws://10.10.3.55:8080/mini';
//  final String _URL = 'ws://localhost:8080/mini';

  List<List<DrawEntity>> undoPoints = List<List<DrawEntity>>(); // 撤销的数据
  List<List<DrawEntity>> points = List<List<DrawEntity>>(); // 存储要画的数据
  List<DrawEntity> pointsList = List<DrawEntity>(); //预处理的数据，避免绘制时处理卡顿
  String pentColor = "default"; //默认颜色
  double pentSize = 5; //默认字体大小

  //Socket 连接
  WebSocketChannel _channel;

  //开始连接
  connect() {
    _socketConnect();
  }

  _socketConnect() {
    _channel = IOWebSocketChannel.connect(_URL);
    _channel.stream.listen(
      (message) {
        //监听到的消息
        print("收到消息：$message");
        message = jsonDecode(message);
        if (message["type"] == "sendDraw") {
          //正在连续绘制
          if (points.length == 0) {
            points.add(List<DrawEntity>());
            points.add(List<DrawEntity>());
          }
          pentColor = message["pentColor"];
          pentSize = message["pentSize"];
          //添加绘制
          //添加绘制
          points[points.length - 2].add(DrawEntity(
              Offset(message["dx"], message["dy"]),
              color: pentColor,
              strokeWidth: pentSize));
          //通知更新
          setState();
        } else if (message["type"] == "sendDrawNull") {
          //手抬起，添加占位
          //添加绘制标识
          points.add(List<DrawEntity>());
          //通知更新
          setState();
        } else if (message["type"] == "clear") {
          //清空画板
          points.clear();
          //通知更新
          setState();
        } else if (message["type"] == "sendDrawUndo") {
          //撤销，缓存到撤销容器
          undoPoints.add(points[points.length - 3]); //添加到撤销的数据里
          points.removeAt(points.length - 3); //移除数据
          //通知更新
          setState();
        } else if (message["type"] == "reverseUndoDate") {
          //反撤销数据
          List<DrawEntity> ss = undoPoints.removeLast();
          points.insert(points.length - 2, ss);
          //通知更新
          setState();
        }
      },
      onDone: () {
        print("连接断开 onDone");
        //尝试重新连接
        _socketConnect();
      },
      onError: (err) {
        print("连接异常 onError：");
        print(err);
      },
      cancelOnError: true,
    );
  }

  //清除数据
  clear() {
    //清除数据
    points.clear();
    //通知更新
    setState();
    _channel.sink
        .add(jsonEncode({'uuid': 'xxxx', 'type': 'clear', 'msg': 'clear'}));
  }

  //绘制数据
  sendDraw(Offset localPosition) {
    if (points.length == 0) {
      points.add(List<DrawEntity>());
      points.add(List<DrawEntity>());
    }
    //添加绘制
    points[points.length - 2].add(
        DrawEntity(localPosition, color: pentColor, strokeWidth: pentSize));
//    points.add(localPosition);
    //通知更新
    setState();

    //发送绘制消息给服务端
    _channel.sink.add(jsonEncode({
      'uuid': 'xxxx',
      'type': 'sendDraw',
      'pentColor': pentColor,
      'pentSize': pentSize,
      "dx": localPosition.dx,
      "dy": localPosition.dy
    }));
  }

  //绘制Null数据隔断标识
  sendDrawNull() {
    //添加绘制标识
    points.add(List<DrawEntity>());
    //通知更新
    setState();
    //发送绘制消息给服务端
    _channel.sink.add(jsonEncode({'uuid': 'xxxx', 'type': 'sendDrawNull'}));
  }

  //撤销一条数据
  undoDate() {
    //撤销，缓存到撤销容器
    undoPoints.add(points[points.length - 3]); //添加到撤销的数据里
    points.removeAt(points.length - 3); //移除数据
    setState();
    //发送绘制消息给服务端
    _channel.sink.add(jsonEncode({'uuid': 'xxxx', 'type': 'sendDrawUndo'}));
  }

  //反撤销一条数据
  reverseUndoDate() {
    List<DrawEntity> ss = undoPoints.removeLast();
    points.insert(points.length - 2, ss);

    setState();
    //发送绘制消息给服务端
    _channel.sink.add(jsonEncode({'uuid': 'xxxx', 'type': 'reverseUndoDate'}));
  }

  @override
  void dispose() {
    _channel.sink?.close();
    super.dispose();
  }

  _update() {
    pointsList = List<DrawEntity>();
    for (int i = 0; i < points.length - 1; i++) {
      pointsList.addAll(points[i]);
      pointsList.add(null);
    }
  }

  setState() {
    _update();
    notifyListeners();
  }
}
