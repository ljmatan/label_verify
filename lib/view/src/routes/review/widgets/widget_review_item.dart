part of '../route_review.dart';

class _WidgetReviewItem extends StatefulWidget {
  const _WidgetReviewItem(
    this.reviewItem, {
    required this.documentVisualContent,
    required this.comparisonDocumentVisualContent,
    required this.highlightedContours,
    required this.displayOnScreen,
  });

  /// The review item specified with this widget display.
  ///
  final LvModelDocumentReviewConfiguration reviewItem;

  /// Document specified within this review item configuration.
  ///
  final List<Uint8List> documentVisualContent, comparisonDocumentVisualContent;

  /// A collection of detected image differences.
  ///
  final List<List<LvModelDiffResult>> highlightedContours;

  /// Function implemented for displaying of the specified content on screen.
  ///
  final Function displayOnScreen;

  @override
  State<_WidgetReviewItem> createState() => __WidgetReviewItemState();
}

class __WidgetReviewItemState extends State<_WidgetReviewItem> with AutomaticKeepAliveClientMixin {
  late bool _zoneHighlighted;

  @override
  void initState() {
    super.initState();
    _zoneHighlighted = widget.highlightedContours[widget.reviewItem.page].any(
      (contour) {
        bool overlaps() {
          if (widget.reviewItem.positionEndPercentX < contour.positionStartPercentX ||
              widget.reviewItem.positionStartPercentX > contour.positionEndPercentX) {
            return false;
          }
          if (widget.reviewItem.positionEndPercentY < contour.positionStartPercentY ||
              widget.reviewItem.positionStartPercentY > contour.positionEndPercentY) {
            return false;
          }
          return true;
        }

        return overlaps() && widget.reviewItem.type != LvModelDocumentReviewConfigurationType.dynamicText;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
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
                    boxShadow: kElevationToShadow[1],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width,
                      maxHeight: 400,
                    ),
                    child: FutureBuilder(
                      future: widget.reviewItem.getImageDisplay(
                        originalImage: widget.comparisonDocumentVisualContent[widget.reviewItem.page],
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(
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

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.memory(
                            snapshot.data!,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Tooltip(
                    message: 'Higlight content',
                    child: ElevatedButton(
                      child: const Icon(Icons.visibility),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.reviewItem.label,
                        maxLines: 1,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        widget.reviewItem.type.displayName,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  child: const Icon(Icons.close),
                  onPressed: () {},
                ),
                const SizedBox(width: 6),
                FilledButton(
                  child: const Icon(Icons.check),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.reviewItem.description?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  widget.reviewItem.description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Card(
                margin: EdgeInsets.zero,
                color: _zoneHighlighted ? Colors.red : Colors.green,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    _zoneHighlighted ? 'A discrepancy has been detected. Please verify manually.' : 'All checks passed.',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
