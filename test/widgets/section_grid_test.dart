// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/theme/design_tokens.dart';
import 'package:portfolio/widgets/section_shell.dart';

const double _gutter = Space.md;

Future<void> _pump(
  WidgetTester tester, {
  required double width,
  required List<Widget> children,
  int desktopColumns = 2,
}) async {
  tester.view
    ..physicalSize = Size(width, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(width, 900)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: SectionGrid(
              desktopColumns: desktopColumns,
              gutter: _gutter,
              children: children,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _cell(String key, int lines) {
  return Container(
    key: ValueKey(key),
    color: const Color(0xFF000000),
    child: Text(List.filled(lines, 'line').join('\n')),
  );
}

void main() {
  testWidgets('columns are equal and fill the width', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      width: 980,
      children: [_cell('a', 1), _cell('b', 1)],
    );

    const expected = (980 - _gutter) / 2;
    expect(tester.getSize(find.byKey(const ValueKey('a'))).width, expected);
    expect(tester.getSize(find.byKey(const ValueKey('b'))).width, expected);
    expect(tester.getBottomRight(find.byKey(const ValueKey('b'))).dx, 980);
  });

  testWidgets('cells in the same row share the tallest height', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      width: 980,
      children: [_cell('short', 1), _cell('tall', 4)],
    );

    final short = tester.getSize(find.byKey(const ValueKey('short')));
    final tall = tester.getSize(find.byKey(const ValueKey('tall')));
    expect(short.height, tall.height);
    expect(short.height, greaterThan(0));
  });

  testWidgets('an incomplete last row keeps the column width', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      width: 980,
      children: [_cell('a', 1), _cell('b', 1), _cell('c', 1)],
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('c'))).width,
      tester.getSize(find.byKey(const ValueKey('a'))).width,
    );
  });

  testWidgets('mobile collapses to a single column', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      width: 400,
      children: [_cell('a', 1), _cell('b', 1)],
    );

    expect(tester.getSize(find.byKey(const ValueKey('a'))).width, 400);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('b'))).dy,
      greaterThan(tester.getTopLeft(find.byKey(const ValueKey('a'))).dy),
    );
  });

  testWidgets('tablet uses its own column count', (WidgetTester tester) async {
    await _pump(
      tester,
      width: 1000,
      children: [_cell('a', 1), _cell('b', 1), _cell('c', 1)],
      desktopColumns: 3,
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('a'))).width,
      (1000 - _gutter) / 2,
    );
  });
}
