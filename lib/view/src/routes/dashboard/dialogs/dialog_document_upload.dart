part of '../route_dashboard.dart';

class _DialogDocumentUpload extends StatefulWidget {
  const _DialogDocumentUpload();

  /// Overlays an instance of this widget to the screen,
  /// returning true if the user confirmed the document upload.
  ///
  static Future<bool> display([
    BuildContext? context,
  ]) async {
    return await showDialog<bool?>(
          context: context ?? LvApp.navigatorKey.currentContext!,
          builder: (context) {
            return const _DialogDocumentUpload();
          },
        ) ==
        true;
  }

  @override
  State<_DialogDocumentUpload> createState() => __DialogDocumentUploadState();
}

class __DialogDocumentUploadState extends State<_DialogDocumentUpload> {
  /// Whether the label input mode is currently active.
  ///
  ({
    Uint8List fileBytes,
    String fileName,
    LvServiceFilesExtensionTypes fileType,
    int pagesNumber,
  })? _mediaFile;

  /// Key used for verifying document label text input.
  ///
  final _formKey = GlobalKey<FormState>();

  /// Text editing controller used for the purposes of entering document label details.
  ///
  final _labelTextController = TextEditingController();

  /// If a document is selected from the existing document list, the ID will be recorded to this property.
  ///
  int? _selectedFileId;

  @override
  Widget build(BuildContext context) {
    return LvDialog(
      title: 'Document Upload',
      children: _mediaFile != null
          ? [
              Text(
                'Enter the document label in below input field before proceeding:',
              ),
              const SizedBox(height: 14),
              Form(
                key: _formKey,
                child: GsaWidgetTextField(
                  controller: _labelTextController,
                  labelText: 'File Label',
                  validator: (value) {
                    if ((value?.length ?? 0) < 3) return 'Label must be at least 3 characters long.';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                label: Text('Confirm'),
                onPressed: () async {
                  if (_formKey.currentState?.validate() == true) {
                    LvDialogContentBlocking.display();
                    try {
                      final storedFile = await LvServiceFiles.instance.storeFile(
                        fileBytes: _mediaFile!.fileBytes,
                        fileType: _mediaFile!.fileType,
                      );
                      final document = LvModelDocument(
                        id: -1,
                        categoryId: null,
                        label: _labelTextController.text.trim(),
                        fileName: _mediaFile!.fileName,
                        fileType: _mediaFile!.fileType.name,
                        filePath: storedFile.filePath,
                        fileImageDisplayPaths: storedFile.fileImageDisplayPaths,
                        createdAt: DateTime.now(),
                        lastUpdated: null,
                      );
                      final documentId = await LvServiceDatabase.instance.insertDocument(document);
                      document.id = documentId;
                      LvDataDocuments.instance.documentAdd([document]);
                      Navigator.popUntil(context, (route) => route.isFirst);
                    } catch (e) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      GsaWidgetOverlayAlert(
                        title: 'Error',
                        message: '$e',
                      ).openDialog(context);
                    }
                  }
                },
              ),
            ]
          : [
              Text(
                'Document files are transferred to the server for processing, '
                'either by creating new document entries, or by updating existing ones with new revisions.\n\n'
                'To upload a new document, you can:',
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                label: Text('Select a File'),
                icon: Icon(Icons.upload),
                onPressed: () async {
                  final mediaFile = await LvServiceFiles.instance.getFile(
                    LvServiceFilesType.document,
                  );
                  if (mediaFile == null) return;
                  setState(() => _mediaFile = mediaFile);
                },
              ),
              if (LvDataDocuments.instance.collection.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Or you can select from the existing documents to update with the latest content:',
                ),
                const SizedBox(height: 14),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Row(
                      children: [
                        Expanded(
                          child: DropdownMenu(
                            dropdownMenuEntries: [
                              for (final document in LvDataDocuments.instance.collection)
                                DropdownMenuEntry(
                                  value: document.id,
                                  label: document.fileName,
                                ),
                            ],
                            enableFilter: true,
                            expandedInsets: EdgeInsets.zero,
                            onSelected: (value) {
                              setState(() => _selectedFileId = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          child: Text('CONFIRM'),
                          onPressed: _selectedFileId != null
                              ? () async {
                                  Navigator.pop(context);
                                }
                              : null,
                        ),
                      ],
                    );
                  },
                ),
              ],
              const SizedBox(height: 14),
              Text(
                'After uploading the document, review parameters can be configured through the "CONFIGURE" menu.',
              ),
            ],
    );
  }

  @override
  void dispose() {
    _labelTextController.dispose();
    super.dispose();
  }
}
