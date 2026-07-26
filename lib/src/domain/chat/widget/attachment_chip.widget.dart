import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';
import 'package:hanigold_admin/src/domain/chat/controller/chat.controller.dart';
import 'package:hanigold_admin/src/domain/chat/utils/chat_attachment_utils.dart';
import 'package:hanigold_admin/src/domain/chat/widget/chat_dialog_internals.dart';

class AttachmentChip extends StatelessWidget {
  const AttachmentChip({
    super.key,
    required this.attachment,
    required this.isUploading,
    required this.onRemove,
    this.onEdit,
  });

  final ChatPendingAttachment attachment;
  final bool isUploading;
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;

  bool _isImageAttachment(ChatPendingAttachment attachment) =>
      attachment.fileType == 'image' &&
          attachment.bytes != null &&
          attachment.bytes!.isNotEmpty;

  bool _showEditButton(ChatPendingAttachment attachment) =>
      onEdit != null && _isImageAttachment(attachment);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final failed = attachment.failed.value;
      final progress = attachment.progress.value;
      final isImage = _isImageAttachment(attachment);
      final borderColor =
      failed ? Colors.red.withAlpha(200) : AppColor.textColor.withAlpha(50);

      return Container(
        margin: const EdgeInsets.only(left: 8),
        constraints: BoxConstraints(
          maxWidth: isImage ? 120 : 160,
        ),
        decoration: BoxDecoration(
          color: failed
              ? Colors.red.withAlpha(30)
              : AppColor.secondary50Color.withAlpha(180),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isImage)
              _ImageThumbnail(
                bytes: attachment.bytes!,
                showEdit: _showEditButton(attachment),
                onEdit: onEdit,
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, isImage ? 4 : 6, 4, 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isImage)
                    Icon(
                      kAttachmentTypeIcons[attachment.fileType] ??
                          Icons.insert_drive_file_outlined,
                      size: 16,
                      color: failed ? Colors.red : AppColor.buttonColor,
                    ),
                  if (!isImage) const SizedBox(width: 5),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          attachment.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.bodyText.copyWith(
                            fontSize: 11,
                            color: AppColor.textColor,
                          ),
                        ),
                        Text(
                          failed
                              ? 'آپلود ناموفق'
                              : formatAttachmentSize(attachment.sizeBytes),
                          style: AppTextStyle.bodyText.copyWith(
                            fontSize: 10,
                            color: failed
                                ? Colors.red
                                : AppColor.textColor.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: onRemove,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: onRemove != null
                            ? AppColor.textColor.withAlpha(170)
                            : AppColor.textColor.withAlpha(60),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isUploading && !failed && progress > 0 && progress < 1.0)
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(10)),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: AppColor.textColor.withAlpha(30),
                  valueColor:
                  AlwaysStoppedAnimation<Color>(AppColor.buttonColor),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _ImageThumbnail extends StatelessWidget {
  const _ImageThumbnail({
    required this.bytes,
    required this.showEdit,
    required this.onEdit,
  });

  final Uint8List bytes;
  final bool showEdit;
  final VoidCallback? onEdit;

  void _handleEdit() {
    if (onEdit == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    onEdit!();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onEdit == null ? null : _handleEdit,
                child: Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                  cacheWidth: 300,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: AppColor.secondary50Color,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: AppColor.textColor.withAlpha(120),
                    ),
                  ),
                ),
              ),
              if (showEdit)
                PositionedDirectional(
                  top: 0,
                  start: 0,
                  child: Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                    child: IconButton(
                      onPressed: onEdit == null ? null : _handleEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'ویرایش تصویر',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
