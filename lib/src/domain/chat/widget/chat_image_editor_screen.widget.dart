import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// Full-screen image editor for pending chat image attachments.
class ChatImageEditorScreen extends StatelessWidget {
  const ChatImageEditorScreen({
    super.key,
    required this.imageBytes,
    required this.onDone,
  });

  final Uint8List imageBytes;
  final Future<void> Function(Uint8List editedBytes) onDone;

  static const _editorConfigs = ProImageEditorConfigs(
    mainEditor: MainEditorConfigs(
      tools: [
        SubEditorMode.paint,
        SubEditorMode.text,
        SubEditorMode.cropRotate,
      ],
    ),
    paintEditor: PaintEditorConfigs(
      tools: [
        PaintMode.moveAndZoom,
        PaintMode.freeStyle,
        PaintMode.eraser,
        PaintMode.blur,
      ],
      showOpacityAdjustmentButton: true,
      initialPaintMode: PaintMode.freeStyle,

    ),
    cropRotateEditor: CropRotateEditorConfigs(
      tools: [
        CropRotateTool.rotate,
        CropRotateTool.flip,
        CropRotateTool.aspectRatio,
        CropRotateTool.reset,
      ],
      aspectRatios: [
        AspectRatioItem(text: 'Free', value: -1),
        AspectRatioItem(text: 'Original', value: 0.0),
        AspectRatioItem(text: '1:1', value: 1.0),
        AspectRatioItem(text: '4:3', value: 4.0 / 3.0),
        AspectRatioItem(text: '16:9', value: 16.0 / 9.0),
      ],
    ),
    imageGeneration: ImageGenerationConfigs(
      outputFormat: OutputFormat.jpg,
      jpegQuality: 92,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.memory(
      imageBytes,
      configs: _editorConfigs,
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (Uint8List bytes) async {
          await onDone(bytes);
        },
        onCloseEditor: (_) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
