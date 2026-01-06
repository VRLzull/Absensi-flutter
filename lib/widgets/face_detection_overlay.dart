import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionOverlay extends StatelessWidget {
  final List<Face> faces;

  const FaceDetectionOverlay({
    super.key,
    required this.faces,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FaceDetectionPainter(faces),
      size: Size.infinite,
    );
  }
}

class FaceDetectionPainter extends CustomPainter {
  final List<Face> faces;

  FaceDetectionPainter(this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty) return;

    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final landmarkPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    for (final face in faces) {
      // Draw bounding box
      final rect = face.boundingBox;
      canvas.drawRect(rect, paint);

      // Draw landmarks
      for (final landmark in face.landmarks.values) {
        if (landmark != null) {
          canvas.drawCircle(
            Offset(landmark.position.x.toDouble(), landmark.position.y.toDouble()),
            3,
            landmarkPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
