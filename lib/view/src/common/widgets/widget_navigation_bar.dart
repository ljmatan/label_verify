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
    this.onBackPressed,
    this.actions,
  });

  /// The text value displayed as a title to this navigation bar.
  ///
  final String label;

  /// Whether to include a back button into the navigation bar display.
  ///
  final bool includeBackButton;

  /// Method invoked on back button press. Replaces the [_LvWidgetNavigationBarState] action implementation.
  ///
  final void Function()? onBackPressed;

  /// Additional button specifications for the navigation bar.
  ///
  final List<
      ({
        String label,
        IconData icon,
        void Function() onTap,
      })>? actions;

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
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (widget.actions != null)
              for (final action in widget.actions!)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilledButton.tonalIcon(
                    label: Text(action.label),
                    icon: Icon(action.icon),
                    onPressed: action.onTap,
                  ),
                ),
            if (widget.includeBackButton)
              if (MediaQuery.of(context).size.width < 1000)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: widget.onBackPressed ??
                      () {
                        Navigator.pop(context);
                      },
                )
              else
                FilledButton.tonalIcon(
                  label: const Text('CLOSE'),
                  icon: const Icon(Icons.close),
                  onPressed: widget.onBackPressed ??
                      () {
                        Navigator.pop(context);
                      },
                ),
          ],
        ),
      ),
    );
  }
}
