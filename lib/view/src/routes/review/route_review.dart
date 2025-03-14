import 'package:flutter/material.dart';
import 'package:generic_shop_app_content/gsac.dart';
import 'package:label_verify/models/models.dart';
import 'package:label_verify/services/services.dart';
import 'package:label_verify/view/src/common/widgets/widget_media_review_selection.dart';
import 'package:label_verify/view/src/common/widgets/widget_navigation_bar.dart';

/// Route for establishing the process of reviewing the media content.
///
class LvRouteReview extends StatefulWidget {
  /// Default widget constructor.
  ///
  const LvRouteReview({
    super.key,
    required this.document,
    required this.comparisonDocument,
  });

  /// Media content used for review and comparison of submitted changes.
  ///
  final LvModelDocument document;

  /// Media content used for review and comparison of submitted changes.
  ///
  final LvModelDocumentRevision comparisonDocument;

  @override
  State<LvRouteReview> createState() => _LvRouteReviewState();
}

class _LvRouteReviewState extends State<LvRouteReview> {
  /// Notifier implemented to track the view tab selection.
  ///
  final _selectedTabNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          LvWidgetNavigationBar(
            label: 'Review',
          ),
          Expanded(
            child: FutureBuilder(
              future: LvServiceDatabase.instance.getDocumentReviewConfigurationsForId(
                widget.document.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(
                    child: const CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: GsaWidgetError(
                      snapshot.error?.toString() ?? 'No revision configuration found.',
                    ),
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: LvWidgetMediaReviewSelection(
                        contentDocument: widget.document,
                        comparisonDocument: widget.comparisonDocument,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Ink(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          widget.document.label.toUpperCase(),
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w300,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.end,
                                      alignment: WrapAlignment.end,
                                      children: [
                                        for (final button in <({
                                          String label,
                                          int length,
                                        })>{
                                          (
                                            label: 'CHECKLIST',
                                            length: 0,
                                          ),
                                          (
                                            label: 'RESOLVED',
                                            length: 0,
                                          ),
                                          (
                                            label: 'ERRORS',
                                            length: 0,
                                          ),
                                        }.indexed)
                                          Padding(
                                            padding: button.$1 == 0 ? EdgeInsets.zero : const EdgeInsets.only(left: 8),
                                            child: ValueListenableBuilder<int>(
                                              valueListenable: _selectedTabNotifier,
                                              builder: (context, value, child) {
                                                return TextButton(
                                                  child: Text(
                                                    '${button.$2.label} (${button.$2.length})',
                                                    style: TextStyle(
                                                      color: button.$1 == value ? Colors.white : Colors.grey.shade200,
                                                      fontWeight: button.$1 == value ? FontWeight.w900 : null,
                                                      decoration: button.$1 == value ? TextDecoration.underline : null,
                                                      decorationColor: Colors.white,
                                                    ),
                                                  ),
                                                  onPressed: button.$1 == value
                                                      ? null
                                                      : () {
                                                          _selectedTabNotifier.value = button.$1;
                                                        },
                                                );
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ValueListenableBuilder(
                              valueListenable: _selectedTabNotifier,
                              builder: (context, value, child) {
                                return ListView(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                  children: [
                                    for (final reviewItem in snapshot.data!)
                                      Card(
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade200,
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                      ),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        minWidth: MediaQuery.of(context).size.width,
                                                        maxHeight: 400,
                                                      ),
                                                      child: FutureBuilder(
                                                        future: widget.document.getFileImageDisplays().then(
                                                          (value) {
                                                            return reviewItem.getImageDisplay(
                                                              originalImage: value[reviewItem.page],
                                                            );
                                                          },
                                                        ),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.connectionState != ConnectionState.done) {
                                                            return Center(
                                                              child: CircularProgressIndicator(),
                                                            );
                                                          }

                                                          if (snapshot.hasError || snapshot.data?.isNotEmpty != true) {
                                                            return Center(
                                                              child: GsaWidgetError(
                                                                snapshot.error?.toString() ?? 'No data found.',
                                                              ),
                                                            );
                                                          }

                                                          return Image.memory(
                                                            snapshot.data!,
                                                            width: MediaQuery.of(context).size.width,
                                                            fit: BoxFit.contain,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 10,
                                                    right: 10,
                                                    child: ElevatedButton(
                                                      child: Icon(Icons.zoom_in),
                                                      onPressed: () {},
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      reviewItem.label,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    child: Icon(Icons.close),
                                                    onPressed: () {},
                                                  ),
                                                  const SizedBox(width: 6),
                                                  FilledButton(
                                                    child: Icon(Icons.check),
                                                    onPressed: () {},
                                                  ),
                                                ],
                                              ),
                                              if (reviewItem.description != null)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text(
                                                    reviewItem.description!,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey.shade800,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _selectedTabNotifier.dispose();
    super.dispose();
  }
}
