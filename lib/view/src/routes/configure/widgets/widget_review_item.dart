part of '../route_configure.dart';

class _WidgetReviewItem extends StatefulWidget {
  const _WidgetReviewItem(
    this.reviewItem, {
    required this.document,
    required this.removeReviewItem,
  });

  /// Specified review item forwarded to this widget instance.
  ///
  final LvModelDocumentReviewConfiguration reviewItem;

  /// The document for which this review item is submitted.
  ///
  final LvModelDocument document;

  /// Method used to remove the specified review item from the list of such items.
  ///
  final void Function() removeReviewItem;

  @override
  State<_WidgetReviewItem> createState() => _WidgetReviewItemState();
}

class _WidgetReviewItemState extends State<_WidgetReviewItem> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
      color: Colors.white,
      margin: EdgeInsets.zero,
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
                          return widget.reviewItem.getImageDisplay(
                            originalImage: value[widget.reviewItem.page],
                          );
                        },
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(
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

                        LvServiceImages.instance.ocrScan(snapshot.data!).then(
                          (value) {
                            print(
                              value.map(
                                (element) => element.toJson(),
                              ),
                            );
                          },
                        );

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.memory(
                            widget.reviewItem.imageDisplay!,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        widget.reviewItem.type.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: TextButton(
                    child: const Icon(Icons.close),
                    onPressed: () async {
                      final confirmed = await GsaWidgetOverlayConfirmation(
                        'Are you sure you want to remove "${widget.reviewItem.label}"?',
                      ).openDialog(context);
                      if (confirmed) widget.removeReviewItem();
                    },
                  ),
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
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
