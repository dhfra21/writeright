import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/ml_inference/ml_inference_service.dart';

/// Touch-based drawing canvas for handwriting input.
/// Supports multi-stroke drawing, clear, and PNG export.
class DrawingCanvas extends StatefulWidget {
  final ValueChanged<List<List<Offset>>>? onStrokesChanged;
  final double strokeWidth;
  final Color strokeColor;
  final double width;
  final double height;

  const DrawingCanvas({
    super.key,
    this.onStrokesChanged,
    this.strokeWidth = 6.0,
    this.strokeColor = AppTheme.primaryPurple,
    this.width = 280,
    this.height = 280,
  });

  @override
  State<DrawingCanvas> createState() => DrawingCanvasState();
}

class DrawingCanvasState extends State<DrawingCanvas> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  int _paintVersion = 0;

  /// Clears all strokes from the canvas.
  void clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
      _paintVersion++;
    });
  }

  /// Returns true if the canvas has any strokes.
  bool get hasStrokes => _strokes.isNotEmpty;

  /// Returns the current number of strokes.
  int get strokeCount => _strokes.length;

  /// Removes the last stroke (undo).
  void undo() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
        _currentStroke = [];
        _paintVersion++;
      });
      widget.onStrokesChanged?.call(_strokes.map((s) => s.toList()).toList());
    }
  }

  /// Converts strokes to List<Point> for the ML inference service.
  List<Point> toPoints() {
    final points = <Point>[];
    for (final stroke in _strokes) {
      for (final offset in stroke) {
        points.add(Point(x: offset.dx, y: offset.dy));
      }
    }
    return points;
  }

  /// Exports the canvas drawing as a PNG Uint8List.
  Future<Uint8List?> exportAsImage() async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, widget.width, widget.height),
      );

      // White background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, widget.width, widget.height),
        Paint()..color = Colors.white,
      );

      // Draw all strokes
      final paint = Paint()
        ..color = widget.strokeColor
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = widget.strokeWidth
        ..style = PaintingStyle.stroke;

      for (final stroke in _strokes) {
        if (stroke.length < 2) continue;
        final path = Path()..moveTo(stroke[0].dx, stroke[0].dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(
        widget.width.toInt(),
        widget.height.toInt(),
      );
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _currentStroke = [details.localPosition];
          _strokes.add(_currentStroke);
          _paintVersion++;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _currentStroke.add(details.localPosition);
          _paintVersion++;
        });
        widget.onStrokesChanged?.call(
          _strokes.map((s) => s.toList()).toList(),
        );
      },
      onPanEnd: (details) {
        widget.onStrokesChanged?.call(
          _strokes.map((s) => s.toList()).toList(),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.primaryPurple.withValues(alpha: 0.2),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPurple.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _StrokePainter(
              strokes: _strokes,
              strokeColor: widget.strokeColor,
              strokeWidth: widget.strokeWidth,
              version: _paintVersion,
            ),
          ),
        ),
      ),
    );
  }
}

class _StrokePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color strokeColor;
  final double strokeWidth;
  final int version;

  _StrokePainter({
    required this.strokes,
    required this.strokeColor,
    required this.strokeWidth,
    required this.version,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke[0].dx, stroke[0].dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) =>
      oldDelegate.version != version ||
      oldDelegate.strokeColor != strokeColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
