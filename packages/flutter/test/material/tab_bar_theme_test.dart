// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const String _tab1Text = 'tab 1';
const String _tab2Text = 'tab 2';
const String _tab3Text = 'tab 3';

final Key _painterKey = UniqueKey();

const List<Tab> _tabs = <Tab>[
  Tab(text: _tab1Text, icon: Icon(Icons.looks_one)),
  Tab(text: _tab2Text, icon: Icon(Icons.looks_two)),
  Tab(text: _tab3Text, icon: Icon(Icons.looks_3)),
];

Widget _withTheme(TabBarTheme theme) {
  return MaterialApp(
    theme: ThemeData(tabBarTheme: theme),
    home: Scaffold(
      body: RepaintBoundary(
        key: _painterKey,
        child: TabBar(
          tabs: _tabs,
          controller: TabController(length: _tabs.length, vsync: const TestVSync()),
        ),
      ),
    ),
  );
}

RenderParagraph _iconRenderObject(WidgetTester tester, IconData icon) {
  return tester.renderObject<RenderParagraph>(
      find.descendant(of: find.byIcon(icon), matching: find.byType(RichText)));
}

void main() {
  testWidgets('Tab bar defaults', (WidgetTester tester) async {
    await tester.pumpWidget(_withTheme(null));

    final RenderParagraph selectedRenderObject = tester.renderObject<RenderParagraph>(find.text(_tab1Text));
    expect(selectedRenderObject.text.style.fontFamily, equals('Roboto'));
    expect(selectedRenderObject.text.style.fontSize, equals(14.0));
    expect(selectedRenderObject.text.style.color, equals(Colors.white));
    final RenderParagraph unselectedRenderObject = tester.renderObject<RenderParagraph>(find.text(_tab2Text));
    expect(unselectedRenderObject.text.style.fontFamily, equals('Roboto'));
    expect(unselectedRenderObject.text.style.fontSize, equals(14.0));
    expect(unselectedRenderObject.text.style.color, equals(Colors.white.withAlpha(0xB2)));
  });

  testWidgets('Tab bar theme overrides label color (selected)', (WidgetTester tester) async {
    const Color labelColor = Colors.black;
    const TabBarTheme tabBarTheme = TabBarTheme(labelColor: labelColor);

    await tester.pumpWidget(_withTheme(tabBarTheme));

    final RenderParagraph textRenderObject = tester.renderObject<RenderParagraph>(find.text(_tab1Text));
    expect(textRenderObject.text.style.color, equals(labelColor));
    final RenderParagraph iconRenderObject = _iconRenderObject(tester, Icons.looks_one);
    expect(iconRenderObject.text.style.color, equals(labelColor));
  });

  testWidgets('Tab bar theme overrides label styles', (WidgetTester tester) async {
    const TextStyle labelStyle = TextStyle(fontFamily: 'foobar');
    const TextStyle unselectedLabelStyle = TextStyle(fontFamily: 'baz');
    const TabBarTheme tabBarTheme = TabBarTheme(
      labelStyle: labelStyle,
      unselectedLabelStyle: unselectedLabelStyle,
    );

    await tester.pumpWidget(_withTheme(tabBarTheme));

    final RenderParagraph selectedRenderObject = tester.renderObject<RenderParagraph>(find.text(_tab1Text));
    expect(selectedRenderObject.text.style.fontFamily, equals(labelStyle.fontFamily));
    final RenderParagraph unselectedRenderObject = tester.renderObject<RenderParagraph>(find.text(_tab2Text));
    expect(unselectedRenderObject.text.style.fontFamily, equals(unselectedLabelStyle.fontFamily));
  });

  testWidgets('Tab bar theme with just label style specified', (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/28784
    const TextStyle labelStyle = TextStyle(fontFamily: 'foobar');
    const TabBarTheme tabBarTheme = TabBarTheme(
      labelStyle: labelStyle,
    );

    await tester.pumpWidget(_withTheme(tabBarTheme));

    final RenderParagraph selectedRenderObject = tester.renderObject<RenderParagraph>(find.text(_tab1Text));
    expect(selectedRenderObject.text.style.fontFamily, equals(labelStyle.fontFamily));
    final RenderParagraph unselectedRenderObject = tester.renderObject<RenderParagraph>(find.text(_tab2Text));
    expect(unselectedRenderObject.text.style.fontFamily, equals('Roboto'));
    expect(unselectedRenderObject.text.style.fontSize, equals(14.0));
    expect(unselectedRenderObject.text.style.color, equals(Colors.white.withAlpha(0xB2)));
  });

  testWidgets('Tab bar label styles override theme label styles', (WidgetTester tester) async {
    const TextStyle labelStyle = TextStyle(fontFamily: '1');
    const TextStyle unselectedLabelStyle = TextStyle(fontFamily: '2');
    const TextStyle themeLabelStyle = TextStyle(fontFamily: '3');
    const TextStyle themeUnselectedLabelStyle = TextStyle(fontFamily: '4');
    const TabBarTheme tabBarTheme = TabBarTheme(
      labelStyle: themeLabelStyle,
      unselectedLabelStyle: themeUnselectedLabelStyle,
    );

    await tester.pumpWidget(
      MaterialApp(
          theme: ThemeData(tabBarTheme: tabBarTheme),
          home: Scaffold(body: TabBar(
            tabs: _tabs,
            controller: TabController(length: _tabs.length, vsync: const TestVSync()),
            labelStyle: labelStyle,
            unselectedLabelStyle: unselectedLabelStyle,
          ),
        ),
      ),
    );

    final RenderParagraph selectedRenderObject = tester.renderObject<RenderParagraph>(find.text(_tab1Text));
    expect(selectedRenderObject.text.style.fontFamily, equals(labelStyle.fontFamily));
    final RenderParagraph unselectedRenderObject = tester.renderObject<RenderParagraph>(find.text(_tab2Text));
    expect(unselectedRenderObject.text.style.fontFamily, equals(unselectedLabelStyle.fontFamily));
  });

  testWidgets('Tab bar theme overrides label color (unselected)', (WidgetTester tester) async {
    const Color unselectedLabelColor = Colors.black;
    const TabBarTheme tabBarTheme = TabBarTheme(unselectedLabelColor: unselectedLabelColor);

    await tester.pumpWidget(_withTheme(tabBarTheme));

    final RenderParagraph textRenderObject = tester.renderObject<RenderParagraph>(find.text(_tab2Text));
    expect(textRenderObject.text.style.color, equals(unselectedLabelColor));
    final RenderParagraph iconRenderObject = _iconRenderObject(tester, Icons.looks_two);
    expect(iconRenderObject.text.style.color, equals(unselectedLabelColor));
  });

  testWidgets('Tab bar theme overrides tab indicator size (tab)', (WidgetTester tester) async {
    const TabBarTheme tabBarTheme = TabBarTheme(indicatorSize: TabBarIndicatorSize.tab);

    await tester.pumpWidget(_withTheme(tabBarTheme));

    await expectLater(
      find.byKey(_painterKey),
      matchesGoldenFile('tab_bar_theme.tab_indicator_size_tab.png'),
      skip: !Platform.isLinux,
    );
  });

  testWidgets('Tab bar theme overrides tab indicator size (label)', (WidgetTester tester) async {
    const TabBarTheme tabBarTheme = TabBarTheme(indicatorSize: TabBarIndicatorSize.label);

    await tester.pumpWidget(_withTheme(tabBarTheme));

    await expectLater(
      find.byKey(_painterKey),
      matchesGoldenFile('tab_bar_theme.tab_indicator_size_label.png'),
      skip: !Platform.isLinux,
    );
  });

  testWidgets('Tab bar theme - custom tab indicator', (WidgetTester tester) async {
    final TabBarTheme tabBarTheme = TabBarTheme(
      indicator: BoxDecoration(
        border: Border.all(color: Colors.black),
        shape: BoxShape.rectangle,
      ),
    );

    await tester.pumpWidget(_withTheme(tabBarTheme));

    await expectLater(
      find.byKey(_painterKey),
      matchesGoldenFile('tab_bar_theme.custom_tab_indicator.png'),
      skip: !Platform.isLinux,
    );
  });

  testWidgets('Tab bar theme - beveled rect indicator', (WidgetTester tester) async {
    final TabBarTheme tabBarTheme = TabBarTheme(
      indicator: ShapeDecoration(
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        color: Colors.black,
      ),
    );

    await tester.pumpWidget(_withTheme(tabBarTheme));

    await expectLater(
      find.byKey(_painterKey),
      matchesGoldenFile('tab_bar_theme.beveled_rect_indicator.png'),
      skip: !Platform.isLinux,
    );
  });
}
