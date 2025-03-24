import 'dart:async';

import 'package:flutter/material.dart';

/// Default project dialog builder widget.
///
class LvDialog extends StatefulWidget {
  /// Default widget constructor.
  ///
  const LvDialog({
    super.key,
    required this.children,
    this.title,
  });

  /// Collection of children widgets to be displayed within the dialog.
  ///
  final List<Widget> children;

  /// Label or a title applied to and displayed with this dialog.
  ///
  final String? title;

  @override
  State<LvDialog> createState() => _LvDialogState();
}

class _LvDialogState extends State<LvDialog> {
  final _scrollController = ScrollController();

  Timer? _errorMessageTimer;
  final _errorMessageController = StreamController<String?>.broadcast();

  void onError(String? message) {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.ease);
    _errorMessageTimer?.cancel();
    _errorMessageController.add(message);
    _errorMessageTimer = Timer(
      const Duration(seconds: 5),
      () => _errorMessageController.add(null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
        child: ConstrainedBox(
          constraints: MediaQuery.of(context).size.width < 1000
              ? BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom)
              : const BoxConstraints(maxWidth: 800),
          child: Material(
            color: MediaQuery.of(context).size.width < 1000 ? Colors.white : Colors.transparent,
            borderRadius: MediaQuery.of(context).size.width < 1000 ? null : BorderRadius.circular(10),
            child: SizedBox.expand(
              child: Stack(
                children: [
                  Center(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: (MediaQuery.of(context).size.width < 1000
                              ? const EdgeInsets.symmetric(horizontal: 20)
                              : const EdgeInsets.symmetric(horizontal: 40)),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MediaQuery.of(context).size.width < 1000 ? MainAxisSize.max : MainAxisSize.min,
                              mainAxisAlignment:
                                  MediaQuery.of(context).size.width < 1000 ? MainAxisAlignment.center : MainAxisAlignment.start,
                              children: [
                                if (widget.title != null) ...[
                                  const SizedBox(height: 30),
                                  Stack(
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: Text(
                                            widget.title!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                          ),
                                          iconSize: 18,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 32),
                                ],
                                StreamBuilder<String?>(
                                  stream: _errorMessageController.stream,
                                  builder: (context, message) {
                                    if (message.data == null) return const SizedBox();
                                    return Padding(
                                      padding: widget.title != null ? EdgeInsets.zero : const EdgeInsets.only(top: 30),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                        child: Text(
                                          message.data!,
                                          textAlign: TextAlign.justify,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (widget.title == null) const SizedBox(height: 20),
                                ...widget.children,
                                SizedBox(
                                  height: MediaQuery.of(context).viewInsets.bottom + (MediaQuery.of(context).size.width < 1000 ? 20 : 30),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        // Block Navigator.pop(context) events
                      },
                    ),
                  ),
                  if (MediaQuery.of(context).size.width < 1000)
                    Positioned(
                      top: 10 + MediaQuery.of(context).padding.top,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      onTap: MediaQuery.of(context).size.width < 1000 ? null : () => Navigator.pop(context),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _errorMessageTimer?.cancel();
    _errorMessageController.close();
    super.dispose();
  }
}
