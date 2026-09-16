import 'package:eclat_se_connaitre/data/local_store.dart';
import 'package:eclat_se_connaitre/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('portée et hors-ligne visibles', (tester) async {
    final state = AppState(LocalStore());
    await tester.pumpWidget(EclatApp(state));
    expect(find.text('Éclat'), findsOneWidget);
    expect(find.text('Tout reste sur cet appareil'), findsOneWidget);
    expect(find.text('Une exploration, pas un diagnostic'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Commencer sans inscription'), findsOneWidget);
  });
}
