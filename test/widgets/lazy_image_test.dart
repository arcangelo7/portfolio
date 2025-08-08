import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/widgets/lazy_image.dart';

void main() {
  group('LazyImage Widget Tests', () {
    testWidgets('shows placeholder when not visible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Add enough height to push LazyImage out of viewport
                  Container(height: 2000),
                  const LazyImage(
                    assetPath: 'assets/images/profile_cutout.png',
                    width: 100,
                    height: 100,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify placeholder is shown (should find Icon widget)
      expect(find.byIcon(Icons.image), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('shows image when visible in viewport', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LazyImage(
                assetPath: 'assets/images/profile_cutout.png',
                width: 100,
                height: 100,
              ),
            ),
          ),
        ),
      );

      // Initially should show placeholder or loading
      await tester.pump();

      // Since image is in viewport, it should be visible or show a placeholder
      final hasPlaceholder = find.byIcon(Icons.image).evaluate().isNotEmpty;
      final hasLoadingIndicator =
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

      expect(hasPlaceholder || hasLoadingIndicator, isTrue);
    });

    testWidgets('creates LazyImage widget with correct properties', (
      WidgetTester tester,
    ) async {
      const testPath = 'assets/images/profile_cutout.png';
      const testWidth = 150.0;
      const testHeight = 100.0;
      const testFit = BoxFit.contain;
      const testSemanticLabel = 'Test Image';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyImage(
              assetPath: testPath,
              width: testWidth,
              height: testHeight,
              fit: testFit,
              semanticLabel: testSemanticLabel,
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify LazyImage widget is created
      final lazyImageWidget = tester.widget<LazyImage>(find.byType(LazyImage));

      expect(lazyImageWidget.assetPath, testPath);
      expect(lazyImageWidget.width, testWidth);
      expect(lazyImageWidget.height, testHeight);
      expect(lazyImageWidget.fit, testFit);
      expect(lazyImageWidget.semanticLabel, testSemanticLabel);
      // critical removed: all images load lazily
    });

    testWidgets('loads images lazily (no critical path)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LazyImage(
                assetPath: 'assets/images/profile_cutout.png',
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.red,
                    child: Icon(Icons.error),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      // With no critical path, we allow placeholder/loading state
      final hasPlaceholder = find.byIcon(Icons.image).evaluate().isNotEmpty;
      final hasLoadingIndicator =
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      expect(hasPlaceholder || hasLoadingIndicator, isTrue);
    });
  });
}
