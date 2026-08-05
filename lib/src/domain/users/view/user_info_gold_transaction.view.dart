import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_info_detail_gold_transaction.controller.dart';
import 'package:hanigold_admin/src/domain/users/widgets/balance_user.widget.dart';
import 'package:hanigold_admin/src/utils/num_display.dart';
import 'package:hanigold_admin/src/widget/custom_appbar1.widget.dart';
import 'package:hanigold_admin/src/widget/hanigold_loading.widget.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../config/const/app_color.dart';
import '../../../config/const/app_text_style.dart';
import '../../../widget/app_drawer.widget.dart';
import '../../../widget/background_image_total.widget.dart';
import '../../../widget/chat_floating_button.widget.dart';
import '../../../widget/err_page.dart';
import '../../../widget/pager_widget.dart';
import '../widgets/gold_transaction_filter.widget.dart';
import '../widgets/tabel_info.widget.dart';

import 'package:flutter/services.dart';

class UserInfoGoldTransactionView extends StatefulWidget {
  const UserInfoGoldTransactionView({super.key});

  @override
  State<UserInfoGoldTransactionView> createState() => _UserInfoGoldTransactionViewState();
}

class _UserInfoGoldTransactionViewState extends State<UserInfoGoldTransactionView> {
  final UserInfoDetailGoldTransactionController controller = Get.find<UserInfoDetailGoldTransactionController>();
  final GlobalKey _balanceKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    return Obx(() => Scaffold(
          appBar: CustomAppbar1(
            title: 'جزییات تراکنش کاربر طلا',
            //onBackTap: () => Get.offNamed("/listUserInfoGoldTransaction"),
            onBackTap: () => Get.back(),
          ),
          drawer: const AppDrawer(),
          body: Stack(
            children: [
              BackgroundImageTotal(),
              SafeArea(
                child: controller.state.value == PageStateDe.loading
                    ? Center(
                        child: HaniGoldLoading.large(),
                      )
                    : controller.state.value == PageStateDe.list
                        ? SizedBox(
                            height: Get.height,
                            width: Get.width,
                            child: SingleChildScrollView(
                              controller: isDesktop ? null : controller.scrollControllerMobile,
                              child: Column(
                                children: [
                                  isDesktop
                                      ? Container(
                                          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: AppColor.backGroundColor1.withAlpha(150)),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Row(mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            ' حساب کاربری ${controller.headerInfoUserTransactionModel?.accountName ?? ""}',
                                                            style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 14 : 13),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10, width: 10,),
                                                  Row(
                                                    children: [
                                                      // خروجی اکسل
                                                      OutlinedButton.icon(
                                                        onPressed: () {
                                                          showGeneralDialog(
                                                              context: context,
                                                              barrierDismissible: true,
                                                              barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                                                              barrierColor: Colors.black45,
                                                              transitionDuration: const Duration(milliseconds: 200),
                                                              pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                                                                return Center(
                                                                  child: Material(
                                                                    color: Colors.transparent,
                                                                    child: Container(
                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColor.backGroundColor),
                                                                      width: isDesktop ? Get.width * 0.2 : Get.height * 0.5,
                                                                      height: isDesktop ? Get.height * 0.5 : Get.height * 0.7,
                                                                      padding: EdgeInsets.all(20),
                                                                      child: Column(
                                                                        children: [
                                                                          Padding(
                                                                            padding: const EdgeInsets.all(8.0),
                                                                            child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text('خروجی اکسل', style: AppTextStyle.labelText.copyWith(fontSize: 15, fontWeight: FontWeight.normal,),),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Container(color: AppColor.textColor, height: 0.2,),
                                                                          Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                            child: Column(
                                                                              children: [
                                                                                SizedBox(height: 8),
                                                                                Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      'از تاریخ',
                                                                                      style: AppTextStyle.labelText.copyWith(fontSize: 13, fontWeight: FontWeight.normal, color: AppColor.textColor),
                                                                                    ),
                                                                                    Container(
                                                                                      //height: 50,
                                                                                      padding: EdgeInsets.only(bottom: 5),
                                                                                      child: IntrinsicHeight(
                                                                                        child: TextFormField(
                                                                                          validator: (value) {
                                                                                            if (value == null || value.isEmpty) {
                                                                                              return 'لطفا تاریخ را انتخاب کنید';
                                                                                            }
                                                                                            return null;
                                                                                          },
                                                                                          controller: controller.dateStartController,
                                                                                          readOnly: true,
                                                                                          style: AppTextStyle.labelText,
                                                                                          decoration: InputDecoration(
                                                                                            suffixIcon: Icon(Icons.calendar_month, color: AppColor.textColor),
                                                                                            border: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(10),
                                                                                            ),
                                                                                            filled: true,
                                                                                            fillColor: AppColor.textFieldColor,
                                                                                            errorMaxLines: 1,
                                                                                          ),
                                                                                          onTap: () async {
                                                                                            Jalali? pickedDate = await showPersianDatePicker(
                                                                                              context: context,
                                                                                              initialDate: Jalali.now(),
                                                                                              firstDate: Jalali(1400, 1, 1),
                                                                                              lastDate: Jalali(1450, 12, 29),
                                                                                              initialEntryMode: PersianDatePickerEntryMode.calendar,
                                                                                              initialDatePickerMode: PersianDatePickerMode.day,
                                                                                              locale: Locale("fa", "IR"),
                                                                                            );
                                                                                            if (pickedDate != null) {
                                                                                              Gregorian gregorian = pickedDate.toGregorian();
                                                                                              controller.startDateFilter.value =
                                                                                              "${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(
                                                                                                  2, '0')}";

                                                                                              controller.dateStartController.text =
                                                                                              "${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(
                                                                                                  2, '0')}";
                                                                                            }
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                SizedBox(height: 8),
                                                                                Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      'تا تاریخ',
                                                                                      style: AppTextStyle.labelText.copyWith(fontSize: 13, fontWeight: FontWeight.normal, color: AppColor.textColor),
                                                                                    ),
                                                                                    Container(
                                                                                      //height: 50,
                                                                                      padding: EdgeInsets.only(bottom: 5),
                                                                                      child: IntrinsicHeight(
                                                                                        child: TextFormField(
                                                                                          validator: (value) {
                                                                                            if (value == null || value.isEmpty) {
                                                                                              return 'لطفا تاریخ را انتخاب کنید';
                                                                                            }
                                                                                            return null;
                                                                                          },
                                                                                          controller: controller.dateEndController,
                                                                                          readOnly: true,
                                                                                          style: AppTextStyle.labelText,
                                                                                          decoration: InputDecoration(
                                                                                            suffixIcon: Icon(Icons.calendar_month, color: AppColor.textColor),
                                                                                            border: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(10),
                                                                                            ),
                                                                                            filled: true,
                                                                                            fillColor: AppColor.textFieldColor,
                                                                                            errorMaxLines: 1,
                                                                                          ),
                                                                                          onTap: () async {
                                                                                            Jalali? pickedDate = await showPersianDatePicker(
                                                                                              context: context,
                                                                                              initialDate: Jalali.now(),
                                                                                              firstDate: Jalali(1400, 1, 1),
                                                                                              lastDate: Jalali(1450, 12, 29),
                                                                                              initialEntryMode: PersianDatePickerEntryMode.calendar,
                                                                                              initialDatePickerMode: PersianDatePickerMode.day,
                                                                                              locale: Locale("fa", "IR"),
                                                                                            );
                                                                                            // DateTime date=DateTime.now();
                                                                                            if (pickedDate != null) {
                                                                                              Gregorian gregorian = pickedDate.toGregorian();
                                                                                              controller.endDateFilter.value =
                                                                                              "${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(
                                                                                                  2, '0')}";

                                                                                              controller.dateEndController.text =
                                                                                              "${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(
                                                                                                  2, '0')}";
                                                                                            }
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Spacer(),
                                                                          Container(margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                            width: double.infinity,
                                                                            height: 40,
                                                                            child: ElevatedButton(
                                                                              style: ButtonStyle(
                                                                                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                                                                                    horizontal: 23,
                                                                                  )),
                                                                                  // elevation: WidgetStatePropertyAll(5),
                                                                                  backgroundColor: WidgetStatePropertyAll(AppColor.appBarColor),
                                                                                  shape: WidgetStatePropertyAll(
                                                                                      RoundedRectangleBorder(side: BorderSide(color: AppColor.textColor), borderRadius: BorderRadius.circular(5)))),
                                                                              onPressed: () async {
                                                                                controller.getGoldExcel();
                                                                                Get.back();
                                                                              },
                                                                              child: controller.isLoading.value
                                                                                  ? CircularProgressIndicator(
                                                                                      valueColor: AlwaysStoppedAnimation<Color>(AppColor.textColor),
                                                                                    )
                                                                                  : Text(
                                                                                      'ثبت',
                                                                                      style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10),
                                                                                    ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              });
                                                        },
                                                        label: Text('خروجی اکسل', style: AppTextStyle.labelText.copyWith(color: AppColor.primaryColor, fontSize: 12),),
                                                        icon: SvgPicture.asset('assets/svg/excel.svg', height: 24,),
                                                      ),
                                                      SizedBox(width: 5,),
                                                      // خروجی pdf
                                                      OutlinedButton.icon(
                                                        onPressed: () {
                                                          showGeneralDialog(
                                                              context: context,
                                                              barrierDismissible: true,
                                                              barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                                                              barrierColor: Colors.black45,
                                                              transitionDuration: const Duration(milliseconds: 200),
                                                              pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                                                                return Center(
                                                                  child: Material(
                                                                    color: Colors.transparent,
                                                                    child: Container(
                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColor.backGroundColor),
                                                                      width: isDesktop ? Get.width * 0.2 : Get.height * 0.5,
                                                                      height: isDesktop ? Get.height * 0.5 : Get.height * 0.7,
                                                                      padding: EdgeInsets.all(20),
                                                                      child: Column(
                                                                        children: [
                                                                          Padding(padding: const EdgeInsets.all(8.0),
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  'خروجی pdf',
                                                                                  style: AppTextStyle.labelText.copyWith(
                                                                                    fontSize: 15,
                                                                                    fontWeight: FontWeight.normal,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Container(color: AppColor.textColor, height: 0.2,),
                                                                          Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                            child: Column(
                                                                              children: [
                                                                                SizedBox(height: 8),
                                                                                Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      'از تاریخ',
                                                                                      style: AppTextStyle.labelText.copyWith(fontSize: 13, fontWeight: FontWeight.normal, color: AppColor.textColor),
                                                                                    ),
                                                                                    Container(
                                                                                      //height: 50,
                                                                                      padding: EdgeInsets.only(bottom: 5),
                                                                                      child: IntrinsicHeight(
                                                                                        child: TextFormField(
                                                                                          validator: (value) {
                                                                                            if (value == null || value.isEmpty) {
                                                                                              return 'لطفا تاریخ را انتخاب کنید';
                                                                                            }
                                                                                            return null;
                                                                                          },
                                                                                          controller: controller.dateStartController,
                                                                                          readOnly: true,
                                                                                          style: AppTextStyle.labelText,
                                                                                          decoration: InputDecoration(
                                                                                            suffixIcon: Icon(Icons.calendar_month, color: AppColor.textColor),
                                                                                            border: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(10),
                                                                                            ),
                                                                                            filled: true,
                                                                                            fillColor: AppColor.textFieldColor,
                                                                                            errorMaxLines: 1,
                                                                                          ),
                                                                                          onTap: () async {
                                                                                            Jalali? pickedDate = await showPersianDatePicker(
                                                                                              context: context,
                                                                                              initialDate: Jalali.now(),
                                                                                              firstDate: Jalali(1400, 1, 1),
                                                                                              lastDate: Jalali(1450, 12, 29),
                                                                                              initialEntryMode: PersianDatePickerEntryMode.calendar,
                                                                                              initialDatePickerMode: PersianDatePickerMode.day,
                                                                                              locale: Locale("fa", "IR"),
                                                                                            );
                                                                                            if (pickedDate != null) {
                                                                                              Gregorian gregorian = pickedDate.toGregorian();
                                                                                              controller.startDateFilter.value =
                                                                                              "${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(
                                                                                                  2, '0')}";

                                                                                              controller.dateStartController.text =
                                                                                              "${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(
                                                                                                  2, '0')}";
                                                                                            }
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                SizedBox(height: 8),
                                                                                Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      'تا تاریخ',
                                                                                      style: AppTextStyle.labelText.copyWith(fontSize: 13, fontWeight: FontWeight.normal, color: AppColor.textColor),
                                                                                    ),
                                                                                    Container(
                                                                                      //height: 50,
                                                                                      padding: EdgeInsets.only(bottom: 5),
                                                                                      child: IntrinsicHeight(
                                                                                        child: TextFormField(
                                                                                          validator: (value) {
                                                                                            if (value == null || value.isEmpty) {
                                                                                              return 'لطفا تاریخ را انتخاب کنید';
                                                                                            }
                                                                                            return null;
                                                                                          },
                                                                                          controller: controller.dateEndController,
                                                                                          readOnly: true,
                                                                                          style: AppTextStyle.labelText,
                                                                                          decoration: InputDecoration(
                                                                                            suffixIcon: Icon(Icons.calendar_month, color: AppColor.textColor),
                                                                                            border: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(10),
                                                                                            ),
                                                                                            filled: true,
                                                                                            fillColor: AppColor.textFieldColor,
                                                                                            errorMaxLines: 1,
                                                                                          ),
                                                                                          onTap: () async {
                                                                                            Jalali? pickedDate = await showPersianDatePicker(
                                                                                              context: context,
                                                                                              initialDate: Jalali.now(),
                                                                                              firstDate: Jalali(1400, 1, 1),
                                                                                              lastDate: Jalali(1450, 12, 29),
                                                                                              initialEntryMode: PersianDatePickerEntryMode.calendar,
                                                                                              initialDatePickerMode: PersianDatePickerMode.day,
                                                                                              locale: Locale("fa", "IR"),
                                                                                            );
                                                                                            // DateTime date=DateTime.now();
                                                                                            if (pickedDate != null) {
                                                                                              Gregorian gregorian = pickedDate.toGregorian();
                                                                                              controller.endDateFilter.value =
                                                                                              "${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(
                                                                                                  2, '0')}";

                                                                                              controller.dateEndController.text =
                                                                                              "${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(
                                                                                                  2, '0')}";
                                                                                            }
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Spacer(),
                                                                          Container(margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                            width: double.infinity,
                                                                            height: 40,
                                                                            child: ElevatedButton(
                                                                              style: ButtonStyle(
                                                                                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 23)),
                                                                                  // elevation: WidgetStatePropertyAll(5),
                                                                                  backgroundColor: WidgetStatePropertyAll(AppColor.appBarColor),
                                                                                  shape: WidgetStatePropertyAll(
                                                                                      RoundedRectangleBorder(side: BorderSide(color: AppColor.textColor), borderRadius: BorderRadius.circular(5)))),
                                                                              onPressed: () async {
                                                                                controller.exportGetGoldPdf(controller.id.value.toString());
                                                                                Get.back();
                                                                              },
                                                                              child: controller.isLoading.value
                                                                                  ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColor.textColor),)
                                                                                  : Text(
                                                                                      'ثبت',
                                                                                      style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10),
                                                                                    ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              });
                                                        },
                                                        label: Text('خروجی pdf', style: AppTextStyle.labelText.copyWith(color: AppColor.textAccentColor, fontSize: 12),),
                                                        icon: SvgPicture.asset('assets/svg/pdf.svg', height: 24,),
                                                      ),
                                                      SizedBox(width: 5,),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Container(margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                                height: 0.8,
                                                width: Get.width,
                                                color: AppColor.textColor,
                                              ),
                                              Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 40,
                                                        backgroundColor: AppColor.textFieldColor,
                                                        backgroundImage: AssetImage("assets/images/boy.png"),
                                                      ),
                                                      Container(
                                                        // width: 300,
                                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                      child: Text(
                                                                        'نام : ',
                                                                        style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10, fontWeight: FontWeight.normal),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(height: 5,),
                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                      child: Text(
                                                                        'شماره : ',
                                                                        style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(height: 5,),
                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                      child: Text('نقش : ', style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10),),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(height: 5,),
                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                      child: Text(
                                                                        'تاریخ عضویت : ',
                                                                        style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(height: 5,),
                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                      child: Text('بیعانه : ', style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10),),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(height: 5,),
                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                      child: Text('آدرس : ', style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10),),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: AppColor.textColor),
                                                                      child: Text(
                                                                        controller.headerInfoUserTransactionModel?.accountName ?? "",
                                                                        style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10, color: AppColor.backGroundColor),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(height: 5,),
                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: AppColor.textColor),
                                                                      child: Text(
                                                                        controller.headerInfoUserTransactionModel?.tell ?? "",
                                                                        style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10, color: AppColor.backGroundColor),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(height: 5,),
                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: AppColor.textColor),
                                                                      child: Text(
                                                                        controller.headerInfoUserTransactionModel?.accountGroup ?? "",
                                                                        style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10, color: AppColor.backGroundColor),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(height: 5,),
                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: AppColor.textColor),
                                                                      child: Text(
                                                                        controller.headerInfoUserTransactionModel?.startDate?.toPersianDate().toString() ?? "",
                                                                        style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10, color: AppColor.backGroundColor),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(height: 5,),
                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: AppColor.textColor),
                                                                      child: Text(
                                                                        controller.headerInfoUserTransactionModel?.deposit ?? "",
                                                                        style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10, color: AppColor.accentColor),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(height: 5,),
                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: AppColor.textColor),
                                                                      child: Text(
                                                                        controller.headerInfoUserTransactionModel?.address ?? "",
                                                                        style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10, color: AppColor.backGroundColor),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          IconButton(
                                                            icon: SvgPicture.asset(
                                                              'assets/svg/camera.svg',
                                                              height: 24,
                                                              colorFilter: ColorFilter.mode(AppColor.iconViewColor, BlendMode.srcIn),
                                                            ),
                                                            tooltip: 'گرفتن اسکرین شات',
                                                            onPressed: () => controller.captureBalanceScreenshot(context, _balanceKey),
                                                          ),
                                                          SizedBox(height: 5,),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              await controller.checkAccountSocialStatus();
                                                              if (controller.socialStatus.value != null) {
                                                                Get.defaultDialog(
                                                                  backgroundColor: AppColor.backGroundColor,
                                                                  title: "ارسال مانده حساب",
                                                                  titleStyle: AppTextStyle.smallTitleText.copyWith(color: Color(0xff0ab6f0)),
                                                                  middleText: "آیا از ارسال مانده حساب مطمئن هستید؟",
                                                                  middleTextStyle: AppTextStyle.bodyText,
                                                                  confirm: Obx(() {
                                                                    final status = controller.socialStatus.value;
                                                                    final hasTelegram = status?.telegramStatus == true;
                                                                    final hasWhatsApp = status?.whatsappStatus == true;

                                                                    if (!hasTelegram && !hasWhatsApp) {
                                                                      return Padding(
                                                                        padding: const EdgeInsets.all(16.0),
                                                                        child: Text(
                                                                          'هیچ کانال ارتباطی فعال نیست',
                                                                          style: AppTextStyle.bodyText.copyWith(
                                                                            color: AppColor.errorColor,
                                                                            fontSize: 13,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }

                                                                    return Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                      children: [
                                                                        if (hasTelegram)
                                                                          GestureDetector(
                                                                            onTap: () async {
                                                                              Get.back();
                                                                              await controller.sendBalanceToTelegram();
                                                                            },
                                                                            child: SvgPicture.asset(
                                                                              'assets/svg/telegram.svg',
                                                                              height: 24,
                                                                              colorFilter: ColorFilter.mode(Color(0xff0ab6f0), BlendMode.srcIn),
                                                                            ),
                                                                          ),
                                                                        if (hasWhatsApp)
                                                                          GestureDetector(
                                                                            onTap: () {
                                                                              // TODO: Implement WhatsApp send logic
                                                                              Get.back();
                                                                            },
                                                                            child: SvgPicture.asset('assets/svg/whatsapp.svg', height: 24,),
                                                                          ),
                                                                      ],
                                                                    );
                                                                  }),
                                                                );
                                                              }
                                                            },
                                                            child: Tooltip(
                                                              message: "ارسال مانده حساب",
                                                              child: SvgPicture.asset(
                                                                'assets/svg/send.svg',
                                                                height: 22,
                                                                colorFilter: ColorFilter.mode(AppColor.secondary3Color, BlendMode.srcIn),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        width: Get.width * 0.3,
                                                        child: RepaintBoundary(
                                                          key: _balanceKey,
                                                          child: BalanceUserWidget(
                                                            title: "${controller.headerInfoUserTransactionModel?.accountName} ${Jalali.now().year}/${Jalali.now().month.toString().padLeft(2, '0')}/${Jalali.now().day.toString().padLeft(2, '0')}",
                                                            listBalance: controller.balanceList,
                                                            size: Get.width * 0.4,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 20,),
                                              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  TabelInfoWidget(
                                                    list: controller.headerInfoUserTransactionModel?.inventorys ?? [],
                                                    title: 'دریافت و پرداخت',
                                                    title1: 'دریافت',
                                                    title2: 'پرداخت',
                                                    typeSel1: 'receive',
                                                    typeSel2: 'payment',
                                                  ),
                                                  SizedBox(width: 30,),
                                                  TabelInfoWidget(
                                                    list: controller.headerInfoUserTransactionModel?.orders ?? [],
                                                    title: 'خرید و فروش',
                                                    title1: 'خرید',
                                                    title2: 'فروش',
                                                    typeSel1: 'buy',
                                                    typeSel2: 'sell',
                                                  ),
                                                  SizedBox(width: 30,),
                                                  TabelInfoWidget(
                                                    list: controller.headerInfoUserTransactionModel?.remmitances ?? [],
                                                    title: 'حواله',
                                                    title1: 'حواله',
                                                    title2: 'رسید',
                                                    typeSel1: 'issue',
                                                    typeSel2: 'reciept',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          //margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: AppColor.backGroundColor),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: AppColor.secondary2Color.withAlpha(30),
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: const Color(0xFF64748B)),
                                                  ),
                                                  child: SizedBox(
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                ' حساب کاربری ${controller.headerInfoUserTransactionModel?.accountName ?? ""}',
                                                                style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 14 : 13),
                                                              ),
                                                            ),
                                                            // خروجی اکسل
                                                            GestureDetector(
                                                              onTap: () {
                                                                showGeneralDialog(
                                                                    context: context,
                                                                    barrierDismissible: true,
                                                                    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                                                                    barrierColor: Colors.black45,
                                                                    transitionDuration: const Duration(milliseconds: 200),
                                                                    pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                                                                      return Center(
                                                                        child: Material(
                                                                          color: Colors.transparent,
                                                                          child: Container(
                                                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColor.backGroundColor),
                                                                            width: isDesktop ? Get.width * 0.2 : Get.height * 0.5,
                                                                            height: isDesktop ? Get.height * 0.5 : Get.height * 0.7,
                                                                            padding: EdgeInsets.all(20),
                                                                            child: Column(
                                                                              children: [
                                                                                Padding(padding: const EdgeInsets.all(8.0),
                                                                                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        'خروجی اکسل',
                                                                                        style: AppTextStyle.labelText.copyWith(
                                                                                          fontSize: 15,
                                                                                          fontWeight: FontWeight.normal,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Container(color: AppColor.textColor, height: 0.2,),
                                                                                Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                                  child: Column(
                                                                                    children: [
                                                                                      SizedBox(height: 8),
                                                                                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            'از تاریخ',
                                                                                            style:
                                                                                                AppTextStyle.labelText.copyWith(fontSize: 13, fontWeight: FontWeight.normal, color: AppColor.textColor),
                                                                                          ),
                                                                                          Container(
                                                                                            //height: 50,
                                                                                            padding: EdgeInsets.only(bottom: 5),
                                                                                            child: IntrinsicHeight(
                                                                                              child: TextFormField(
                                                                                                validator: (value) {
                                                                                                  if (value == null || value.isEmpty) {
                                                                                                    return 'لطفا تاریخ را انتخاب کنید';
                                                                                                  }
                                                                                                  return null;
                                                                                                },
                                                                                                controller: controller.dateStartController,
                                                                                                readOnly: true,
                                                                                                style: AppTextStyle.labelText,
                                                                                                decoration: InputDecoration(
                                                                                                  suffixIcon: Icon(Icons.calendar_month, color: AppColor.textColor),
                                                                                                  border: OutlineInputBorder(
                                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                                  ),
                                                                                                  filled: true,
                                                                                                  fillColor: AppColor.textFieldColor,
                                                                                                  errorMaxLines: 1,
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  Jalali? pickedDate = await showPersianDatePicker(
                                                                                                    context: context,
                                                                                                    initialDate: Jalali.now(),
                                                                                                    firstDate: Jalali(1400, 1, 1),
                                                                                                    lastDate: Jalali(1450, 12, 29),
                                                                                                    initialEntryMode: PersianDatePickerEntryMode.calendar,
                                                                                                    initialDatePickerMode: PersianDatePickerMode.day,
                                                                                                    locale: Locale("fa", "IR"),
                                                                                                  );
                                                                                                  if (pickedDate != null) {
                                                                                                    Gregorian gregorian = pickedDate.toGregorian();
                                                                                                    controller.startDateFilter.value =
                                                                                                    "${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(
                                                                                                        2, '0')}";

                                                                                                    controller.dateStartController.text =
                                                                                                    "${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day
                                                                                                        .toString()
                                                                                                        .padLeft(2, '0')}";
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      SizedBox(height: 8),
                                                                                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            'تا تاریخ',
                                                                                            style:
                                                                                                AppTextStyle.labelText.copyWith(fontSize: 13, fontWeight: FontWeight.normal, color: AppColor.textColor),
                                                                                          ),
                                                                                          Container(
                                                                                            //height: 50,
                                                                                            padding: EdgeInsets.only(bottom: 5),
                                                                                            child: IntrinsicHeight(
                                                                                              child: TextFormField(
                                                                                                validator: (value) {
                                                                                                  if (value == null || value.isEmpty) {
                                                                                                    return 'لطفا تاریخ را انتخاب کنید';
                                                                                                  }
                                                                                                  return null;
                                                                                                },
                                                                                                controller: controller.dateEndController,
                                                                                                readOnly: true,
                                                                                                style: AppTextStyle.labelText,
                                                                                                decoration: InputDecoration(
                                                                                                  suffixIcon: Icon(Icons.calendar_month, color: AppColor.textColor),
                                                                                                  border: OutlineInputBorder(
                                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                                  ),
                                                                                                  filled: true,
                                                                                                  fillColor: AppColor.textFieldColor,
                                                                                                  errorMaxLines: 1,
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  Jalali? pickedDate = await showPersianDatePicker(
                                                                                                    context: context,
                                                                                                    initialDate: Jalali.now(),
                                                                                                    firstDate: Jalali(1400, 1, 1),
                                                                                                    lastDate: Jalali(1450, 12, 29),
                                                                                                    initialEntryMode: PersianDatePickerEntryMode.calendar,
                                                                                                    initialDatePickerMode: PersianDatePickerMode.day,
                                                                                                    locale: Locale("fa", "IR"),
                                                                                                  );
                                                                                                  // DateTime date=DateTime.now();
                                                                                                  if (pickedDate != null) {
                                                                                                    Gregorian gregorian = pickedDate.toGregorian();
                                                                                                    controller.endDateFilter.value =
                                                                                                    "${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(
                                                                                                        2, '0')}";

                                                                                                    controller.dateEndController.text =
                                                                                                    "${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day
                                                                                                        .toString()
                                                                                                        .padLeft(2, '0')}";
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Spacer(),
                                                                                Container(
                                                                                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                                  width: double.infinity,
                                                                                  height: 40,
                                                                                  child: ElevatedButton(
                                                                                    style: ButtonStyle(
                                                                                        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                                                                                          horizontal: 23,
                                                                                        )),
                                                                                        // elevation: WidgetStatePropertyAll(5),
                                                                                        backgroundColor: WidgetStatePropertyAll(AppColor.appBarColor),
                                                                                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                                                                            side: BorderSide(color: AppColor.textColor), borderRadius: BorderRadius.circular(5)))),
                                                                                    onPressed: () async {
                                                                                      controller.getGoldExcel();
                                                                                      Get.back();
                                                                                    },
                                                                                    child: controller.isLoading.value
                                                                                        ? CircularProgressIndicator(
                                                                                            valueColor: AlwaysStoppedAnimation<Color>(AppColor.textColor),
                                                                                          )
                                                                                        : Text('ثبت', style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10),),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    });
                                                              },
                                                              child: SvgPicture.asset('assets/svg/excel.svg', height: 30,),
                                                            ),
                                                            SizedBox(width: 17,),
                                                            // خروجی pdf
                                                            GestureDetector(
                                                              onTap: () {
                                                                showGeneralDialog(
                                                                    context: context,
                                                                    barrierDismissible: true,
                                                                    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                                                                    barrierColor: Colors.black45,
                                                                    transitionDuration: const Duration(milliseconds: 200),
                                                                    pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                                                                      return Center(
                                                                        child: Material(
                                                                          color: Colors.transparent,
                                                                          child: Container(
                                                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColor.backGroundColor),
                                                                            width: isDesktop ? Get.width * 0.2 : Get.height * 0.5,
                                                                            height: isDesktop ? Get.height * 0.5 : Get.height * 0.7,
                                                                            padding: EdgeInsets.all(20),
                                                                            child: Column(
                                                                              children: [
                                                                                Padding(padding: const EdgeInsets.all(8.0),
                                                                                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        'خروجی pdf',
                                                                                        style: AppTextStyle.labelText.copyWith(
                                                                                          fontSize: 15,
                                                                                          fontWeight: FontWeight.normal,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Container(color: AppColor.textColor, height: 0.2,),
                                                                                Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                                  child: Column(
                                                                                    children: [
                                                                                      SizedBox(height: 8),
                                                                                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            'از تاریخ',
                                                                                            style:
                                                                                                AppTextStyle.labelText.copyWith(fontSize: 13, fontWeight: FontWeight.normal, color: AppColor.textColor),
                                                                                          ),
                                                                                          Container(
                                                                                            //height: 50,
                                                                                            padding: EdgeInsets.only(bottom: 5),
                                                                                            child: IntrinsicHeight(
                                                                                              child: TextFormField(
                                                                                                validator: (value) {
                                                                                                  if (value == null || value.isEmpty) {
                                                                                                    return 'لطفا تاریخ را انتخاب کنید';
                                                                                                  }
                                                                                                  return null;
                                                                                                },
                                                                                                controller: controller.dateStartController,
                                                                                                readOnly: true,
                                                                                                style: AppTextStyle.labelText,
                                                                                                decoration: InputDecoration(
                                                                                                  suffixIcon: Icon(Icons.calendar_month, color: AppColor.textColor),
                                                                                                  border: OutlineInputBorder(
                                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                                  ),
                                                                                                  filled: true,
                                                                                                  fillColor: AppColor.textFieldColor,
                                                                                                  errorMaxLines: 1,
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  Jalali? pickedDate = await showPersianDatePicker(
                                                                                                    context: context,
                                                                                                    initialDate: Jalali.now(),
                                                                                                    firstDate: Jalali(1400, 1, 1),
                                                                                                    lastDate: Jalali(1450, 12, 29),
                                                                                                    initialEntryMode: PersianDatePickerEntryMode.calendar,
                                                                                                    initialDatePickerMode: PersianDatePickerMode.day,
                                                                                                    locale: Locale("fa", "IR"),
                                                                                                  );
                                                                                                  if (pickedDate != null) {
                                                                                                    Gregorian gregorian = pickedDate.toGregorian();
                                                                                                    controller.startDateFilter.value =
                                                                                                    "${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(
                                                                                                        2, '0')}";

                                                                                                    controller.dateStartController.text =
                                                                                                    "${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day
                                                                                                        .toString()
                                                                                                        .padLeft(2, '0')}";
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      SizedBox(height: 8),
                                                                                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            'تا تاریخ',
                                                                                            style:
                                                                                                AppTextStyle.labelText.copyWith(fontSize: 13, fontWeight: FontWeight.normal, color: AppColor.textColor),
                                                                                          ),
                                                                                          Container(
                                                                                            //height: 50,
                                                                                            padding: EdgeInsets.only(bottom: 5),
                                                                                            child: IntrinsicHeight(
                                                                                              child: TextFormField(
                                                                                                validator: (value) {
                                                                                                  if (value == null || value.isEmpty) {
                                                                                                    return 'لطفا تاریخ را انتخاب کنید';
                                                                                                  }
                                                                                                  return null;
                                                                                                },
                                                                                                controller: controller.dateEndController,
                                                                                                readOnly: true,
                                                                                                style: AppTextStyle.labelText,
                                                                                                decoration: InputDecoration(
                                                                                                  suffixIcon: Icon(Icons.calendar_month, color: AppColor.textColor),
                                                                                                  border: OutlineInputBorder(
                                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                                  ),
                                                                                                  filled: true,
                                                                                                  fillColor: AppColor.textFieldColor,
                                                                                                  errorMaxLines: 1,
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  Jalali? pickedDate = await showPersianDatePicker(
                                                                                                    context: context,
                                                                                                    initialDate: Jalali.now(),
                                                                                                    firstDate: Jalali(1400, 1, 1),
                                                                                                    lastDate: Jalali(1450, 12, 29),
                                                                                                    initialEntryMode: PersianDatePickerEntryMode.calendar,
                                                                                                    initialDatePickerMode: PersianDatePickerMode.day,
                                                                                                    locale: Locale("fa", "IR"),
                                                                                                  );
                                                                                                  // DateTime date=DateTime.now();
                                                                                                  if (pickedDate != null) {
                                                                                                    Gregorian gregorian = pickedDate.toGregorian();
                                                                                                    controller.endDateFilter.value =
                                                                                                    "${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(
                                                                                                        2, '0')}";

                                                                                                    controller.dateEndController.text =
                                                                                                    "${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day
                                                                                                        .toString()
                                                                                                        .padLeft(2, '0')}";
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Spacer(),
                                                                                Container(
                                                                                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                                  width: double.infinity,
                                                                                  height: 40,
                                                                                  child: ElevatedButton(
                                                                                    style: ButtonStyle(
                                                                                        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 23)),
                                                                                        // elevation: WidgetStatePropertyAll(5),
                                                                                        backgroundColor: WidgetStatePropertyAll(AppColor.appBarColor),
                                                                                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                                                                            side: BorderSide(color: AppColor.textColor), borderRadius: BorderRadius.circular(5)))),
                                                                                    onPressed: () async {
                                                                                      controller.exportGetGoldPdf(controller.id.value.toString());
                                                                                      Get.back();
                                                                                    },
                                                                                    child: controller.isLoading.value
                                                                                        ? CircularProgressIndicator(
                                                                                            valueColor: AlwaysStoppedAnimation<Color>(AppColor.textColor),
                                                                                          )
                                                                                        : Text('ثبت', style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10),),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    });
                                                              },
                                                              child: SvgPicture.asset('assets/svg/pdf.svg', height: 30,),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: AppColor.secondary3Color.withAlpha(20),
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: const Color(0xFF64748B)),
                                                  ),
                                                  child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            // width: 300,
                                                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                          child: Text(
                                                                            'نام : ',
                                                                            style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10, fontWeight: FontWeight.normal),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 5,),
                                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                          child: Text(
                                                                            'شماره : ',
                                                                            style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 5,),
                                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                          child: Text(
                                                                            'نقش : ',
                                                                            style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 5,),
                                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                          child: Text(
                                                                            'تاریخ عضویت : ',
                                                                            style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 5,),
                                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                          child: Text(
                                                                            'بیعانه : ',
                                                                            style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 5,),
                                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                          child: Text(
                                                                            'آدرس : ',
                                                                            style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                                Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Flexible(
                                                                          child: Container(
                                                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: AppColor.textColor),
                                                                            child: Text(
                                                                              controller.headerInfoUserTransactionModel?.accountName ?? "",
                                                                              style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10, color: AppColor.backGroundColor),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 5,),
                                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: AppColor.textColor),
                                                                          child: Text(
                                                                            controller.headerInfoUserTransactionModel?.tell ?? "",
                                                                            style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10, color: AppColor.backGroundColor),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 5,),
                                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: AppColor.textColor),
                                                                          child: Text(
                                                                            controller.headerInfoUserTransactionModel?.accountGroup ?? "",
                                                                            style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10, color: AppColor.backGroundColor),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 5,),
                                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: AppColor.textColor),
                                                                          child: Text(
                                                                            // controller.headerInfoUserTransactionModel!.startDate!.toPersianDate().toString(),
                                                                            "",
                                                                            style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10, color: AppColor.backGroundColor),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 5,),
                                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: AppColor.textColor),
                                                                          child: Text(
                                                                            controller.headerInfoUserTransactionModel?.deposit ?? "",
                                                                            style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10, color: AppColor.accentColor),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 5,),
                                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: AppColor.textColor),
                                                                          child: Text(
                                                                            controller.headerInfoUserTransactionModel?.address ?? "",
                                                                            style: AppTextStyle.labelText.copyWith(fontSize: isDesktop ? 12 : 10, color: AppColor.backGroundColor),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              IconButton(
                                                                icon: SvgPicture.asset(
                                                                  'assets/svg/camera.svg',
                                                                  height: 24,
                                                                  colorFilter: ColorFilter.mode(AppColor.iconViewColor, BlendMode.srcIn),
                                                                ),
                                                                tooltip: 'گرفتن اسکرین شات',
                                                                onPressed: () => controller.captureBalanceScreenshot(context, _balanceKey),
                                                              ),
                                                              SizedBox(width: 15,),
                                                              GestureDetector(
                                                                onTap: () async {
                                                                  await controller.checkAccountSocialStatus();
                                                                  if (controller.socialStatus.value != null) {
                                                                    Get.defaultDialog(
                                                                        backgroundColor: AppColor.backGroundColor,
                                                                        title: "ارسال مانده حساب",
                                                                        titleStyle: AppTextStyle.smallTitleText.copyWith(color: Color(0xff0ab6f0)),
                                                                        middleText: "آیا از ارسال مانده حساب مطمئن هستید؟",
                                                                        middleTextStyle: AppTextStyle.bodyText,
                                                                        confirm: Obx(() {
                                                                          final status = controller.socialStatus.value;
                                                                          final hasTelegram = status?.telegramStatus == true;
                                                                          final hasWhatsApp = status?.whatsappStatus == true;

                                                                          if (!hasTelegram && !hasWhatsApp) {
                                                                            return Padding(
                                                                              padding: const EdgeInsets.all(16.0),
                                                                              child: Text(
                                                                                'هیچ کانال ارتباطی فعال نیست',
                                                                                style: AppTextStyle.bodyText.copyWith(
                                                                                  color: AppColor.errorColor,
                                                                                  fontSize: 13,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }
                                                                          return Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                            children: [
                                                                              if (hasTelegram)
                                                                                GestureDetector(
                                                                                  onTap: () async {
                                                                                    Get.back();
                                                                                    await controller.sendBalanceToTelegram();
                                                                                  },
                                                                                  child: SvgPicture.asset(
                                                                                    'assets/svg/telegram.svg',
                                                                                    height: 24,
                                                                                    colorFilter: ColorFilter.mode(Color(0xff0ab6f0), BlendMode.srcIn),
                                                                                  ),
                                                                                ),
                                                                              if (hasWhatsApp)
                                                                                GestureDetector(
                                                                                  onTap: () {
                                                                                    // TODO: Implement WhatsApp send logic
                                                                                    Get.back();
                                                                                  },
                                                                                  child: SvgPicture.asset(
                                                                                    'assets/svg/whatsapp.svg',
                                                                                    height: 24,
                                                                                  ),
                                                                                ),
                                                                            ],
                                                                          );
                                                                        }));
                                                                  }
                                                                },
                                                                child: Tooltip(
                                                                  message: "ارسال مانده حساب",
                                                                  child: SvgPicture.asset(
                                                                    'assets/svg/send.svg',
                                                                    height: 22,
                                                                    colorFilter: ColorFilter.mode(AppColor.secondary3Color, BlendMode.srcIn),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          RepaintBoundary(
                                                            key: _balanceKey,
                                                            child: BalanceUserWidget(
                                                              title:
                                                                  " ${(controller.headerInfoUserTransactionModel?.accountName?.length ?? 0) > 27 ? controller.headerInfoUserTransactionModel?.accountName?.substring(0, 27) : controller.headerInfoUserTransactionModel?.accountName}"
                                                                  "${Jalali.now().year}/${Jalali.now().month.toString().padLeft(2, '0')}/${Jalali.now().day.toString().padLeft(2, '0')}",
                                                              listBalance: controller.balanceList,
                                                              size: Get.width * 0.9,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                  controller.isOpenMore.value
                                      ? SizedBox(
                                          height: Get.height * 0.9,
                                          width: Get.width,
                                          child: Center(
                                            child: HaniGoldLoading(),
                                          ),
                                        )
                                      : controller.transactionInfoGoldList.isEmpty
                                          ? SizedBox(
                                              height: Get.height * 0.9,
                                              width: Get.width,
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/svg/empty.svg',
                                                      height: 80,
                                                      colorFilter: ColorFilter.mode(
                                                        AppColor.textColor.withOpacity(0.5),
                                                        BlendMode.srcIn,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Text(
                                                      controller.hasActiveFilters() ? 'نتیجه فیلتر خالی است' : 'هیچ تراکنشی یافت نشد',
                                                      style: AppTextStyle.labelText.copyWith(
                                                        fontSize: 16,
                                                        color: AppColor.textColor.withOpacity(0.7),
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      controller.hasActiveFilters() ? 'لطفاً فیلترهای خود را تغییر دهید' : 'تراکنش‌های طلا در این حساب موجود نیست',
                                                      style: AppTextStyle.bodyText.copyWith(
                                                        fontSize: 12,
                                                        color: AppColor.textColor.withOpacity(0.5),
                                                      ),
                                                    ),
                                                    SizedBox(height: 15,),
                                                    GestureDetector(
                                                      onTap: () {
                                                        controller.clearFilter();
                                                        controller.getTransactionInfoGoldListPager(controller.id.value.toString());
                                                      },
                                                      child: Text(
                                                        'تلاش مجدد',
                                                        style: AppTextStyle.bodyText.copyWith(fontSize: 16, color: AppColor.accentColor, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : isDesktop
                                              ? Container(
                                                  margin: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 20),
                                                  padding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 20),
                                                  color: AppColor.backGroundColor1.withAlpha(150),
                                                  child: SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    controller: controller.scrollController,
                                                    physics: ClampingScrollPhysics(),
                                                    child: Row(
                                                      children: [
                                                        SingleChildScrollView(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              // فیلتر
                                                              Row(
                                                                children: [
                                                                  GoldTransactionFilterWidget(
                                                                    controller: controller,
                                                                    onFilterApplied: () {
                                                                      controller.getTransactionInfoGoldListPager(controller.id.value.toString());
                                                                    },
                                                                    onFilterCleared: () {
                                                                      controller.getTransactionInfoGoldListPager(controller.id.value.toString());
                                                                    },
                                                                  ),
                                                                  SizedBox(width: 20,),
                                                                  OutlinedButton.icon(
                                                                    onPressed: () {
                                                                      Get.defaultDialog(
                                                                          backgroundColor: AppColor.backGroundColor,
                                                                          title: "برداشتن تیک چک باکس",
                                                                          titleStyle: AppTextStyle.smallTitleText,
                                                                          middleText: "آیا از برداشتن تیک همه چک باکس ها مطمئن هستید؟",
                                                                          middleTextStyle: AppTextStyle.bodyText,
                                                                          confirm: ElevatedButton(
                                                                              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(AppColor.primaryColor)),
                                                                              onPressed: () {
                                                                                Get.back();
                                                                                controller.removeCheckedAll(controller.id.value, false);
                                                                              },
                                                                              child: Text(
                                                                                'اعمال تغییر',
                                                                                style: AppTextStyle.bodyText,
                                                                              )));
                                                                    },
                                                                    label: Text(
                                                                      'حذف چک باکس',
                                                                      style: AppTextStyle.labelText.copyWith(color: AppColor.textColorSecondary.withAlpha(200), fontSize: 12),
                                                                    ),
                                                                    icon: Icon(
                                                                      Icons.check_box_outline_blank,
                                                                      color: AppColor.textColor.withAlpha(30),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(height: 10,),
                                                              DataTable(
                                                                columns: buildDataColumns(),
                                                                sortColumnIndex: controller.sortIndex.value,
                                                                sortAscending: controller.sort.value,
                                                                border: TableBorder.symmetric(
                                                                  inside: BorderSide(color: AppColor.textColor, width: 0.3),
                                                                  outside: BorderSide(color: AppColor.textColor, width: 0.3),
                                                                  borderRadius: BorderRadius.circular(8),
                                                                ),
                                                                dividerThickness: 0.3,
                                                                rows: buildDataRows(context),
                                                                dataRowMaxHeight: double.infinity,
                                                                //dataRowColor: WidgetStatePropertyAll(AppColor.secondaryColor),
                                                                headingRowColor: WidgetStatePropertyAll(AppColor.buttonColor.withAlpha(40)),
                                                                headingRowHeight: 40,
                                                                columnSpacing: 12,
                                                                horizontalMargin: 0,
                                                              ),
                                                              SizedBox(height: 50,)
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : _buildMobileTransactionCards(context),
                                ],
                              ),
                            ),
                          )
                        : ErrPage(
                            callback: () {
                              controller.getTransactionInfoGoldListPager(controller.id.value.toString());
                              controller.clearFilter();
                            },
                            title: "خطا در دریافت لیست تراکنش ها",
                            des: 'برای دریافت لیست تراکنش ها مجددا تلاش کنید',
                          ),
              ),
              isDesktop
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        controller.paginated.value != null
                            ? Container(
                                height: 70,
                                margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                //color: AppColor.appBarColor.withOpacity(0.5),
                                alignment: Alignment.bottomCenter,
                                child: PagerWidget(
                                  countPage: controller.paginated.value?.totalCount ?? 0,
                                  callBack: (int index) {
                                    controller.isChangePage(index);
                                  },
                                ))
                            : SizedBox(),
                      ],
                    )
                  : SizedBox.shrink(),
            ],
          ),
          floatingActionButton: const ChatFloatingButton(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ));
  }
  List<DataColumn> buildDataColumns() {
    return [
      DataColumn(
          label: Center(
              child: Text('ردیف', style: AppTextStyle.labelText.copyWith(fontSize: 11))),
          headingRowAlignment: MainAxisAlignment.center),
      DataColumn(
          label: Center(
              child: Text('فاکتور', style: AppTextStyle.labelText.copyWith(fontSize: 11))),
          headingRowAlignment: MainAxisAlignment.center),
      DataColumn(
          label: Center(
              child: Text('تاریخ/ساعت', style: AppTextStyle.labelText.copyWith(fontSize: 11))), headingRowAlignment: MainAxisAlignment.center),
      /*DataColumn(
          onSort: (columnIndex, ascending) {
            controller.setSort(columnIndex, ascending);
            controller.onSortColum(columnIndex, ascending);
          },
          label: ConstrainedBox(constraints: BoxConstraints(maxWidth: 80), child: Text('تاریخ', style: AppTextStyle.labelText.copyWith(fontSize: 11))),
          headingRowAlignment: MainAxisAlignment.center),*/
      DataColumn(
          label: Center(
              child: Text('عملیات', style: AppTextStyle.labelText.copyWith(fontSize: 11))),
          headingRowAlignment: MainAxisAlignment.center),
      DataColumn(
          label: Center(
              child: Text('شرح', style: AppTextStyle.labelText.copyWith(fontSize: 11))), headingRowAlignment: MainAxisAlignment.center),
      DataColumn(
          label: Center(
              child: Text('وزن/تعداد', style: AppTextStyle.labelText.copyWith(fontSize: 11))),
          headingRowAlignment: MainAxisAlignment.center),
      DataColumn(
          label: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('طلا بد', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.accentColor, fontWeight: FontWeight.bold)),
                Text('طلا بس', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.primaryColor, fontWeight: FontWeight.bold))
              ],
            ),
          ),
          headingRowAlignment: MainAxisAlignment.center),
      /*DataColumn(
          label: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 100), child: Text('طلا بستانکار', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.primaryColor, fontWeight: FontWeight.bold))),
          headingRowAlignment: MainAxisAlignment.center),*/
      DataColumn(
          label: Center(
            child: Text('مانده طلایی', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.dividerColor, fontWeight: FontWeight.bold)),
          ),
          headingRowAlignment: MainAxisAlignment.center),
      DataColumn(
          label: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('تمام سکه بد', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.accentColor, fontWeight: FontWeight.bold)),
                  Text('تمام سکه بس', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.primaryColor, fontWeight: FontWeight.bold))
                ],
              )),
          headingRowAlignment: MainAxisAlignment.center),
      /*DataColumn(
          label: ConstrainedBox(constraints: BoxConstraints(maxWidth: 110),
              child: Text('تمام سکه بانکی بستانکار', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.primaryColor, fontWeight: FontWeight.bold))),
          headingRowAlignment: MainAxisAlignment.center),*/
      DataColumn(
          label: Center(
              child: Text('مانده تمام سکه', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.dividerColor, fontWeight: FontWeight.bold))),
          headingRowAlignment: MainAxisAlignment.center),
      DataColumn(
          label: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('نیم/ربع بد', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.accentColor, fontWeight: FontWeight.bold)),
                  Text('نیم/ربع بس', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.primaryColor, fontWeight: FontWeight.bold))
                ],
              )),
          headingRowAlignment: MainAxisAlignment.center),
      /*DataColumn(
          label: ConstrainedBox(constraints: BoxConstraints(maxWidth: 100),
              child: Text('نیم / ربع بستانکار', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.primaryColor, fontWeight: FontWeight.bold))),
          headingRowAlignment: MainAxisAlignment.center),*/
      DataColumn(
          label: Center(
              child: Text('مانده نیم/ربع', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.dividerColor, fontWeight: FontWeight.bold))),
          headingRowAlignment: MainAxisAlignment.center),
      DataColumn(
          label: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('نقره بد', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.accentColor, fontWeight: FontWeight.bold)),
                Text('نقره بس', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.primaryColor, fontWeight: FontWeight.bold))
              ],
            ),
          ),
          headingRowAlignment: MainAxisAlignment.center),
      DataColumn(
          label: Center(
            child: Text('مانده نقره', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.dividerColor, fontWeight: FontWeight.bold)),
          ),
          headingRowAlignment: MainAxisAlignment.center),
      DataColumn(
          label: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('دلار بد', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.accentColor, fontWeight: FontWeight.bold)),
                Text('دلار بس', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.primaryColor, fontWeight: FontWeight.bold))
              ],
            ),
          ),
          headingRowAlignment: MainAxisAlignment.center),
      DataColumn(
          label: Center(
            child: Text('مانده دلار', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.dividerColor, fontWeight: FontWeight.bold)),
          ),
          headingRowAlignment: MainAxisAlignment.center),
      DataColumn(
          label: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('یورو بد', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.accentColor, fontWeight: FontWeight.bold)),
                Text('یورو بس', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.primaryColor, fontWeight: FontWeight.bold))
              ],
            ),
          ),
          headingRowAlignment: MainAxisAlignment.center),
      DataColumn(
          label: Center(
            child: Text('مانده یورو', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.dividerColor, fontWeight: FontWeight.bold)),
          ),
          headingRowAlignment: MainAxisAlignment.center),
      DataColumn(
          label: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('ریال بد', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.accentColor, fontWeight: FontWeight.bold)),
                  Text('ریال بس', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.primaryColor, fontWeight: FontWeight.bold))
                ],
              )),
          headingRowAlignment: MainAxisAlignment.center),
      /*DataColumn(
          label: ConstrainedBox(constraints: BoxConstraints(maxWidth: 100),
              child: Text('ریال بستانکار', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.primaryColor, fontWeight: FontWeight.bold))),
          headingRowAlignment: MainAxisAlignment.center),*/
      DataColumn(
          label: Center(
                child: Text('مانده ریالی', style: AppTextStyle.labelText.copyWith(fontSize: 11, color: AppColor.dividerColor, fontWeight: FontWeight.bold))),
          headingRowAlignment: MainAxisAlignment.center),
    ];
  }
  List<DataRow> buildDataRows(BuildContext context) {
    return controller.transactionInfoGoldList.asMap().entries.map((entry) {
      final index = entry.key;
      final trans = entry.value;
      final rowColor = index.isEven ? AppColor.backGroundColor : AppColor.secondaryColor.withAlpha(100);
      return DataRow(
        color: trans.checked == true ? WidgetStateProperty.all(AppColor.appBarColor.withAlpha(150)) : WidgetStateProperty.all(rowColor),
        cells: [
          // ردیف
          DataCell(
              Center(
            child: Row(
                children: [
                  // رجیستر
                  Checkbox(
                    value: trans.checked ?? false,
                    onChanged: (value) async {
                      if (value != null) {
                        //EasyLoading.show(status: 'لطفا منتظر بمانید');
                        await controller.updateGoldChecked(trans.id ?? 0, value);
                      }
                    },
                  ),
                  SizedBox(width: 5,),
                  SelectableText("${trans.rowNum ?? 0}", style: AppTextStyle.bodyText,),
                ],
              ),
          )),
          // صدور فاکتور
          DataCell(
            Row(
              children: [
                Tooltip(
                  message: "صدور فاکتور با مانده",
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        await controller.generateInvoiceForGoldTransaction(trans);
                      },
                      child: SvgPicture.asset(
                        'assets/svg/Invoice-balance.svg',
                        height: 24,
                        /*colorFilter: ColorFilter.mode(
                          AppColor.secondary2Color,
                          BlendMode.srcIn,
                        ),*/
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4,),
                Tooltip(
                  message: "صدور فاکتور بدون مانده",
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        await controller.generateInvoiceForGoldTransactionWithoutBalance(trans);
                      },
                      child: SvgPicture.asset(
                        'assets/svg/Invoice-nobalance.svg',
                        height: 24,
                        /*colorFilter: ColorFilter.mode(
                          AppColor.secondary2Color,
                          BlendMode.srcIn,
                        ),*/
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // تاریخ/ساعت
          DataCell(Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SelectableText(
                  "${trans.date?.toPersianDate() ?? 'نامشخص'} ",
                  style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 11),
                  textDirection: TextDirection.ltr,
                ),
                SelectableText(
                  trans.date != null ? "${trans.date!.hour.toString().padLeft(2, '0')}:${trans.date!.minute.toString().padLeft(2, '0')}:${trans.date!.second.toString().padLeft(2, '0')}" : "نامشخص",
                  style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 11),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          )),
          // تاریخ
          /*DataCell(Center(
            child: SelectableText(
              "${trans.date?.toPersianDate() ?? 'نامشخص'} ",
              style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 11),
              textDirection: TextDirection.ltr,
            ),
          )),*/
          // عملیات
          DataCell(
            Center(
              child: Text(
                trans.type == "issue"
                    ? ' حواله دریافتی '
                    : trans.type == "receive"
                        ? ' دریافت '
                        : trans.type == "payment"
                            ? ' پرداخت '
                            : trans.type == "sell"
                                ? ' فروش '
                                : trans.type == "buy"
                                    ? ' خرید '
                                    : trans.type == "deposit"
                                        ? ' واریز '
                                        : trans.type == "withdraw"
                                            ? ' برداشت '
                                            : trans.type == "reciept"
                                                ? ' حواله پرداختی '
                                                : trans.type == "initial"
                                                    ? ' اول دوره '
                                                    : "",
                style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // شرح
          DataCell(
            SingleChildScrollView(
              child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                    trans.type == "initial"
                        ? Row(
                            children: [
                              SelectableText(
                                " ${trans.item?.name ?? ""} ",
                                style: AppTextStyle.bodyText.copyWith(color: AppColor.secondary3Color, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                    trans.type == "sell" || trans.type == "buy"
                        ? Row(
                            children: [
                              SelectableText(
                                " ${trans.item?.name ?? ""} ",
                                style: AppTextStyle.bodyText.copyWith(color: AppColor.secondary3Color, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              trans.item?.itemUnit?.id == 2
                                  ? SelectableText(
                                      " وزن: ",
                                      style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                    )
                                  : trans.item?.itemUnit?.id == 1
                                      ? SelectableText(
                                          " تعداد: ",
                                          style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                        )
                                      : SelectableText(
                                          " مقدار: ",
                                          style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                              SelectableText(
                                textDirection: TextDirection.ltr,
                                "${trans.amount?.toDisplayString() ?? ""}",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: trans.amount! > 0
                                        ? AppColor.primaryColor
                                        : trans.amount! < 0
                                            ? AppColor.accentColor
                                            : AppColor.textColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                              SelectableText(
                                "${trans.item?.itemUnit?.name}",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: trans.amount! > 0
                                        ? AppColor.primaryColor
                                        : trans.amount! < 0
                                            ? AppColor.accentColor
                                            : AppColor.textColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              SelectableText(
                                " قیمت: ",
                                style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              SelectableText(
                                textDirection: TextDirection.ltr,
                                trans.mesghalPrice?.toStringAsFixed(0).seRagham(separator: ',') ?? "",
                                style: AppTextStyle.bodyText.copyWith(
                                  color: AppColor.dividerColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                    trans.type == "receive" || trans.type == "payment"
                        ? Row(
                            children: [
                              SelectableText(
                                " ${trans.item?.name ?? ""} ",
                                style: AppTextStyle.bodyText.copyWith(color: AppColor.secondary3Color, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              trans.item?.itemUnit?.id == 2
                                  ? Row(
                                      children: [
                                        SelectableText(
                                          " وزن: ",
                                          style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                        SelectableText(
                                          "${trans.detail?.weight ?? ""}",
                                          style: AppTextStyle.bodyText.copyWith(color: AppColor.dividerColor, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  : trans.item?.itemUnit?.id == 1
                                      ? Row(
                                          children: [
                                            SelectableText(
                                              " تعداد: ",
                                              style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                            SelectableText(
                                              textDirection: TextDirection.ltr,
                                              "${trans.amount?.toDisplayString() ?? " "}",
                                              style: AppTextStyle.bodyText.copyWith(
                                                  color: trans.amount! > 0
                                                      ? AppColor.primaryColor
                                                      : trans.amount! < 0
                                                          ? AppColor.accentColor
                                                          : AppColor.textColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            SelectableText(
                                              " مقدار: ",
                                              style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                            SelectableText(
                                              trans.amount?.toStringAsFixed(0).seRagham() ?? "",
                                              style: AppTextStyle.bodyText.copyWith(color: AppColor.dividerColor, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                              SizedBox(width: 5,),
                              trans.item?.id == 1 || trans.item?.id == 10 || trans.item?.id == 12 || trans.item?.id == 13 || trans.item?.id == 14 || trans.item?.id == 15 || trans.item?.id == 16
                                  ? Row(
                                      children: [
                                        SelectableText(
                                          " عیار: ",
                                          style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                        SelectableText(
                                          "${trans.detail?.carat ?? ""}",
                                          style: AppTextStyle.bodyText.copyWith(color: AppColor.dividerColor, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  : SizedBox.shrink(),
                              SizedBox(width: 5,),
                              trans.item?.id == 1
                                  ? Row(
                                      children: [
                                        SelectableText(
                                          " آز: ",
                                          style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                        SelectableText(
                                          textDirection: TextDirection.ltr,
                                          "${trans.detail?.name ?? ""}",
                                          style: AppTextStyle.bodyText.copyWith(color: AppColor.dividerColor, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  : SizedBox.shrink(),
                              SizedBox(width: 5,),
                              trans.item?.id == 1
                                  ? Row(
                                      children: [
                                        SelectableText(
                                          " ش ق: ",
                                          style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                        SelectableText(
                                          textDirection: TextDirection.ltr,
                                          trans.detail?.receiptNumber ?? "",
                                          style: AppTextStyle.bodyText.copyWith(color: AppColor.dividerColor, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  : SizedBox.shrink(),
                            ],
                          )
                        : SizedBox.shrink(),
                    trans.type == "issue"
                        ? Row(
                            children: [
                              Row(
                                children: [
                                  SelectableText(
                                    " از: ",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    "${trans.account?.name ?? ""}",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.accentColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              Row(
                                children: [
                                  SelectableText(
                                    " به: ",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    trans.toAccount.name ?? "",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              SelectableText(
                                " ${trans.item?.name ?? ""} ",
                                style: AppTextStyle.bodyText.copyWith(color: AppColor.secondary3Color, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 5,),
                              trans.item?.itemUnit?.id == 2
                                  ? SelectableText(
                                      " وزن: ",
                                      style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                    )
                                  : trans.item?.itemUnit?.id == 1
                                      ? SelectableText(
                                          " تعداد: ",
                                          style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                        )
                                      : SelectableText(
                                          " مقدار: ",
                                          style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                              SelectableText(
                                textDirection: TextDirection.ltr,
                                "-${trans.amount?.abs().toDisplayString().seRagham() ?? ""}",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: trans.amount! > 0
                                        ? AppColor.primaryColor
                                        : trans.amount! < 0
                                            ? AppColor.accentColor
                                            : AppColor.textColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                              SelectableText(
                                "${trans.item?.itemUnit?.name}",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: trans.amount! > 0
                                        ? AppColor.primaryColor
                                        : trans.amount! < 0
                                            ? AppColor.accentColor
                                            : AppColor.textColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                    trans.type == "reciept"
                        ? Row(
                            children: [
                              Row(
                                children: [
                                  SelectableText(
                                    " از: ",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    trans.toAccount.name ?? "",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.accentColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              Row(
                                children: [
                                  SelectableText(
                                    " به: ",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    "${trans.account?.name ?? ""}",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              SelectableText(
                                " ${trans.item?.name ?? ""} ",
                                style: AppTextStyle.bodyText.copyWith(color: AppColor.secondary3Color, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 5,),
                              trans.item?.itemUnit?.id == 2
                                  ? SelectableText(
                                      " وزن: ",
                                      style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                    )
                                  : trans.item?.itemUnit?.id == 1
                                      ? SelectableText(
                                          " تعداد: ",
                                          style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                        )
                                      : SelectableText(
                                          " مقدار: ",
                                          style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                              SelectableText(
                                textDirection: TextDirection.ltr,
                                "${trans.amount?.toDisplayString().seRagham() ?? ""}",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: trans.amount! > 0
                                        ? AppColor.primaryColor
                                        : trans.amount! < 0
                                            ? AppColor.accentColor
                                            : AppColor.textColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                              SelectableText(
                                "${trans.item?.itemUnit?.name}",
                                style: AppTextStyle.bodyText.copyWith(
                                    color: trans.amount! > 0
                                        ? AppColor.primaryColor
                                        : trans.amount! < 0
                                            ? AppColor.accentColor
                                            : AppColor.textColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                    trans.type == "deposit"
                        ? Row(
                            children: [
                              Row(
                                children: [
                                  SelectableText(
                                    " مبلغ: ",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    "${trans.amount?.toStringAsFixed(0).seRagham() ?? ""}",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    " ریال ",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              Row(
                                children: [
                                  SelectableText(
                                    "(${trans.description ?? ""})",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.dividerColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              Row(
                                children: [
                                  SelectableText(
                                    " ش پ: ",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    trans.trackingNumber ?? "",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.dividerColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                    trans.type == "withdraw"
                        ? Row(
                            children: [
                              Row(
                                children: [
                                  SelectableText(
                                    " مبلغ: ",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    textDirection: TextDirection.ltr,
                                    "-${trans.amount?.abs().toStringAsFixed(0).seRagham() ?? ""}",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.accentColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    " ریال ",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              Row(
                                children: [
                                  SelectableText(
                                    "(${trans.description ?? ""})",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.dividerColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5,),
                              Row(
                                children: [
                                  SelectableText(
                                    " ش پ: ",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    trans.trackingNumber ?? "",
                                    style: AppTextStyle.bodyText.copyWith(color: AppColor.dividerColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                  ]),
                ),
            ),
          ),
          // مقدار
          DataCell(
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  trans.item?.id == 6
                      ? SizedBox.shrink()
                      : SelectableText(
                          trans.item?.itemUnit?.id == 1 && trans.amount! > 0
                              ? "${trans.amount?.toStringAsFixed(0).seRagham()}"
                              : trans.item?.itemUnit?.id == 1 && trans.amount! < 0
                                  ? "(-${trans.amount?.abs().toStringAsFixed(0).seRagham()})"
                                  : trans.item?.itemUnit?.id == 2 && trans.amount! > 0
                                      ? "${trans.amount?.toDisplayString().seRagham()} "
                                      : trans.item?.itemUnit?.id == 2 && trans.amount! < 0
                                          ? "(-${trans.amount?.abs().toDisplayString().seRagham()})"
                                          : trans.item?.itemUnit?.id == 3 && trans.amount! > 0
                                              ? "${trans.amount?.toStringAsFixed(0).seRagham()} "
                                              : trans.item?.itemUnit?.id == 3 && trans.amount! < 0
                                                  ? "(-${trans.amount?.abs().toStringAsFixed(0).seRagham()})"
                                                  : "${trans.amount?.toStringAsFixed(2).seRagham()} ",
                          style: AppTextStyle.bodyText.copyWith(color: trans.amount! > 0 ? AppColor.primaryColor : AppColor.accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                          textDirection: TextDirection.ltr,
                        ),
                ],
              ),
            ),
          ),
          // طلا بد/بس
          DataCell(
             Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      trans.item?.itemUnit?.id == 2 && trans.item?.id != 23
                          ? SelectableText(
                              trans.item?.itemUnit?.id == 2 && trans.item?.id != 23 && trans.amount! < 0 ? "(-${trans.amount?.abs().toStringAsFixed(3).seRagham()})" : "",
                              style: AppTextStyle.bodyText.copyWith(color: trans.amount! < 0 ? AppColor.accentColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                              textDirection: TextDirection.ltr,
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      trans.item?.itemUnit?.id == 2 && trans.item?.id != 23
                          ? SelectableText(
                        trans.item?.itemUnit?.id == 2 && trans.item?.id != 23 && trans.amount! > 0 ? "${trans.amount?.toStringAsFixed(3).seRagham()}" : "",
                        style: AppTextStyle.bodyText.copyWith(color: trans.amount! > 0 ? AppColor.primaryColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                        textDirection: TextDirection.ltr,
                      )
                          : SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
          ),
          // طلا بستانکار
          /*DataCell(
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  trans.item?.itemUnit?.id == 2
                      ? SelectableText(
                          trans.item?.itemUnit?.id == 2 && trans.amount! > 0 ? "${trans.amount?.toStringAsFixed(3).seRagham()}" : "",
                          style: AppTextStyle.bodyText.copyWith(color: trans.amount! > 0 ? AppColor.primaryColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                          textDirection: TextDirection.ltr,
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),*/
          // مانده طلایی
          DataCell(
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectableText(
                    trans.goldTotalRunning! < 0
                        ? "(-${trans.goldTotalRunning?.abs().toStringAsFixed(3).seRagham()})"
                        : trans.goldTotalRunning! > 0
                            ? "${trans.goldTotalRunning?.toStringAsFixed(3).seRagham()}"
                            : "",
                    style: AppTextStyle.bodyText.copyWith(
                        color: trans.goldTotalRunning! > 0
                            ? AppColor.primaryColor
                            : trans.goldTotalRunning! < 0
                                ? AppColor.accentColor
                                : AppColor.textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                    textDirection: TextDirection.ltr,
                  )
                ],
              ),
          ),
          // تمام بده/بس
          DataCell(
             Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: [
                 Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      trans.item?.id == 2
                          ? SelectableText(
                              trans.item?.id == 2 && trans.amount! < 0 ? "(-${trans.amount?.abs().toStringAsFixed(0).seRagham()})" : "",
                              style: AppTextStyle.bodyText.copyWith(color: trans.amount! < 0 ? AppColor.accentColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                              textDirection: TextDirection.ltr,
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     trans.item?.id == 2
                         ? SelectableText(
                       trans.item?.id == 2 && trans.amount! > 0 ? "${trans.amount?.toStringAsFixed(0).seRagham()}" : "",
                       style: AppTextStyle.bodyText.copyWith(color: trans.amount! > 0 ? AppColor.primaryColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                       textDirection: TextDirection.ltr,
                     )
                         : SizedBox.shrink(),
                   ],
                 ),
               ],
             ),
          ),
          // تمام سکه بستانکار
          /*DataCell(
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  trans.item?.id == 2
                      ? SelectableText(
                          trans.item?.id == 2 && trans.amount! > 0 ? "${trans.amount?.toStringAsFixed(0).seRagham()}" : "",
                          style: AppTextStyle.bodyText.copyWith(color: trans.amount! > 0 ? AppColor.primaryColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                          textDirection: TextDirection.ltr,
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),*/
          // مانده تمام سکه
          DataCell(
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectableText(
                    trans.coinTotalRunning! < 0
                        ? "(-${trans.coinTotalRunning?.abs().toStringAsFixed(0).seRagham()})"
                        : trans.coinTotalRunning! > 0
                            ? "${trans.coinTotalRunning?.toStringAsFixed(0).seRagham()}"
                            : "",
                    style: AppTextStyle.bodyText.copyWith(
                        color: trans.coinTotalRunning! > 0
                            ? AppColor.primaryColor
                            : trans.coinTotalRunning! < 0
                                ? AppColor.accentColor
                                : AppColor.textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
          ),
          // نیم ربع بد/بس
          DataCell(
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        trans.item?.id == 3
                            ? SelectableText(
                                trans.item?.id == 3 && trans.amount! < 0 ? "(-${trans.amount?.abs().toStringAsFixed(0).seRagham()})نیم " : "",
                                style: AppTextStyle.bodyText.copyWith(color: trans.amount! < 0 ? AppColor.accentColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                                textDirection: TextDirection.ltr,
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                    SizedBox(height: 2,),
                    (trans.item?.id == 3 || trans.item?.id == 4) && trans.amount != null
                        ? RotatedBox(
                            quarterTurns: 1,
                            child: Divider(
                              color: AppColor.dividerColor,
                              height: 1,
                            ))
                        : SizedBox.shrink(),
                    SizedBox(height: 2,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        trans.item?.id == 4
                            ? SelectableText(
                                trans.item?.id == 4 && trans.amount! < 0 ? "(-${trans.amount?.abs().toStringAsFixed(0).seRagham()})ربع " : "",
                                style: AppTextStyle.bodyText.copyWith(color: trans.amount! < 0 ? AppColor.accentColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                                textDirection: TextDirection.ltr,
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        trans.item?.id == 3
                            ? SelectableText(
                          trans.item?.id == 3 && trans.amount! > 0 ? "${trans.amount?.toStringAsFixed(0).seRagham()} نیم " : "",
                          style: AppTextStyle.bodyText.copyWith(color: trans.amount! > 0 ? AppColor.primaryColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                          textDirection: TextDirection.ltr,
                        )
                            : SizedBox.shrink(),
                      ],
                    ),
                    SizedBox(width: 2,),
                    (trans.item?.id == 3 || trans.item?.id == 4) && trans.amount != null
                        ? RotatedBox(
                        quarterTurns: 1,
                        child: Divider(
                          color: AppColor.dividerColor,
                          height: 1,
                        ))
                        : SizedBox.shrink(),
                    SizedBox(width: 2,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        trans.item?.id == 4
                            ? SelectableText(
                          trans.item?.id == 4 && trans.amount! > 0 ? "${trans.amount?.toStringAsFixed(0).seRagham()} ربع " : "",
                          style: AppTextStyle.bodyText.copyWith(color: trans.amount! > 0 ? AppColor.primaryColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                          textDirection: TextDirection.ltr,
                        )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // نیم ربع بستانکار
          /*DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    trans.item?.id == 3
                        ? SelectableText(
                            trans.item?.id == 3 && trans.amount! > 0 ? "${trans.amount?.toStringAsFixed(0).seRagham()} نیم " : "",
                            style: AppTextStyle.bodyText.copyWith(color: trans.amount! > 0 ? AppColor.primaryColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                            textDirection: TextDirection.ltr,
                          )
                        : SizedBox.shrink(),
                  ],
                ),
                SizedBox(width: 2,),
                (trans.item?.id == 3 || trans.item?.id == 4) && trans.amount != null
                    ? RotatedBox(
                        quarterTurns: 1,
                        child: Divider(
                          color: AppColor.dividerColor,
                          height: 1,
                        ))
                    : SizedBox.shrink(),
                SizedBox(width: 2,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    trans.item?.id == 4
                        ? SelectableText(
                            trans.item?.id == 4 && trans.amount! > 0 ? "${trans.amount?.toStringAsFixed(0).seRagham()} ربع " : "",
                            style: AppTextStyle.bodyText.copyWith(color: trans.amount! > 0 ? AppColor.primaryColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                            textDirection: TextDirection.ltr,
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),*/
          // مانده نیم ربع
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SelectableText(
                      trans.halfCoinTotalRunning! < 0
                          ? "(-${trans.halfCoinTotalRunning?.abs().toStringAsFixed(0).seRagham()})نیم "
                          : trans.halfCoinTotalRunning! > 0
                              ? "${trans.halfCoinTotalRunning?.toStringAsFixed(0).seRagham()} نیم "
                              : "",
                      style: AppTextStyle.bodyText.copyWith(
                          color: trans.halfCoinTotalRunning! > 0
                              ? AppColor.primaryColor
                              : trans.halfCoinTotalRunning! < 0
                                  ? AppColor.accentColor
                                  : AppColor.textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
                SizedBox(width: 2,),
                trans.halfCoinTotalRunning != null || trans.quarterCoinTotalRunning != null
                    ? RotatedBox(
                        quarterTurns: 1,
                        child: Divider(
                          color: AppColor.dividerColor,
                          height: 1,
                        ))
                    : SizedBox.shrink(),
                SizedBox(width: 2,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SelectableText(
                      trans.quarterCoinTotalRunning! < 0
                          ? "(-${trans.quarterCoinTotalRunning?.abs().toStringAsFixed(0).seRagham()}) ربع "
                          : trans.quarterCoinTotalRunning! > 0
                              ? "${trans.quarterCoinTotalRunning?.toStringAsFixed(0).seRagham()} ربع "
                              : "",
                      style: AppTextStyle.bodyText.copyWith(
                          color: trans.quarterCoinTotalRunning! > 0
                              ? AppColor.primaryColor
                              : trans.quarterCoinTotalRunning! < 0
                                  ? AppColor.accentColor
                                  : AppColor.textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // نقره بد/بس
          DataCell(
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    trans.item?.id == 23
                        ? SelectableText(
                      trans.item?.id == 23 && trans.amount! < 0 ? "(-${trans.amount?.abs().toString().seRagham()})" : "",
                      style: AppTextStyle.bodyText.copyWith(color: trans.amount! < 0 ? AppColor.accentColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.ltr,
                    )
                        : SizedBox.shrink(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    trans.item?.id == 23
                        ? SelectableText(
                      trans.item?.id == 23 && trans.amount! > 0 ? "${trans.amount?.toString().seRagham()}" : "",
                      style: AppTextStyle.bodyText.copyWith(color: trans.amount! > 0 ? AppColor.primaryColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.ltr,
                    )
                        : SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
          // مانده نقره
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectableText(
                  trans.silverTotalRunning! < 0
                      ? "(-${trans.silverTotalRunning?.abs().toString().seRagham()})"
                      : trans.silverTotalRunning! > 0
                      ? "${trans.silverTotalRunning?.toString().seRagham()}"
                      : "",
                  style: AppTextStyle.bodyText.copyWith(
                      color: trans.silverTotalRunning! > 0
                          ? AppColor.primaryColor
                          : trans.silverTotalRunning! < 0
                          ? AppColor.accentColor
                          : AppColor.textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                  textDirection: TextDirection.ltr,
                )
              ],
            ),
          ),
          // دلار بد/بس
          DataCell(
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    trans.item?.id == 7
                        ? SelectableText(
                      trans.item?.id == 7 && trans.amount! < 0 ? "(-${trans.amount?.abs().toString().seRagham()})" : "",
                      style: AppTextStyle.bodyText.copyWith(color: trans.amount! < 0 ? AppColor.accentColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.ltr,
                    )
                        : SizedBox.shrink(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    trans.item?.id == 7
                        ? SelectableText(
                      trans.item?.id == 7 && trans.amount! > 0 ? "${trans.amount?.toString().seRagham()}" : "",
                      style: AppTextStyle.bodyText.copyWith(color: trans.amount! > 0 ? AppColor.primaryColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.ltr,
                    )
                        : SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
          // مانده دلار
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectableText(
                  trans.dollarTotalRunning! < 0
                      ? "(-${trans.dollarTotalRunning?.abs().toString().seRagham()})"
                      : trans.dollarTotalRunning! > 0
                      ? "${trans.dollarTotalRunning?.toString().seRagham()}"
                      : "",
                  style: AppTextStyle.bodyText.copyWith(
                      color: trans.dollarTotalRunning! > 0
                          ? AppColor.primaryColor
                          : trans.dollarTotalRunning! < 0
                          ? AppColor.accentColor
                          : AppColor.textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                  textDirection: TextDirection.ltr,
                )
              ],
            ),
          ),
          // یورو بد/بس
          DataCell(
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    trans.item?.id == 17
                        ? SelectableText(
                      trans.item?.id == 17 && trans.amount! < 0 ? "(-${trans.amount?.abs().toString().seRagham()})" : "",
                      style: AppTextStyle.bodyText.copyWith(color: trans.amount! < 0 ? AppColor.accentColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.ltr,
                    )
                        : SizedBox.shrink(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    trans.item?.id == 17
                        ? SelectableText(
                      trans.item?.id == 17 && trans.amount! > 0 ? "${trans.amount?.toString().seRagham()}" : "",
                      style: AppTextStyle.bodyText.copyWith(color: trans.amount! > 0 ? AppColor.primaryColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.ltr,
                    )
                        : SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
          // مانده یورو
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectableText(
                  trans.euroTotalRunning! < 0
                      ? "(-${trans.euroTotalRunning?.abs().toString().seRagham()})"
                      : trans.euroTotalRunning! > 0
                      ? "${trans.euroTotalRunning?.toString().seRagham()}"
                      : "",
                  style: AppTextStyle.bodyText.copyWith(
                      color: trans.euroTotalRunning! > 0
                          ? AppColor.primaryColor
                          : trans.euroTotalRunning! < 0
                          ? AppColor.accentColor
                          : AppColor.textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                  textDirection: TextDirection.ltr,
                )
              ],
            ),
          ),
          // ریال بد/بس
          DataCell(
             Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: [
                 Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      trans.item?.id == 6
                          ? SelectableText(
                              trans.item?.id == 6 && trans.amount! < 0 ? "(-${trans.amount?.abs().toStringAsFixed(0).seRagham()})" : "",
                              style: AppTextStyle.bodyText.copyWith(color: trans.amount! < 0 ? AppColor.accentColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                              textDirection: TextDirection.ltr,
                            )
                          : trans.type == "sell"
                              ? SelectableText(
                                  "(-${trans.totalPrice?.abs().toStringAsFixed(0).seRagham()})",
                                  style: AppTextStyle.bodyText.copyWith(color: trans.type == "sell" ? AppColor.accentColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  textDirection: TextDirection.ltr,
                                )
                              : SizedBox.shrink(),
                    ],
                  ),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     trans.item?.id == 6
                         ? SelectableText(
                       trans.item?.id == 6 && trans.amount! > 0 ? "${trans.amount?.toStringAsFixed(0).seRagham()}" : "",
                       style: AppTextStyle.bodyText.copyWith(color: trans.amount! > 0 ? AppColor.primaryColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                       textDirection: TextDirection.ltr,
                     )
                         : trans.type == "buy"
                         ? SelectableText(
                       "${trans.totalPrice?.toStringAsFixed(0).seRagham()}",
                       style: AppTextStyle.bodyText.copyWith(color: trans.type == "buy" ? AppColor.primaryColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                       textDirection: TextDirection.ltr,
                     )
                         : SizedBox.shrink(),
                   ],
                 ),
               ],
             ),
          ),
          // ریال بستانکار
          /*DataCell(
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  trans.item?.id == 6
                      ? SelectableText(
                          trans.item?.id == 6 && trans.amount! > 0 ? "${trans.amount?.toStringAsFixed(0).seRagham()}" : "",
                          style: AppTextStyle.bodyText.copyWith(color: trans.amount! > 0 ? AppColor.primaryColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                          textDirection: TextDirection.ltr,
                        )
                      : trans.type == "buy"
                          ? SelectableText(
                              "${trans.totalPrice?.toStringAsFixed(0).seRagham()}",
                              style: AppTextStyle.bodyText.copyWith(color: trans.type == "buy" ? AppColor.primaryColor : AppColor.textColor, fontSize: 11, fontWeight: FontWeight.bold),
                              textDirection: TextDirection.ltr,
                            )
                          : SizedBox.shrink(),
                ],
              ),
            ),
          ),*/
          // ریال طلایی
          DataCell(
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectableText(
                    trans.cashTotalRunning! < 0
                        ? "(-${trans.cashTotalRunning?.abs().toStringAsFixed(0).seRagham()})"
                        : trans.cashTotalRunning! > 0
                            ? "${trans.cashTotalRunning?.toStringAsFixed(0).seRagham()}"
                            : "",
                    style: AppTextStyle.bodyText.copyWith(
                        color: trans.cashTotalRunning! > 0
                            ? AppColor.primaryColor
                            : trans.cashTotalRunning! < 0
                                ? AppColor.accentColor
                                : AppColor.textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                    textDirection: TextDirection.ltr,
                  )
                ],
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
  Widget _buildMobileTransactionCards(BuildContext context) {
    if (controller.transactionInfoGoldList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColor.textColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'هیچ تراکنشی یافت نشد',
                style: AppTextStyle.labelText.copyWith(
                  fontSize: 16,
                  color: AppColor.textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        // فیلتر
        Row(
          children: [
            GoldTransactionFilterWidget(
              controller: controller,
              onFilterApplied: () {
                controller.getTransactionInfoGoldListPager(controller.id.value.toString());
              },
              onFilterCleared: () {
                controller.getTransactionInfoGoldListPager(controller.id.value.toString());
              },
            ),
            OutlinedButton.icon(
              onPressed: () {
                Get.defaultDialog(
                    backgroundColor: AppColor.backGroundColor,
                    title: "برداشتن تیک چک باکس",
                    titleStyle: AppTextStyle.smallTitleText,
                    middleText: "آیا از برداشتن تیک همه چک باکس ها مطمئن هستید؟",
                    middleTextStyle: AppTextStyle.bodyText,
                    confirm: ElevatedButton(
                        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(AppColor.primaryColor)),
                        onPressed: () {
                          Get.back();
                          controller.removeCheckedAll(controller.id.value, false);
                        },
                        child: Text('اعمال تغییر', style: AppTextStyle.bodyText,)
                    )
                );
              },
              label: Text('حذف چک باکس', style: AppTextStyle.labelText.copyWith(color: AppColor.textColorSecondary.withAlpha(200), fontSize: 12),),
              icon: Icon(
                Icons.check_box_outline_blank,
                color: AppColor.textColor.withAlpha(30),
              ),
            ),
            SizedBox.shrink(),
          ],
        ),
        SizedBox(height: 2),
        ListView.builder(
          itemCount: controller.transactionInfoGoldList.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (ctx, index) {
            final trans = controller.transactionInfoGoldList[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.only(top: 2, right: 15, left: 15, bottom: 12),
              decoration: BoxDecoration(
                color: trans.checked == true ? AppColor.backGroundColor.withAlpha(180) : AppColor.secondaryColor.withAlpha(180),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF64748B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with checkbox and row number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${trans.rowNum ?? 0}",
                            style: AppTextStyle.bodyText.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Checkbox(
                            value: trans.checked ?? false,
                            onChanged: (value) async {
                              if (value != null) {
                                await controller.updateGoldChecked(trans.id ?? 0, value);
                              }
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMobileCardItem(
                            'تاریخ: ',
                            trans.date?.toPersianDate() ?? 'نامشخص',
                            AppColor.textColor,
                          ),
                          SizedBox(width: 10,),
                          _buildMobileCardItem(
                            'ساعت: ',
                            trans.date != null
                                ? "${trans.date!.hour.toString().padLeft(2, '0')}:${trans.date!.minute.toString().padLeft(2, '0')}:${trans.date!.second.toString().padLeft(2, '0')}"
                                : "نامشخص",
                            AppColor.textColor,
                          ),
                        ],
                      ),
                      _buildTransactionTypeChip(trans.type),
                    ],
                  ),
                  Divider(color: AppColor.iconViewColor, height: 0.5,),
                  const SizedBox(height: 5),
                  // Transaction details based on type
                  trans.type == "receive" || trans.type == "payment"
                      ? Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColor.textFieldColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF64748B)),
                          ),
                          child: Row(
                            children: [
                              Text("مقدار: ", style: AppTextStyle.bodyText,),
                              Text(
                                trans.item?.itemUnit?.id == 1 && trans.amount! > 0
                                    ? "${trans.amount?.toStringAsFixed(0).seRagham()}"
                                    : trans.item?.itemUnit?.id == 1 && trans.amount! < 0
                                        ? "(-${trans.amount?.abs().toStringAsFixed(0).seRagham()})"
                                        : trans.item?.itemUnit?.id == 2 && trans.amount! > 0
                                            ? "${trans.amount?.toDisplayString().seRagham()} "
                                            : trans.item?.itemUnit?.id == 2 && trans.amount! < 0
                                                ? "(-${trans.amount?.abs().toDisplayString().seRagham()})"
                                                : trans.item?.itemUnit?.id == 3 && trans.amount! > 0
                                                    ? "${trans.amount?.toStringAsFixed(0).seRagham()} "
                                                    : trans.item?.itemUnit?.id == 3 && trans.amount! < 0
                                                        ? "(-${trans.amount?.abs().toStringAsFixed(0).seRagham()})"
                                                        : "${trans.amount?.toStringAsFixed(2).seRagham()} ",
                                style: AppTextStyle.bodyText.copyWith(color: trans.amount! > 0 ? AppColor.primaryColor : AppColor.accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                                textDirection: TextDirection.ltr,
                              ),
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
                  _buildTransactionDetails(trans),
                  // Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await controller.generateInvoiceForGoldTransaction(trans);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColor.secondary2Color.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColor.secondary2Color.withAlpha(75)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.receipt_long, size: 18, color: AppColor.secondary2Color),
                                SizedBox(width: 6),
                                Text(
                                  "فاکتور با مانده",
                                  style: AppTextStyle.labelText.copyWith(
                                    color: AppColor.secondary2Color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 4,),
                        GestureDetector(
                          onTap: () async {
                            await controller.generateInvoiceForGoldTransactionWithoutBalance(trans);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColor.secondary2Color.withAlpha(45),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColor.secondary2Color.withAlpha(100)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.receipt_long, size: 18, color: AppColor.secondary2Color),
                                SizedBox(width: 6),
                                Text(
                                  "فاکتور",
                                  style: AppTextStyle.labelText.copyWith(
                                    color: AppColor.secondary2Color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Description if available
                  if (trans.description != null && trans.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildMobileCardItem(
                        'توضیحات: ',
                        trans.description ?? "",
                        AppColor.dividerColor,
                      ),
                    ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColor.secondary3Color.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColor.textColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (trans.item?.itemUnit?.id == 2 && (trans.amount ?? 0) != 0)
                              Row(
                                children: [
                                  trans.item?.itemUnit?.id == 2 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) < 0
                                      ? _buildMobileCardItemTotal(AppColor.textAccentColor, "طلا بدهکار: ", "(-${trans.amount!.abs().toString().seRagham()})", AppColor.accentColor)
                                      : trans.item?.itemUnit?.id == 2 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) > 0
                                          ? _buildMobileCardItemTotal(
                                              AppColor.textPrimaryColor,
                                              "طلا بستانکار: ",
                                              trans.amount!.toString().seRagham(),
                                              AppColor.primaryColor,
                                            )
                                          : SizedBox.shrink(),
                                ],
                              ),
                            Row(
                              children: [
                                trans.item?.id == 6 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) < 0
                                    ? _buildMobileCardItemTotal(AppColor.textAccentColor, "ریال بدهکار: ", "(-${trans.amount!.abs().toStringAsFixed(0).seRagham()})", AppColor.accentColor)
                                    : trans.type == "sell"
                                        ? _buildMobileCardItemTotal(AppColor.textAccentColor, "ریال بدهکار: ", "(-${trans.totalPrice!.abs().toStringAsFixed(0).seRagham()})", AppColor.accentColor)
                                        : trans.item?.id == 6 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) > 0
                                            ? _buildMobileCardItemTotal(
                                                AppColor.textPrimaryColor,
                                                "ریال بستانکار: ",
                                                trans.amount!.toStringAsFixed(0).seRagham(),
                                                AppColor.primaryColor,
                                              )
                                            : trans.type == "buy"
                                                ? _buildMobileCardItemTotal(
                                                    AppColor.textPrimaryColor,
                                                    "ریال بستانکار: ",
                                                    trans.totalPrice!.toStringAsFixed(0).seRagham(),
                                                    AppColor.primaryColor,
                                                  )
                                                : SizedBox.shrink(),
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (trans.item?.id == 2 && (trans.amount ?? 0) != 0)
                              Row(
                                children: [
                                  trans.item?.id == 2 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) < 0
                                      ? _buildMobileCardItemTotal(AppColor.textAccentColor, "تمام سکه بدهکار: ", "(-${trans.amount!.abs().toStringAsFixed(0).seRagham()})", AppColor.accentColor)
                                      : trans.item?.id == 2 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) > 0
                                          ? _buildMobileCardItemTotal(
                                              AppColor.textPrimaryColor,
                                              "تمام سکه بستانکار: ",
                                              trans.amount!.toStringAsFixed(0).seRagham(),
                                              AppColor.primaryColor,
                                            )
                                          : SizedBox.shrink(),
                                ],
                              ),
                            if (trans.item?.id == 3 && (trans.amount ?? 0) != 0)
                              Row(
                                children: [
                                  trans.item?.id == 3 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) < 0
                                      ? _buildMobileCardItemTotal(AppColor.textAccentColor, "نیم سکه بدهکار: ", "(-${trans.amount!.abs().toStringAsFixed(0).seRagham()})", AppColor.accentColor)
                                      : trans.item?.id == 3 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) > 0
                                          ? _buildMobileCardItemTotal(
                                              AppColor.textPrimaryColor,
                                              "نیم سکه بستانکار: ",
                                              trans.amount!.toStringAsFixed(0).seRagham(),
                                              AppColor.primaryColor,
                                            )
                                          : SizedBox.shrink(),
                                ],
                              ),
                            if (trans.item?.id == 4 && (trans.amount ?? 0) != 0)
                              Row(
                                children: [
                                  trans.item?.id == 4 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) < 0
                                      ? _buildMobileCardItemTotal(AppColor.textAccentColor, "ربع سکه بدهکار: ", "(-${trans.amount!.abs().toStringAsFixed(0).seRagham()})", AppColor.accentColor)
                                      : trans.item?.id == 4 && (trans.amount ?? 0) != 0 && (trans.amount ?? 0) > 0
                                          ? _buildMobileCardItemTotal(
                                              AppColor.textPrimaryColor,
                                              "ربع سکه بستانکار: ",
                                              trans.amount!.toStringAsFixed(0).seRagham(),
                                              AppColor.primaryColor,
                                            )
                                          : SizedBox.shrink(),
                                ],
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColor.dividerColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColor.textColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if ((trans.goldTotalRunning ?? 0) != 0)
                              Expanded(
                                child: _buildMobileCardItemTotal(
                                  AppColor.dividerColor,
                                  "مانده طلایی: ",
                                  (trans.goldTotalRunning ?? 0) < 0 ? "(-${trans.goldTotalRunning!.abs().toStringAsFixed(3).seRagham()})" : trans.goldTotalRunning!.toStringAsFixed(3).seRagham(),
                                  (trans.goldTotalRunning ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,
                                ),
                              ),
                            if ((trans.cashTotalRunning ?? 0) != 0)
                              _buildMobileCardItemTotal(
                                AppColor.dividerColor,
                                "مانده ریالی: ",
                                (trans.cashTotalRunning ?? 0) < 0 ? "(-${trans.cashTotalRunning!.abs().toStringAsFixed(0).seRagham()})" : trans.cashTotalRunning!.toStringAsFixed(0).seRagham(),
                                (trans.cashTotalRunning ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,
                              ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if ((trans.coinTotalRunning ?? 0) != 0)
                              _buildMobileCardItemTotal(
                                AppColor.dividerColor,
                                "مانده تمام سکه: ",
                                (trans.coinTotalRunning ?? 0) < 0 ? "(-${trans.coinTotalRunning!.abs().toStringAsFixed(0)})" : trans.coinTotalRunning!.toStringAsFixed(0),
                                (trans.coinTotalRunning ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,
                              ),
                            if ((trans.halfCoinTotalRunning ?? 0) != 0)
                              _buildMobileCardItemTotal(
                                AppColor.dividerColor,
                                "مانده نیم: ",
                                (trans.halfCoinTotalRunning ?? 0) < 0 ? "(-${trans.halfCoinTotalRunning!.abs().toStringAsFixed(0)})" : trans.halfCoinTotalRunning!.toStringAsFixed(0),
                                (trans.halfCoinTotalRunning ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,
                              ),
                            if ((trans.quarterCoinTotalRunning ?? 0) != 0)
                              _buildMobileCardItemTotal(
                                AppColor.dividerColor,
                                "مانده ربع: ",
                                (trans.quarterCoinTotalRunning ?? 0) < 0 ? "(-${trans.quarterCoinTotalRunning!.abs().toStringAsFixed(0)})" : trans.quarterCoinTotalRunning!.toStringAsFixed(0),
                                (trans.quarterCoinTotalRunning ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,
                              ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if ((trans.silverTotalRunning ?? 0) != 0)
                              _buildMobileCardItemTotal(
                                AppColor.dividerColor,
                                "مانده نقره: ",
                                (trans.silverTotalRunning ?? 0) < 0 ? "(-${trans.silverTotalRunning!.abs().toString().seRagham()})" : trans.silverTotalRunning!.toString().seRagham(),
                                (trans.silverTotalRunning ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,
                              ),
                            if ((trans.dollarTotalRunning ?? 0) != 0)
                              _buildMobileCardItemTotal(
                                AppColor.dividerColor,
                                "مانده دلار: ",
                                (trans.dollarTotalRunning ?? 0) < 0 ? "(-${trans.dollarTotalRunning!.abs().toString().seRagham()})" : trans.dollarTotalRunning!.toString().seRagham(),
                                (trans.dollarTotalRunning ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,
                              ),
                            if ((trans.euroTotalRunning ?? 0) != 0)
                              _buildMobileCardItemTotal(
                                AppColor.dividerColor,
                                "مانده یورو: ",
                                (trans.euroTotalRunning ?? 0) < 0 ? "(-${trans.euroTotalRunning!.abs().toString().seRagham()})" : trans.euroTotalRunning!.toString().seRagham(),
                                (trans.euroTotalRunning ?? 0) < 0 ? AppColor.accentColor : AppColor.primaryColor,
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Obx(() {
          if (controller.isLoading.value && controller.transactionInfoGoldList.isNotEmpty) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Center(
                child: HaniGoldLoading(),
              ),
            );
          }
          if (!controller.hasMore.value && controller.transactionInfoGoldList.isNotEmpty) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Text(
                "همه تراکنش‌ها نمایش داده شد",
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyText.copyWith(
                  color: AppColor.textColor.withOpacity(0.7),
                ),
              ),
            );
          }
          return SizedBox.shrink();
        }),
        SizedBox(height: 20),
      ]),
    );
  }
  Widget _buildTransactionTypeChip(String? type) {
    String typeText = '';
    Color chipColor = AppColor.textColor;

    switch (type) {
      case 'issue':
        typeText = 'حواله دریافتی';
        chipColor = const Color(0xFF3B82F6);
        break;
      case 'receive':
        typeText = 'دریافت';
        chipColor = const Color(0xFF10B981);
        break;
      case 'payment':
        typeText = 'پرداخت';
        chipColor = const Color(0xFFEF4444);
        break;
      case 'sell':
        typeText = 'فروش';
        chipColor = const Color(0xFFF59E0B);
        break;
      case 'buy':
        typeText = 'خرید';
        chipColor = const Color(0xFF10B981);
        break;
      case 'deposit':
        typeText = 'واریز';
        chipColor = const Color(0xFF8B5CF6);
        break;
      case 'withdraw':
        typeText = 'برداشت';
        chipColor = const Color(0xFFEF4444);
        break;
      case 'reciept':
        typeText = 'حواله پرداختی';
        chipColor = const Color(0xFF3B82F6);
        break;
      case 'initial':
        typeText = 'اول دوره';
        chipColor = const Color(0xFF6B7280);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        typeText,
        style: AppTextStyle.labelText.copyWith(
          color: chipColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  Widget _buildTransactionDetails(dynamic trans) {
    switch (trans.type) {
      case 'initial':
        return _buildInitialTransactionDetails(trans);
      case 'sell':
      case 'buy':
        return _buildSellBuyTransactionDetails(trans);
      case 'receive':
      case 'payment':
        return _buildReceivePaymentTransactionDetails(trans);
      case 'issue':
        return _buildIssueTransactionDetails(trans);
      case 'reciept':
        return _buildReceiptTransactionDetails(trans);
      case 'deposit':
        return _buildDepositTransactionDetails(trans);
      case 'withdraw':
        return _buildWithdrawTransactionDetails(trans);
      default:
        return const SizedBox.shrink();
    }
  }
  Widget _buildInitialTransactionDetails(dynamic trans) {
    return _buildMobileCardItem(
      'آیتم: ',
      trans.item?.name ?? "",
      AppColor.secondary3Color,
    );
  }
  Widget _buildSellBuyTransactionDetails(dynamic trans) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMobileCardItem(
                'آیتم: ',
                trans.item?.name ?? "",
                AppColor.secondary3Color,
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildMobileCardItem(
                    trans.item?.itemUnit?.id == 2
                        ? 'وزن: '
                        : trans.item?.itemUnit?.id == 1
                            ? 'تعداد: '
                            : 'مقدار: ',
                    (trans.amount ?? 0) < 0 ? "-${trans.amount?.abs().toString().seRagham() ?? ""}" : trans.amount?.toString().seRagham() ?? "",
                    (trans.amount ?? 0) > 0
                        ? AppColor.primaryColor
                        : (trans.amount ?? 0) < 0
                            ? AppColor.accentColor
                            : AppColor.textColor,
                  ),
                  Text(" ${trans.item?.itemUnit?.name ?? ""}", style: AppTextStyle.labelText,),
                ],
              ),
            ),
            Row(
              children: [
                _buildMobileCardItem(
                  'قیمت: ',
                  trans.mesghalPrice?.toString().seRagham() ?? "",
                  AppColor.dividerColor,
                ),
                Text(' ریال', style: AppTextStyle.bodyText,),
              ],
            )
          ],
        ),
      ],
    );
  }
  Widget _buildReceivePaymentTransactionDetails(dynamic trans) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _buildMobileCardItem(
                'آیتم: ',
                trans.item?.name ?? "",
                AppColor.secondary3Color,
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildMobileCardItem(
                    trans.item?.itemUnit?.id == 2
                        ? 'وزن: '
                        : trans.item?.itemUnit?.id == 1
                            ? 'تعداد: '
                            : 'مقدار: ',
                    trans.item?.itemUnit?.id == 2
                        ? "${trans.detail?.weight ?? ""}"
                        : trans.item?.itemUnit?.id == 1
                            ? "${trans.amount ?? " "}"
                            : trans.amount?.toString().seRagham() ?? "",
                    //(trans.amount ?? 0) < 0 ? "-${trans.amount?.abs().toString().seRagham() ?? ""}" : trans.amount?.toString().seRagham() ?? "",
                    (trans.amount ?? 0) > 0
                        ? AppColor.primaryColor
                        : (trans.amount ?? 0) < 0
                            ? AppColor.accentColor
                            : AppColor.textColor,
                  ),
                  Text(" ${trans.item?.itemUnit?.name ?? ""}", style: AppTextStyle.labelText,),
                ],
              ),
            ),
            if (trans.item?.id == 1 || trans.item?.id == 10 || trans.item?.id == 12 || trans.item?.id == 13 || trans.item?.id == 14 || trans.item?.id == 15 || trans.item?.id == 16)
              Expanded(
                child: _buildMobileCardItem(
                  'عیار: ',
                  trans.detail?.carat?.toString() ?? "",
                  AppColor.dividerColor,
                ),
              ),
          ],
        ),
        if (trans.item?.id == 1) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _buildMobileCardItem(
                  'آز: ',
                  trans.detail?.name ?? "",
                  AppColor.dividerColor,
                ),
              ),
              Expanded(
                child: _buildMobileCardItem(
                  'ش ق: ',
                  trans.detail?.receiptNumber ?? "",
                  AppColor.dividerColor,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
  Widget _buildIssueTransactionDetails(dynamic trans) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildMobileCardItem(
                'از: ',
                trans.account?.name ?? "",
                AppColor.accentColor,
              ),
            ),
            Expanded(
              child: _buildMobileCardItem(
                'به: ',
                trans.toAccount?.name ?? "",
                AppColor.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildMobileCardItem(
                'آیتم: ',
                trans.item?.name ?? "",
                AppColor.secondary3Color,
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildMobileCardItem(
                    trans.item?.itemUnit?.id == 2
                        ? 'وزن: '
                        : trans.item?.itemUnit?.id == 1
                            ? 'تعداد: '
                            : 'مقدار: ',
                    "-${trans.amount?.abs().toString().seRagham() ?? ""}",
                    trans.amount! > 0
                        ? AppColor.primaryColor
                        : trans.amount! < 0
                            ? AppColor.accentColor
                            : AppColor.textColor,
                  ),
                  Text(" ${trans.item?.itemUnit?.name ?? ""}", style: AppTextStyle.labelText,),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
  Widget _buildReceiptTransactionDetails(dynamic trans) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildMobileCardItem(
                'از: ',
                trans.toAccount?.name ?? "",
                AppColor.accentColor,
              ),
            ),
            Expanded(
              child: _buildMobileCardItem(
                'به: ',
                trans.account?.name ?? "",
                AppColor.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMobileCardItem(
                'آیتم: ',
                trans.item?.name ?? "",
                AppColor.secondary3Color,
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildMobileCardItem(
                    trans.item?.itemUnit?.id == 2
                        ? 'وزن: '
                        : trans.item?.itemUnit?.id == 1
                            ? 'تعداد: '
                            : 'مقدار: ',
                    trans.amount?.toString().seRagham() ?? "",
                    trans.amount! > 0
                        ? AppColor.primaryColor
                        : trans.amount! < 0
                            ? AppColor.accentColor
                            : AppColor.textColor,
                  ),
                  Text(" ${trans.item?.itemUnit?.name ?? ""}", style: AppTextStyle.labelText,),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
  Widget _buildDepositTransactionDetails(dynamic trans) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildMobileCardItem(
              'مبلغ: ',
              trans.amount?.toString().seRagham() ?? "",
              AppColor.primaryColor,
            ),
            Expanded(
              child: Text(
                ' ریال',
                style: AppTextStyle.bodyText,
              ),
            ),
            if (trans.trackingNumber != null && trans.trackingNumber!.isNotEmpty)
              Expanded(
                child: _buildMobileCardItem(
                  'ش پ: ',
                  trans.trackingNumber!,
                  AppColor.dividerColor,
                ),
              ),
          ],
        ),
      ],
    );
  }
  Widget _buildWithdrawTransactionDetails(dynamic trans) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildMobileCardItem(
              'مبلغ: ',
              "-${trans.amount?.abs().toString().seRagham() ?? ""}",
              AppColor.accentColor,
            ),
            Expanded(
              child: Text(
                ' ریال',
                style: AppTextStyle.bodyText,
              ),
            ),
            if (trans.trackingNumber != null && trans.trackingNumber!.isNotEmpty)
              Expanded(
                child: _buildMobileCardItem(
                  'ش پ: ',
                  trans.trackingNumber!,
                  AppColor.dividerColor,
                ),
              ),
          ],
        ),
      ],
    );
  }
  Widget _buildMobileCardItem(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextStyle.labelText.copyWith(
            color: const Color(0xFF94A3B8),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Flexible(
          child: Text(
            value,
            style: AppTextStyle.labelText.copyWith(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textDirection: value.contains(RegExp(r'[0-9]')) ? TextDirection.ltr : TextDirection.rtl,
          ),
        ),
      ],
    );
  }
  Widget _buildMobileCardItemTotal(Color color1, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextStyle.labelText.copyWith(
            color: color1,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyle.labelText.copyWith(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textDirection: value.contains(RegExp(r'[0-9]')) ? TextDirection.ltr : TextDirection.rtl,
        ),
      ],
    );
  }
}
