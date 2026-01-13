import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

// Inline the icon widget to avoid Google Fonts dependency in tests
class ExportableAppIcon extends StatelessWidget {
  final double size;

  const ExportableAppIcon({super.key, this.size = 1024});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF050505), // void_
      ),
      child: Stack(
        children: [
          // Signal accent bar at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size * 0.12,
            child: Container(
              color: const Color(0xFFFF6B35), // signal
            ),
          ),
          // Just "CS" letters
          Center(
            child: Text(
              'CS',
              style: TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: size * 0.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFE8E8E8), // bone
                height: 1.0,
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('Export app icon as PNG', (WidgetTester tester) async {
    const size = 1024.0;

    // Create a repaint boundary key
    final boundaryKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: boundaryKey,
          child: const ExportableAppIcon(size: size),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find the repaint boundary
    final boundary =
        boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    // Capture the image
    final image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Save to assets folder
    final file = File('assets/icons/app_icon.png');
    await file.create(recursive: true);
    await file.writeAsBytes(pngBytes);

    print('Icon exported to: ${file.absolute.path}');
    expect(file.existsSync(), true);
  });
}
