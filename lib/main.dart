import 'package:flutter/material.dart';
import 'package:label_verify/view/src/routes/splash/route_splash.dart';

void main() async {
  runApp(const LvApp());
}

/// Entry point for the "Label Verify" application.
///
/// The application is used to verify and review documents with specific content,
/// as well as any changes across document versions.
///
class LvApp extends StatelessWidget {
  /// Default widget constructor.
  ///
  const LvApp({super.key});

  /// Key referencing state to a [Navigator] object.
  ///
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: const LvRouteSplash(),
      theme: ThemeData(
        primaryColor: Colors.grey.shade900,
      ),
    );
  }
}
