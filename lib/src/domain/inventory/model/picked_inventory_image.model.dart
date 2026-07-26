import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class PickedInventoryImage {
  PickedInventoryImage({
    required this.id,
    required this.file,
    required this.previewBytes,
  });

  final String id;
  final XFile file;
  final Uint8List previewBytes;
}
