import 'package:flutter/material.dart';
import 'package:generic_shop_app_content/gsac.dart';
import 'package:label_verify/models/models.dart';
import 'package:label_verify/services/services.dart';
import 'package:label_verify/view/src/common/dialogs/dialog_content_blocking.dart';
import 'package:label_verify/view/src/common/widgets/widget_media_review_selection.dart';
import 'package:label_verify/view/src/common/widgets/widget_navigation_bar.dart';

part 'widgets/widget_animated_drag_showcase.dart';
part 'widgets/widget_review_item.dart';

/// Route for establishing the process of reviewing the media content.
///
class LvRouteConfigure extends StatefulWidget {
  /// Default widget constructor.
  ///
  const LvRouteConfigure({
    super.key,
    required this.document,
  });

  /// The media content value forwarded to this widget.
  ///
  final LvModelDocument document;

  @override
  State<LvRouteConfigure> createState() => _LvRouteConfigureState();
}

class _LvRouteConfigureState extends State<LvRouteConfigure> {
  final _reviewItems = <LvModelDocumentReviewConfiguration>[];

  late Future<void> _getReviewItems;

  @override
  void initState() {
    super.initState();
    _getReviewItems = LvServiceDatabase.instance
        .getDocumentReviewConfigurationsForId(
      widget.document.id,
    )
        .then(
      (value) {
        _reviewItems.addAll(value);
      },
    );
  }

  /// Method invoked on successful addition of a review item.
  ///
  void _addReviewItem(LvModelDocumentReviewConfiguration value) {
    _reviewItems.add(value);
    setState(() {});
  }

  /// Used to remove a previously-added review item.
  ///
  void _removeReviewItem(LvModelDocumentReviewConfiguration value) {
    _reviewItems.remove(value);
    setState(() {});
  }

  /// Value determining whether any review items have been submitted by the user.
  ///
  bool get _reviewItemsSubmitted {
    return _reviewItems.isNotEmpty == true;
  }

  /// Store the current changes as a database record.
  ///
  Future<void> _saveChanges() async {
    LvDialogContentBlocking.display();
    try {
      for (final reviewItem in _reviewItems) {
        if (reviewItem.id == -1) {
          final reviewItemId = await LvServiceDatabase.instance.insertDocumentReviewConfiguration(reviewItem);
          reviewItem.id = reviewItemId;
        }
      }
      Navigator.pop(context);
      GsaWidgetOverlayAlert(
        title: 'Success',
        message: 'Changes saved successfully.',
      ).openDialog(context);
    } catch (e) {
      Navigator.pop(context);
      GsaWidgetOverlayAlert(
        title: 'Error',
        message: '$e',
      ).openDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          LvWidgetNavigationBar(
            label: 'Configure',
          ),
          Expanded(
            child: FutureBuilder(
              future: _getReviewItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: GsaWidgetError(
                      snapshot.error.toString(),
                    ),
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: kElevationToShadow[2],
                        ),
                        child: LvWidgetMediaReviewSelection(
                          contentDocument: widget.document,
                          addReviewItem: (value) => _addReviewItem(value),
                        ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          if (_reviewItemsSubmitted)
                                            Tooltip(
                                              message: 'Confirm all of the current changes without exiting the screen.',
                                              child: FilledButton.icon(
                                                label: Text('PUBLISH'),
                                                icon: Icon(Icons.save),
                                                onPressed: () async {
                                                  await _saveChanges();
                                                },
                                              ),
                                            ),
                                          Expanded(
                                            child: Text(
                                              widget.document.fileName.toUpperCase(),
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              children: [
                                if (!_reviewItemsSubmitted) ...[
                                  Text(
                                    'To start adding parameters, simply click and drag across any media section you want to track. '
                                    'This specific selection is later used when reviewing future document changes.\n\n'
                                    'You can adjust the image view by zooming and panning using the button controls provided on the screen.',
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: _WidgetAnimatedDragShowcase(
                                      widget.document,
                                    ),
                                  ),
                                ] else
                                  for (final reviewItem in _reviewItems)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _WidgetReviewItem(
                                        reviewItem,
                                        document: widget.document,
                                        removeReviewItem: () {
                                          _removeReviewItem(reviewItem);
                                        },
                                      ),
                                    ),
                              ],
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
}
