// import 'package:flutter/material.dart';
// abstract class WaterMarkPainter {
//   /// 绘制"单元水印"，完整的水印是由单元水印重复平铺组成,返回值为"单元水印"占用空间的大小。
//   /// [devicePixelRatio]: 因为最终要将绘制内容保存为图片，所以在绘制时需要根据屏幕的
//   /// DPR来放大，以防止失真
//   Size paintUnit(Canvas canvas, double devicePixelRatio);
//
//   /// 是否需要重绘
//   bool shouldRepaint(covariant WaterMarkPainter oldPainter) => true;
// }
// class WaterMark extends StatefulWidget {
//   WaterMark({
//     Key? key,
//     this.repeat = ImageRepeat.repeat,
//     required this.painter,
//   }) : super(key: key);
//
//   /// 单元水印画笔
//   final WaterMarkPainter painter;
//
//   /// 单元水印的重复方式
//   final ImageRepeat repeat;
//
//   @override
//   State<WaterMark> createState() => _WaterMarkState();
// }
// class _WaterMarkState extends State<WaterMark> {
//   late Future<MemoryImage> _memoryImageFuture;
//
//   @override
//   void initState() {
//     // 缓存的是promise
//     _memoryImageFuture = _getWaterMarkImage();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.expand( // 水印尽可能大
//       child: FutureBuilder(
//         future: _memoryImageFuture,
//         builder: (BuildContext context, AsyncSnapshot snapshot) {
//           if (snapshot.connectionState != ConnectionState.done) {
//             // 如果单元水印还没有绘制好先返回一个空的Container
//             return Container();
//           } else {
//             // 如果单元水印已经绘制好，则渲染水印
//             return DecoratedBox(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: snapshot.data, // 背景图，即我们绘制的单元水印图片
//                   repeat: widget.repeat, // 指定重复方式
//                   alignment: Alignment.topLeft,
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   @override
//   void didUpdateWidget(WaterMark oldWidget) {
//     if (widget.painter.runtimeType != oldWidget.painter.runtimeType ||
//         widget.painter.shouldRepaint(oldWidget.painter)) {
//       //先释放之前的缓存
//       _memoryImageFuture.then((value) => value.evict());
//       //重新绘制并缓存
//       _memoryImageFuture = _getWaterMarkImage();
//     }
//     super.didUpdateWidget(oldWidget);
//   }
//
//   // 离屏绘制单元水印并将绘制结果转为图片缓存起来
//   Future<MemoryImage> _getWaterMarkImage() async {
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder);
//     // 绘制单元水印并获取其大小
//     final Size size = widget.painter.paintUnit(canvas);
//     final picture = recorder.endRecording();
//     //将单元水印导为图片并缓存起来
//     final img = await picture.toImage(size.width.ceil(), size.height.ceil());
//     final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
//     final pngBytes = byteData!.buffer.asUint8List();
//     return MemoryImage(pngBytes);
//   }
//
//   @override
//   void dispose() {
//     _memoryImageFuture.then((value) => value.evict());
//     super.dispose();
//   }
// }
//
// class WaterMaskTest extends StatelessWidget {
//   const WaterMaskTest({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         wChild(1, Colors.white, 200),
//         WaterMark(
//           painter: TextWaterMarkPainter(text: 'wendux', rotate: -20),
//         ),
//       ],
//     );
//   }
//
//   Widget wChild(int index, color, double size) {
//     return Listener(
//       onPointerDown: (e) => print(index),
//       child: Container(
//         width: size,
//         height: size,
//         color: Colors.grey,
//       ),
//     );
//   }
// }
// class TextWaterMarkPainter extends WaterMarkPainter {
//   TextWaterMarkPainter({
//     Key? key,
//     double? rotate,
//     EdgeInsets? padding,
//     TextStyle? textStyle,
//     required this.text,
//   })  : assert(rotate == null || rotate >= -90 && rotate <= 90),
//         rotate = rotate ?? 0,
//         padding = padding ?? const EdgeInsets.all(10.0),
//         textStyle = textStyle ??
//             TextStyle(
//               color: Color.fromARGB(20, 0, 0, 0),
//               fontSize: 14,
//             );
//
//   double rotate; // 文本旋转的度数，是角度不是弧度
//   TextStyle textStyle; // 文本样式
//   EdgeInsets padding; // 文本的 padding
//   String text; // 文本
//
//   @override
//   Size paintUnit(Canvas canvas,double devicePixelRatio) {
//     //根据屏幕 devicePixelRatio 对文本样式中长度相关的一些值乘以devicePixelRatio
//     final _textStyle = _handleTextStyle(textStyle, devicePixelRatio);
//     final _padding = padding * devicePixelRatio;
//
//     //构建文本段落
//     final builder = ui.ParagraphBuilder(_textStyle.getParagraphStyle(
//       textDirection: textDirection,
//       textAlign: TextAlign.start,
//       textScaleFactor: devicePixelRatio,
//     ));
//
//     //添加要绘制的文本及样式
//     builder
//       ..pushStyle(_textStyle.getTextStyle()) // textStyle 为 ui.TextStyle
//       ..addText(text);
//
//     //layout 后我们才能知道文本占用的空间
//     ui.Paragraph paragraph = builder.build()
//       ..layout(ui.ParagraphConstraints(width: double.infinity));
//
//     //文本占用的真实宽度
//     final textWidth = paragraph.longestLine.ceilToDouble();
//     //文本占用的真实高度
//     final fontSize = paragraph.height;
//
//     ...//省略应用旋转和 padding 的相关代码
//
//     //绘制文本
//     canvas.drawParagraph(paragraph, Offset.zero);
//
//   }
//
//   TextStyle _handleTextStyle(double devicePixelRatio) {
//     var style = textStyle;
//     double _scale(attr) => attr == null ? 1.0 : devicePixelRatio;
//     return style.apply(
//       decorationThicknessFactor: _scale(style.decorationThickness),
//       letterSpacingFactor: _scale(style.letterSpacing),
//       wordSpacingFactor: _scale(style.wordSpacing),
//       heightFactor: _scale(style.height),
//     );
//   }
//
//   @override
//   bool shouldRepaint(TextWaterMarkPainter oldPainter) {
//     ...// 待实现
//   }
// }