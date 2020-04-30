import 'package:flutter/material.dart';
import 'package:flutter_draw/drawguess/draw_entity.dart';

import '../draw_provider.dart';

//自定义 Canvas 画板（ pengzhenkun - 2020.04.30 ）
class SignaturePainter extends CustomPainter {
  List<DrawEntity> pointsList;
  Paint pt;

  SignaturePainter(this.pointsList) {
    pt = Paint() //设置笔的属性
      ..color = pintColor["default"]
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.bevel;
  }

  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      //画线
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        pt
          ..color = pintColor[pointsList[i].color]
          ..strokeWidth = pointsList[i].strokeWidth;

        canvas.drawLine(pointsList[i].offset, pointsList[i + 1].offset, pt);
      }
    }
  }

//是否重绘
  bool shouldRepaint(SignaturePainter other) => other.pointsList != pointsList;
}

//drawLine(Offset p1, Offset p2, Paint paint) → void
//canvas.drawOval(
//Rect.fromCircle(center: points[i], radius: 20.0), paint);
//canvas.drawOval(rect, paint)
//canvas.drawCircle(points[i], 10.0, paint);
