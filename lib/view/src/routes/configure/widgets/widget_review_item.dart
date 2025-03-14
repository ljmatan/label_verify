part of '../route_configure.dart';

class _WidgetReviewItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                      future: document.getFileImageDisplays().then(
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

                        if (snapshot.hasError) {
                          return Center(
                            child: GsaWidgetError(
                              snapshot.error.toString(),
                            ),
                          );
                        }

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.memory(
                            reviewItem.imageDisplay!,
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
                        reviewItem.label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        reviewItem.type.displayName,
                        style: TextStyle(
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
                    child: Icon(Icons.close),
                    onPressed: () async {
                      final confirmed = await GsaWidgetOverlayConfirmation(
                        'Are you sure you want to remove "${reviewItem.label}"?',
                      ).openDialog(context);
                      if (confirmed) removeReviewItem();
                    },
                  ),
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
    );
  }
}
