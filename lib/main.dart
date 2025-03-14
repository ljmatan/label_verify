import 'package:flutter/material.dart';
import 'package:label_verify/config.dart';
import 'package:label_verify/view/src/routes/dashboard/route_dashboard.dart';

void main() async {
  await LvConfig.instance.init();
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
      home: LvRouteDashboard(),
      theme: ThemeData(
        primaryColor: Colors.grey.shade900,
      ),
    );
  }
}
