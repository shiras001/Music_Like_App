import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// This test reproduces the responsive bottom-controls layout used in
// the LRC adjust screen and ensures no layout overflow / exceptions
// occur for several common device sizes and text scale factors.

Widget _buildResponsiveControls() {
  return SafeArea(
    top: false,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.of(context).textScaleFactor;
        final isNarrow = constraints.maxWidth < 420 || textScale > 1.2;
        if (isNarrow) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: ElevatedButton(onPressed: () {}, child: FittedBox(fit: BoxFit.scaleDown, child: Text('適用')))),
                    const SizedBox(width: 8),
                    Expanded(child: ElevatedButton(onPressed: () {}, child: FittedBox(fit: BoxFit.scaleDown, child: Text('復元')))),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(constraints: BoxConstraints(minWidth: 72), child: ElevatedButton(onPressed: () {}, child: FittedBox(fit: BoxFit.scaleDown, child: Text('-1.00s')))),
                        const SizedBox(width: 8),
                        ConstrainedBox(constraints: BoxConstraints(minWidth: 72), child: ElevatedButton(onPressed: () {}, child: FittedBox(fit: BoxFit.scaleDown, child: Text('-0.10s')))),
                        const SizedBox(width: 8),
                        ConstrainedBox(constraints: BoxConstraints(minWidth: 72), child: ElevatedButton(onPressed: () {}, child: FittedBox(fit: BoxFit.scaleDown, child: Text('-0.01s')))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(constraints: BoxConstraints(minWidth: 72), child: ElevatedButton(onPressed: () {}, child: FittedBox(fit: BoxFit.scaleDown, child: Text('+1.00s')))),
                        const SizedBox(width: 8),
                        ConstrainedBox(constraints: BoxConstraints(minWidth: 72), child: ElevatedButton(onPressed: () {}, child: FittedBox(fit: BoxFit.scaleDown, child: Text('+0.10s')))),
                        const SizedBox(width: 8),
                        ConstrainedBox(constraints: BoxConstraints(minWidth: 72), child: ElevatedButton(onPressed: () {}, child: FittedBox(fit: BoxFit.scaleDown, child: Text('+0.01s')))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: ElevatedButton(onPressed: () {}, child: Text('適用'))),
                  const SizedBox(width: 8),
                  Expanded(child: ElevatedButton(onPressed: () {}, child: Text('復元'))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(constraints: BoxConstraints(minWidth: 72), child: ElevatedButton(onPressed: () {}, child: Text('-1.00s'))),
                  const SizedBox(width: 8),
                  ConstrainedBox(constraints: BoxConstraints(minWidth: 72), child: ElevatedButton(onPressed: () {}, child: Text('-0.10s'))),
                  const SizedBox(width: 8),
                  ConstrainedBox(constraints: BoxConstraints(minWidth: 72), child: ElevatedButton(onPressed: () {}, child: Text('-0.01s'))),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(constraints: BoxConstraints(minWidth: 72), child: ElevatedButton(onPressed: () {}, child: Text('+1.00s'))),
                  const SizedBox(width: 8),
                  ConstrainedBox(constraints: BoxConstraints(minWidth: 72), child: ElevatedButton(onPressed: () {}, child: Text('+0.10s'))),
                  const SizedBox(width: 8),
                  ConstrainedBox(constraints: BoxConstraints(minWidth: 72), child: ElevatedButton(onPressed: () {}, child: Text('+0.01s'))),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sizes = [
    Size(360, 800), // typical phone portrait
    Size(800, 360), // landscape
    Size(412, 915), // taller phone
    Size(1440, 3120), // large device
  ];
  final textScales = [1.0, 1.3, 1.6];

  for (final size in sizes) {
    for (final ts in textScales) {
      testWidgets('responsive controls no overflow ${size.width}x${size.height} ts=$ts', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size, textScaleFactor: ts),
            child: Scaffold(body: Column(children: [Expanded(child: Container()), _buildResponsiveControls()])),
          ),
        ));

        // Allow frames to settle
        await tester.pumpAndSettle();

        // Ensure no exceptions were thrown during layout
        final exception = tester.takeException();
        expect(exception, isNull, reason: 'Layout threw exception for ${size.width}x${size.height} ts=$ts');
      });
    }
  }
}
