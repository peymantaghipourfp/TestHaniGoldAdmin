
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hanigold_admin/src/domain/inventory/controller/inventory_create_receive.controller.dart';
import 'package:hanigold_admin/src/domain/inventory/model/picked_inventory_image.model.dart';
import 'package:hanigold_admin/src/domain/inventory/utils/inventory_image_picker.dart';
import 'package:hanigold_admin/src/domain/inventory/widget/picked_image_thumbnail.widget.dart';
import 'package:uuid/uuid.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/const/app_color.dart';
import '../../../config/const/app_text_style.dart';
import '../../../config/logger/app_logger.dart';
import '../../../widget/hanigold_loading.widget.dart';
import '../model/inventory_detail.model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ItemTempDetailWidgetReceive extends StatefulWidget {
  final InventoryDetailModel detail;
  final Function(String, List<XFile>)? recId;
  final List<XFile> image;

  const ItemTempDetailWidgetReceive({
    super.key,
    required this.detail,
    this.recId,
    required this.image,
  });

  @override
  State<ItemTempDetailWidgetReceive> createState() =>
      _ItemTempDetailWidgetReceive();
}

class _ItemTempDetailWidgetReceive extends State<ItemTempDetailWidgetReceive> {
  InventoryCreateReceiveController inventoryCreateReceiveController =
  Get.find<InventoryCreateReceiveController>();
  final RxList<PickedInventoryImage> pickedImages =
      <PickedInventoryImage>[].obs;
  var recordId = ''.obs;
  var uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadExistingImages();
  }

  Future<void> _loadExistingImages() async {
    for (final file in widget.image) {
      final previewBytes = await file.readAsBytes();
      pickedImages.add(
        PickedInventoryImage(
          id: uuid.v4(),
          file: file,
          previewBytes: previewBytes,
        ),
      );
    }
    if (mounted) setState(() {});
  }

  Future<void> pickImageDesktop() async {
    recordId.value = uuid.v4();
    try {
      final images = await InventoryImagePicker.pickMultipleDesktop();
      if (images.isEmpty) return;
      pickedImages.addAll(images);
      pickedImages.refresh();
      widget.recId?.call(
        recordId.value,
        images.map((p) => p.file).toList(),
      );
      setState(() {});
    } catch (e) {
      throw Exception('خطا در انتخاب فایل‌ها');
    }
  }

  Future<void> pickImageMobile() async {
    recordId.value = uuid.v4();

    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return SafeArea(
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.secondary200Color,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Wrap(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: Icon(
                          Icons.camera_alt,
                          color: AppColor.textColor,
                        ),
                        title: Text(
                          'دوربین',
                          style: AppTextStyle.bodyText.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onTap: () =>
                            Navigator.pop(context, ImageSource.camera),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: Icon(
                          Icons.photo_library,
                          color: AppColor.textColor,
                        ),
                        title: Text(
                          'گالری',
                          style: AppTextStyle.bodyText.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onTap: () =>
                            Navigator.pop(context, ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      if (source == null) return;

      if (source == ImageSource.camera) {
        final photo = await InventoryImagePicker.pickFromCamera();
        if (photo == null) return;
        pickedImages.add(photo);
        pickedImages.refresh();
        widget.recId?.call(recordId.value, [photo.file]);
      } else if (source == ImageSource.gallery) {
        final images = await InventoryImagePicker.pickFromGallery();
        if (images.isEmpty) return;
        pickedImages.addAll(images);
        pickedImages.refresh();
        widget.recId?.call(
          recordId.value,
          images.map((p) => p.file).toList(),
        );
      }
      setState(() {});
    } catch (e, s) {
      AppLogger.e('pickImageMobile error:', e, s);
      Get.snackbar('خطا', 'امکان انتخاب تصویر وجود ندارد');
    }
  }

  void _removeImage(PickedInventoryImage image) {
    pickedImages.remove(image);
    widget.image.removeWhere((f) => f.path == image.file.path);
    pickedImages.refresh();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Card(
      color: AppColor.backGroundColor,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: isMobile ? 80 : 60,
          minWidth: isMobile ? double.infinity : 100,
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12.0 : 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isMobile
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.detail.item?.name ?? '',
                    style: AppTextStyle.bodyText.copyWith(
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'مقدار: ${widget.detail.quantity}',
                          style: AppTextStyle.bodyText.copyWith(
                            fontSize: isMobile ? 11 : 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          'وزن750: ${widget.detail.weight750}',
                          style: AppTextStyle.bodyText.copyWith(
                            fontSize: isMobile ? 11 : 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Text(
                      widget.detail.item?.name ?? '',
                      style: AppTextStyle.bodyText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'مقدار: ${widget.detail.quantity}',
                      style: AppTextStyle.bodyText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'وزن750: ${widget.detail.weight750}',
                      style: AppTextStyle.bodyText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: isMobile ? 0 : 35,
                  top: isMobile ? 8 : 10,
                ),
                child: Text(
                  'توضیحات: ${widget.detail.description}',
                  style: AppTextStyle.bodyText.copyWith(
                    fontSize: isMobile ? 11 : 12,
                  ),
                  maxLines: isMobile ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: isMobile ? 8 : 10),
              Container(
                padding: EdgeInsets.only(
                  bottom: 5,
                  right: isMobile ? 0 : 10,
                ),
                child: isMobile
                    ? Column(
                  children: [
                    Obx(() {
                      if (inventoryCreateReceiveController
                          .isUploadingDesktop.value) {
                        return Container(
                          width: double.infinity,
                          padding:
                          const EdgeInsets.symmetric(vertical: 8),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HaniGoldLoadingPage(
                                message: 'در حال بارگذاری تصویر...',
                              ),
                            ],
                          ),
                        );
                      }

                      return PickedImageThumbnailRow(
                        images: pickedImages,
                        onRemove: _removeImage,
                        onTap: (image) {
                          showPickedImageFullscreenDialog(
                            context,
                            previewBytes: image.previewBytes,
                          );
                        },
                      );
                    }),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => isMobile
                          ? pickImageMobile()
                          : pickImageDesktop(),
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          border:
                          Border.all(color: AppColor.iconViewColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/svg/camera.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                AppColor.iconViewColor,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'افزودن عکس',
                                style: AppTextStyle.labelText.copyWith(
                                  fontSize: 12,
                                  color: AppColor.iconViewColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Obx(() {
                        if (inventoryCreateReceiveController
                            .isUploadingDesktop.value) {
                          return const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HaniGoldLoadingPage(
                                message: 'در حال بارگذاری تصویر...',
                              ),
                            ],
                          );
                        }

                        return PickedImageThumbnailRow(
                          images: pickedImages,
                          onRemove: _removeImage,
                          onTap: (image) {
                            showPickedImageFullscreenDialog(
                              context,
                              previewBytes: image.previewBytes,
                            );
                          },
                        );
                      }),
                    ),
                    GestureDetector(
                      onTap: () => isMobile
                          ? pickImageMobile()
                          : pickImageDesktop(),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 80),
                        child: SvgPicture.asset(
                          'assets/svg/camera.svg',
                          width: 30,
                          height: 30,
                          colorFilter: ColorFilter.mode(
                            AppColor.iconViewColor,
                            BlendMode.srcIn,
                          ),
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
    );
  }
}
