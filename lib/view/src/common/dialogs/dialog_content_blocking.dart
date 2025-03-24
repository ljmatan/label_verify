import 'package:flutter/material.dart';
import 'package:label_verify/main.dart';

/// An overlay dialog widget that blocks the rest of the content.
///
class LvDialogContentBlocking extends StatefulWidget {
  /// Default widget constructor.
  ///
  const LvDialogContentBlocking({super.key});

  /// Value determining whether the [LvDialogContentBlocking] is currently being displayed
  /// with the [display] method.
  ///
  static bool displayed = false;

  /// Ovelays this widget over the rest of the content using the [showDialog] method.
  ///
  static Future<void> display([
    BuildContext? context,
  ]) async {
    displayed = true;
    final result = await showDialog(
      context: context ?? LvApp.navigatorKey.currentContext!,
      builder: (context) {
        return const LvDialogContentBlocking();
      },
    );
    displayed = false;
    return result;
  }

  /// Calls the [Navigator.pop] method on any available context.
  ///
  static void close([BuildContext? context]) {
    if (displayed && (LvApp.navigatorKey.currentContext != null || context != null)) {
      Navigator.pop(context ?? LvApp.navigatorKey.currentContext!);
    }
  }

  @override
  State<LvDialogContentBlocking> createState() => _LvDialogContentBlockingState();
}

class _LvDialogContentBlockingState extends State<LvDialogContentBlocking> {
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white70,
      ),
      child: SizedBox.expand(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
