import 'dart:math';

import 'package:flutter/material.dart';

class RPSCustomPainter extends CustomPainter {
  final double x;
  final double y;
  final double angle;
  final bool isA;

  RPSCustomPainter(this.x, this.y, this.angle, this.isA);

  @override
  void paint(Canvas canvas, Size size) {
    // Circle
    Paint paint_stroke_0 =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.00
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.miter;

    Paint paint_fill_0 =
        Paint()
          ..color = isA ? Colors.redAccent : Colors.blueAccent
          ..style = PaintingStyle.fill
          ..strokeWidth = size.width * 0.00
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.miter;

    Path path_0 = Path();
    path_0.moveTo(size.width * 0.1, size.height * 0);
    path_0.cubicTo(
      size.width * 0.1,
      size.height * 0,
      size.width * 0.2,
      size.height * 0,
      size.width * 0.2,
      size.height * 0.2,
    );
    path_0.cubicTo(
      size.width * 0.2,
      size.height * 0.2,
      size.width * 0.2,
      size.height * 0.4,
      size.width * 0.1,
      size.height * 0.4,
    );
    path_0.cubicTo(
      size.width * 0,
      size.height * 0.4,
      size.width * 0,
      size.height * 0.2,
      size.width * 0,
      size.height * 0.2,
    );
    path_0.cubicTo(
      size.width * 0,
      size.height * 0.2,
      size.width * 0,
      size.height * 0,
      size.width * 0.1,
      size.height * 0,
    );
    path_0.close();

    canvas.drawPath(path_0, paint_fill_0);
    canvas.drawPath(path_0, paint_stroke_0);

    // Layer 1

    Paint paint_fill_1 =
        Paint()
          ..color = isA ? Colors.redAccent : Colors.blueAccent
          ..style = PaintingStyle.fill
          ..strokeWidth = size.width * 0.00
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.miter;

    Path path_1 = Path();
    path_1.moveTo(size.width * 0, size.height * 0.2);
    path_1.lineTo(size.width * 0, size.height * 0.7);
    path_1.lineTo(size.width * 0.2, size.height * 0.7);
    path_1.lineTo(size.width * 0.2, size.height * 0.2);
    path_1.lineTo(size.width * 0, size.height * 0.2);
    path_1.close();

    canvas.drawPath(path_1, paint_fill_1);

    // Layer 1

    Paint paint_stroke_1 =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.00
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.miter;

    canvas.drawPath(path_1, paint_stroke_1);
    // ---- 柄（handle）部分 ----
    double handleLeft = size.width * 0.075;
    double handleRight = size.width * 0.125;
    double handleTop = size.height * -0.3;
    double handleBottom = size.height * 0.3;

    // 柄の底辺中心（回転軸）
    double handleCx = (handleLeft + handleRight) / 2;
    double handleCy = handleBottom;

    // 回転角度（ラジアン）
    double theta = angle * pi / 180;

    // 回転関数
    Offset rotate(double x, double y) {
      double xr =
          handleCx + (x - handleCx) * cos(theta) - (y - handleCy) * sin(theta);
      double yr =
          handleCy + (x - handleCx) * sin(theta) + (y - handleCy) * cos(theta);
      return Offset(xr, yr);
    }

    // 柄の頂点
    Offset h1 = rotate(handleLeft, handleBottom); // 左下
    Offset h2 = rotate(handleLeft, handleTop); // 左上
    Offset h3 = rotate(handleRight, handleTop); // 右上
    Offset h4 = rotate(handleRight, handleBottom); // 右下

    // 柄 Path
    Path handlePath =
        Path()
          ..moveTo(h1.dx, h1.dy)
          ..lineTo(h2.dx, h2.dy)
          ..lineTo(h3.dx, h3.dy)
          ..lineTo(h4.dx, h4.dy)
          ..close();

    // 柄を描画
    Paint handlePaint =
        Paint()
          ..color = Colors.brown[700]!
          ..style = PaintingStyle.fill;
    canvas.drawPath(handlePath, handlePaint);

    // ---- ハンマー頭（head）部分 ----
    // 柄の上端の中心を取得（くっつける基点）
    Offset handleTopCenter = Offset((h2.dx + h3.dx) / 2, (h2.dy + h3.dy) / 2);

    // ハンマー頭のサイズ
    double headWidth = size.width * 0.18;
    double headHeight = size.height * 0.15;

    // 頭のローカル座標（中心を柄の先端に合わせる）
    List<Offset> headLocal = [
      Offset(-headWidth / 2, 0), // 左下（柄先に接する）
      Offset(-headWidth / 2, -headHeight), // 左上
      Offset(headWidth / 2, -headHeight), // 右上
      Offset(headWidth / 2, 0), // 右下
    ];

    // 回転後に変換
    List<Offset> headPoints =
        headLocal.map((p) {
          double xr =
              handleTopCenter.dx + p.dx * cos(theta) - p.dy * sin(theta);
          double yr =
              handleTopCenter.dy + p.dx * sin(theta) + p.dy * cos(theta);
          return Offset(xr, yr);
        }).toList();

    // 頭 Path
    Path headPath =
        Path()
          ..moveTo(headPoints[0].dx, headPoints[0].dy)
          ..lineTo(headPoints[1].dx, headPoints[1].dy)
          ..lineTo(headPoints[2].dx, headPoints[2].dy)
          ..lineTo(headPoints[3].dx, headPoints[3].dy)
          ..close();

    // 頭を描画
    Paint headPaint =
        Paint()
          ..color = Colors.grey[800]!
          ..style = PaintingStyle.fill;
    canvas.drawPath(headPath, headPaint);

    Paint eye_fill =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill
          ..strokeWidth = size.width * 0.00
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.miter;

    // Draw a perfect circle for the eye
    // Center and radius proportional to current size
    final double eyeCenterX = isA ? size.width * 0.15 : size.width * 0.05;
    final double eyeCenterY = size.height * 0.1;
    final double eyeRadius = size.width * 0.013;
    canvas.drawCircle(Offset(eyeCenterX, eyeCenterY), eyeRadius, eye_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
