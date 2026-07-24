// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/widgets/timeline_item.dart';

Widget _buildTimeline({required List<bool> currents, bool isMobile = false}) {
  return MaterialApp(
    theme: ThemeData.light(),
    home: Scaffold(
      body: Column(
        children: [
          for (var i = 0; i < currents.length; i++)
            TimelineItem(
              isFirst: i == 0,
              isLast: i == currents.length - 1,
              isCurrent: currents[i],
              isMobile: isMobile,
              child: Text('Entry $i'),
            ),
        ],
      ),
    ),
  );
}

Container _innerNode(WidgetTester tester, int index) {
  final items = find.byType(TimelineItem);
  final nodes = find.descendant(
    of: items.at(index),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).shape == BoxShape.circle,
    ),
  );
  // Last matching container is the 12px inner node (the halo comes first).
  return tester.widget<Container>(nodes.last);
}

void main() {
  testWidgets('renders one node per entry', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildTimeline(currents: const [true, false, false]),
    );

    expect(find.byType(TimelineItem), findsNWidgets(3));
    expect(find.text('Entry 0'), findsOneWidget);
    expect(find.text('Entry 2'), findsOneWidget);
  });

  testWidgets('current node is filled with primary, past node is outlined', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTimeline(currents: const [true, false]),
    );

    final theme = ThemeData.light();
    final currentNode = _innerNode(tester, 0);
    final currentDecoration = currentNode.decoration as BoxDecoration;
    expect(currentDecoration.color, theme.colorScheme.primary);
    expect(currentDecoration.border, isNull);

    final pastNode = _innerNode(tester, 1);
    final pastDecoration = pastNode.decoration as BoxDecoration;
    expect(pastDecoration.color, theme.colorScheme.surface);
    expect(pastDecoration.border, isNotNull);
  });

  testWidgets('line does not extend above the first or below the last node', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTimeline(currents: const [false, false, false]),
    );

    const nodeCenter = 36.0;
    final items = find.byType(TimelineItem);

    Positioned lineOf(int index) {
      final lines = find.descendant(
        of: items.at(index),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Positioned &&
              widget.child is Container &&
              (widget.child as Container).color != null,
        ),
      );
      return tester.widget<Positioned>(lines.first);
    }

    final firstLine = lineOf(0);
    expect(firstLine.top, nodeCenter);
    expect(firstLine.bottom, 0);

    final middleLine = lineOf(1);
    expect(middleLine.top, 0);
    expect(middleLine.bottom, 0);

    final lastLine = lineOf(2);
    expect(lastLine.top, 0);
    expect(lastLine.height, nodeCenter);
    expect(lastLine.bottom, isNull);
  });

  testWidgets('single entry renders no line', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTimeline(currents: const [false]));

    final lines = find.descendant(
      of: find.byType(TimelineItem),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Positioned &&
            widget.child is Container &&
            (widget.child as Container).color != null,
      ),
    );
    expect(lines, findsNothing);
  });

  testWidgets('explicit nodeCenter shifts the node', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: const Scaffold(
          body: TimelineItem(
            isFirst: true,
            isLast: false,
            isCurrent: false,
            isMobile: false,
            nodeCenter: 38,
            child: Text('Entry'),
          ),
        ),
      ),
    );

    final node = find.descendant(
      of: find.byType(TimelineItem),
      matching: find.byWidgetPredicate(
        (widget) => widget is Positioned && widget.top == 38 - 10,
      ),
    );
    expect(node, findsOneWidget);
  });
}
