// // test/widget_test.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:planify/main.dart';
// import 'package:planify/services/gemini_service.dart'; 

// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     final geminiService = GeminiService(apiKey: 'AIzaSyBFS5lVuEZzNklLyta4ioepOs2DDw2xPGA');

//     await tester.pumpWidget(
//       MyApp(
//         geminiService: geminiService,
//       ),
//     );

//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);

//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();

//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }