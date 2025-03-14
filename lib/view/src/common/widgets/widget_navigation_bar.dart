import 'package:flutter/material.dart';

/// A widget designed to serve as a header with navigation functionalities.
///
class LvWidgetNavigationBar extends StatefulWidget {
  /// Default widget constructor.
  ///
  const LvWidgetNavigationBar({
    super.key,
    required this.label,
    this.includeBackButton = true,
  });

  /// The text value displayed as a title to this navigation bar.
  ///
  final String label;

  /// Whether to include a back button into the navigation bar display.
  ///
  final bool includeBackButton;

  @override
  State<LvWidgetNavigationBar> createState() => _LvWidgetNavigationBarState();
}

class _LvWidgetNavigationBarState extends State<LvWidgetNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            if (widget.includeBackButton)
              if (MediaQuery.of(context).size.width < 1000)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              else
                FilledButton.tonalIcon(
                  label: Text('CLOSE'),
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
          ],
        ),
      ),
    );
  }
}
