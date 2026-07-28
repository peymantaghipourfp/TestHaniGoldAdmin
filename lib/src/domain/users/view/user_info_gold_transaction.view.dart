
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_info_detail_gold_transaction.controller.dart';
import 'package:hanigold_admin/src/domain/users/widgets/balance_user.widget.dart';
import 'package:hanigold_admin/src/widget/custom_appbar1.widget.dart';
import 'package:hanigold_admin/src/widget/hanigold_loading.widget.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../config/const/app_color.dart';
import '../../../config/const/app_text_style.dart';
import '../../../widget/app_drawer.widget.dart';
import '../../../widget/background_image_total.widget.dart';
import '../../../widget/chat_floating_button.widget.dart';
import '../../../widget/err_page.dart';
import '../../../widget/pager_widget.dart';
import '../widgets/tabel_info.widget.dart';
import '../widgets/user_info_gold_transaction/gold_transaction_desktop_body.widget.dart';
import '../widgets/user_info_gold_transaction/gold_transaction_mobile_list.widget.dart';

class UserInfoGoldTransactionView extends StatefulWidget {
  const UserInfoGoldTransactionView({super.key});

  @override
  State<UserInfoGoldTransactionView> createState() => _UserInfoGoldTransactionViewState();
}

class _UserInfoGoldTransactionViewState extends State<UserInfoGoldTransactionView> {
  final UserInfoDetailGoldTransactionController controller=Get.find<UserInfoDetailGoldTransactionController>();
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
                controller:isDesktop ? null : controller.scrollControllerMobile,
                child: Column(
                  children: [
                    isDesktop
                        ? Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(7),
                          color: AppColor.backGroundColor1
                              .withAlpha(150)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        ' حساب کاربری ${controller.headerInfoUserTransactionModel?.accountName ?? ""}',
                                        style: AppTextStyle
                                            .labelText
                                            .copyWith(
                                            fontSize:
                                            isDesktop
                                                ? 14
                                                : 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,width: 10,
                              ),
                              Row(
                                children: [
                                  // خروجی اکسل
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      showGeneralDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          barrierLabel: MaterialLocalizations
                                              .of(context)
                                              .modalBarrierDismissLabel,
                                          barrierColor: Colors
                                              .black45,
                                          transitionDuration: const Duration(
                                              milliseconds: 200),
                                          pageBuilder: (
                                              BuildContext buildContext,
                                              Animation animation,
                                              Animation secondaryAnimation) {
                                            return Center(
                                              child: Material(
                                                color: Colors
                                                    .transparent,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius
                                                          .circular(
                                                          8),
                                                      color: AppColor
                                                          .backGroundColor
                                                  ),
                                                  width: isDesktop
                                                      ? Get
                                                      .width *
                                                      0.2
                                                      : Get
                                                      .height *
                                                      0.5,
                                                  height: isDesktop
                                                      ? Get
                                                      .height *
                                                      0.5
                                                      : Get
                                                      .height *
                                                      0.7,
                                                  padding: EdgeInsets
                                                      .all(
                                                      20),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .all(
                                                            8.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment
                                                              .center,
                                                          children: [
                                                            Text(
                                                              'خروجی اکسل',
                                                              style: AppTextStyle
                                                                  .labelText
                                                                  .copyWith(
                                                                fontSize: 15,
                                                                fontWeight: FontWeight
                                                                    .normal,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        color: AppColor
                                                            .textColor,
                                                        height: 0.2,
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 10),
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                                height: 8),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  'از تاریخ',
                                                                  style: AppTextStyle
                                                                      .labelText
                                                                      .copyWith(
                                                                      fontSize: 13,
                                                                      fontWeight: FontWeight
                                                                          .normal,
                                                                      color: AppColor
                                                                          .textColor),
                                                                ),
                                                                Container(
                                                                  //height: 50,
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                      bottom: 5),
                                                                  child: IntrinsicHeight(
                                                                    child: TextFormField(
                                                                      validator: (
                                                                          value) {
                                                                        if (value ==
                                                                            null ||
                                                                            value
                                                                                .isEmpty) {
                                                                          return 'لطفا تاریخ را انتخاب کنید';
                                                                        }
                                                                        return null;
                                                                      },
                                                                      controller: controller
                                                                          .dateStartController,
                                                                      readOnly: true,
                                                                      style: AppTextStyle
                                                                          .labelText,
                                                                      decoration: InputDecoration(
                                                                        suffixIcon: Icon(
                                                                            Icons
                                                                                .calendar_month,
                                                                            color: AppColor
                                                                                .textColor),
                                                                        border: OutlineInputBorder(
                                                                          borderRadius: BorderRadius
                                                                              .circular(
                                                                              10),
                                                                        ),
                                                                        filled: true,
                                                                        fillColor: AppColor
                                                                            .textFieldColor,
                                                                        errorMaxLines: 1,
                                                                      ),
                                                                      onTap: () async {
                                                                        Jalali? pickedDate = await showPersianDatePicker(
                                                                          context: context,
                                                                          initialDate: Jalali
                                                                              .now(),
                                                                          firstDate: Jalali(
                                                                              1400,
                                                                              1,
                                                                              1),
                                                                          lastDate: Jalali(
                                                                              1450,
                                                                              12,
                                                                              29),
                                                                          initialEntryMode: PersianDatePickerEntryMode
                                                                              .calendar,
                                                                          initialDatePickerMode: PersianDatePickerMode
                                                                              .day,
                                                                          locale: Locale(
                                                                              "fa",
                                                                              "IR"),
                                                                        );
                                                                        Gregorian gregorian = pickedDate!
                                                                            .toGregorian();
                                                                        controller
                                                                            .startDateFilter
                                                                            .value =
                                                                        "${gregorian
                                                                            .year}-${gregorian
                                                                            .month
                                                                            .toString()
                                                                            .padLeft(
                                                                            2,
                                                                            '0')}-${gregorian
                                                                            .day
                                                                            .toString()
                                                                            .padLeft(
                                                                            2,
                                                                            '0')}";

                                                                        controller
                                                                            .dateStartController
                                                                            .text =
                                                                        "${pickedDate
                                                                            .year}/${pickedDate
                                                                            .month
                                                                            .toString()
                                                                            .padLeft(
                                                                            2,
                                                                            '0')}/${pickedDate
                                                                            .day
                                                                            .toString()
                                                                            .padLeft(
                                                                            2,
                                                                            '0')}";
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 8),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  'تا تاریخ',
                                                                  style: AppTextStyle
                                                                      .labelText
                                                                      .copyWith(
                                                                      fontSize: 13,
                                                                      fontWeight: FontWeight
                                                                          .normal,
                                                                      color: AppColor
                                                                          .textColor),
                                                                ),
                                                                Container(
                                                                  //height: 50,
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                      bottom: 5),
                                                                  child: IntrinsicHeight(
                                                                    child: TextFormField(
                                                                      validator: (
                                                                          value) {
                                                                        if (value ==
                                                                            null ||
                                                                            value
                                                                                .isEmpty) {
                                                                          return 'لطفا تاریخ را انتخاب کنید';
                                                                        }
                                                                        return null;
                                                                      },
                                                                      controller: controller
                                                                          .dateEndController,
                                                                      readOnly: true,
                                                                      style: AppTextStyle
                                                                          .labelText,
                                                                      decoration: InputDecoration(
                                                                        suffixIcon: Icon(
                                                                            Icons
                                                                                .calendar_month,
                                                                            color: AppColor
                                                                                .textColor),
                                                                        border: OutlineInputBorder(
                                                                          borderRadius: BorderRadius
                                                                              .circular(
                                                                              10),
                                                                        ),
                                                                        filled: true,
                                                                        fillColor: AppColor
                                                                            .textFieldColor,
                                                                        errorMaxLines: 1,
                                                                      ),
                                                                      onTap: () async {
                                                                        Jalali? pickedDate = await showPersianDatePicker(
                                                                          context: context,
                                                                          initialDate: Jalali
                                                                              .now(),
                                                                          firstDate: Jalali(
                                                                              1400,
                                                                              1,
                                                                              1),
                                                                          lastDate: Jalali(
                                                                              1450,
                                                                              12,
                                                                              29),
                                                                          initialEntryMode: PersianDatePickerEntryMode
                                                                              .calendar,
                                                                          initialDatePickerMode: PersianDatePickerMode
                                                                              .day,
                                                                          locale: Locale(
                                                                              "fa",
                                                                              "IR"),
                                                                        );
                                                                        // DateTime date=DateTime.now();
                                                                        Gregorian gregorian = pickedDate!
                                                                            .toGregorian();
                                                                        controller
                                                                            .endDateFilter
                                                                            .value =
                                                                        "${gregorian
                                                                            .year}-${gregorian
                                                                            .month
                                                                            .toString()
                                                                            .padLeft(
                                                                            2,
                                                                            '0')}-${gregorian
                                                                            .day
                                                                            .toString()
                                                                            .padLeft(
                                                                            2,
                                                                            '0')}";

                                                                        controller
                                                                            .dateEndController
                                                                            .text =
                                                                        "${pickedDate
                                                                            .year}/${pickedDate
                                                                            .month
                                                                            .toString()
                                                                            .padLeft(
                                                                            2,
                                                                            '0')}/${pickedDate
                                                                            .day
                                                                            .toString()
                                                                            .padLeft(
                                                                            2,
                                                                            '0')}";
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
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                            horizontal: 20,
                                                            vertical: 10),
                                                        width: double
                                                            .infinity,
                                                        height: 40,
                                                        child: ElevatedButton(
                                                          style: ButtonStyle(
                                                              padding: WidgetStatePropertyAll(
                                                                  EdgeInsets
                                                                      .symmetric(
                                                                      horizontal: 23,
                                                                      )),
                                                              // elevation: WidgetStatePropertyAll(5),
                                                              backgroundColor:
                                                              WidgetStatePropertyAll(
                                                                  AppColor
                                                                      .appBarColor),
                                                              shape: WidgetStatePropertyAll(
                                                                  RoundedRectangleBorder(
                                                                      side: BorderSide(
                                                                          color: AppColor
                                                                              .textColor),
                                                                      borderRadius: BorderRadius
                                                                          .circular(
                                                                          5)))),
                                                          onPressed: () async {
                                                            controller.getGoldExcel();
                                                            Get.back();
                                                          },
                                                          child: controller
                                                              .isLoading
                                                              .value
                                                              ?
                                                          CircularProgressIndicator(
                                                            valueColor: AlwaysStoppedAnimation<
                                                                Color>(
                                                                AppColor
                                                                    .textColor),
                                                          )
                                                              :
                                                          Text(
                                                            'ثبت',
                                                            style: AppTextStyle
                                                                .labelText
                                                                .copyWith(
                                                                fontSize: isDesktop
                                                                    ? 12
                                                                    : 10),
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
                                    label: Text(
                                      'خروجی اکسل',
                                      style: AppTextStyle
                                          .labelText.copyWith(color: AppColor.primaryColor,fontSize: 12),
                                    ),
                                    icon: SvgPicture.asset(
                                      'assets/svg/excel.svg',
                                      height: 24,
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  // خروجی pdf
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      showGeneralDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          barrierLabel: MaterialLocalizations.of(context)
                                              .modalBarrierDismissLabel,
                                          barrierColor: Colors.black45,
                                          transitionDuration: const Duration(milliseconds: 200),
                                          pageBuilder: (BuildContext buildContext,
                                              Animation animation,
                                              Animation secondaryAnimation) {
                                            return Center(
                                              child: Material(
                                                color: Colors.transparent,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8),
                                                      color: AppColor.backGroundColor
                                                  ),
                                                  width:isDesktop?  Get.width * 0.2:Get.height * 0.5,
                                                  height:isDesktop?  Get.height * 0.5:Get.height * 0.7,
                                                  padding: EdgeInsets.all(20),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
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
                                                      Container(
                                                        color: AppColor.textColor,height: 0.2,
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                                        child: Column(
                                                          children: [
                                                            SizedBox(height: 8),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  'از تاریخ',
                                                                  style: AppTextStyle.labelText.copyWith(fontSize: 13,
                                                                      fontWeight: FontWeight.normal,color: AppColor.textColor ),
                                                                ),
                                                                Container(
                                                                  //height: 50,
                                                                  padding: EdgeInsets.only(bottom: 5),
                                                                  child: IntrinsicHeight(
                                                                    child: TextFormField(
                                                                      validator: (value){
                                                                        if(value==null || value.isEmpty){
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
                                                                          firstDate: Jalali(1400,1,1),
                                                                          lastDate: Jalali(1450,12,29),
                                                                          initialEntryMode: PersianDatePickerEntryMode.calendar,
                                                                          initialDatePickerMode: PersianDatePickerMode.day,
                                                                          locale: Locale("fa","IR"),
                                                                        );
                                                                        Gregorian gregorian= pickedDate!.toGregorian();
                                                                        controller.startDateFilter.value =
                                                                        "${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(2, '0')}";

                                                                        controller.dateStartController.text =
                                                                        "${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(2, '0')}";

                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(height: 8),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  'تا تاریخ',
                                                                  style: AppTextStyle.labelText.copyWith(fontSize: 13,
                                                                      fontWeight: FontWeight.normal,color: AppColor.textColor ),
                                                                ),
                                                                Container(
                                                                  //height: 50,
                                                                  padding: EdgeInsets.only(bottom: 5),
                                                                  child: IntrinsicHeight(
                                                                    child: TextFormField(
                                                                      validator: (value){
                                                                        if(value==null || value.isEmpty){
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
                                                                          firstDate: Jalali(1400,1,1),
                                                                          lastDate: Jalali(1450,12,29),
                                                                          initialEntryMode: PersianDatePickerEntryMode.calendar,
                                                                          initialDatePickerMode: PersianDatePickerMode.day,
                                                                          locale: Locale("fa","IR"),
                                                                        );
                                                                        // DateTime date=DateTime.now();
                                                                        Gregorian gregorian= pickedDate!.toGregorian();
                                                                        controller.endDateFilter.value =
                                                                        "${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(2, '0')}";

                                                                        controller.dateEndController.text =
                                                                        "${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(2, '0')}";

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
                                                        margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                                        width: double.infinity,
                                                        height: 40,
                                                        child: ElevatedButton(
                                                          style: ButtonStyle(
                                                              padding: WidgetStatePropertyAll(
                                                                  EdgeInsets.symmetric(horizontal: 23)),
                                                              // elevation: WidgetStatePropertyAll(5),
                                                              backgroundColor:
                                                              WidgetStatePropertyAll(AppColor.appBarColor),
                                                              shape: WidgetStatePropertyAll(RoundedRectangleBorder(side: BorderSide(color: AppColor.textColor),
                                                                  borderRadius: BorderRadius.circular(5)))),
                                                          onPressed: () async {
                                                            controller.exportGetGoldPdf(controller.id.value.toString());
                                                            Get.back();
                                                          },
                                                          child: controller.isLoading.value?
                                                          CircularProgressIndicator(
                                                            valueColor: AlwaysStoppedAnimation<Color>(AppColor.textColor),
                                                          ) :
                                                          Text(
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
                                    label: Text(
                                      'خروجی pdf',
                                      style: AppTextStyle.labelText.copyWith(color: AppColor.textAccentColor,fontSize: 12),
                                    ),
                                    icon: SvgPicture.asset(
                                      'assets/svg/pdf.svg',
                                      height: 24,
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20),
                            height: 0.8,
                            width: Get.width,
                            color: AppColor.textColor,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor:
                                    AppColor
                                        .textFieldColor,
                                    backgroundImage: AssetImage(
                                        "assets/images/boy.png"),
                                  ),
                                  Container(
                                    // width: 300,
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                      10,
                                                      vertical:
                                                      5),
                                                  child:
                                                  Text(
                                                    'نام : ',
                                                    style: AppTextStyle.labelText.copyWith(
                                                        fontSize: isDesktop
                                                            ? 12

                                                            : 10,
                                                        fontWeight:
                                                        FontWeight.normal),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                      10,
                                                      vertical:
                                                      5),
                                                  child:
                                                  Text(
                                                    'شماره : ',
                                                    style: AppTextStyle
                                                        .labelText
                                                        .copyWith(fontSize: isDesktop ? 12 : 10),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                      10,
                                                      vertical:
                                                      5),
                                                  child:
                                                  Text(
                                                    'نقش : ',
                                                    style: AppTextStyle
                                                        .labelText
                                                        .copyWith(fontSize: isDesktop ? 12 : 10),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                      10,
                                                      vertical:
                                                      5),
                                                  child:
                                                  Text(
                                                    'تاریخ عضویت : ',
                                                    style: AppTextStyle
                                                        .labelText
                                                        .copyWith(fontSize: isDesktop ? 12 : 10),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                      10,
                                                      vertical:
                                                      5),
                                                  child:
                                                  Text(
                                                    'بیعانه : ',
                                                    style: AppTextStyle
                                                        .labelText
                                                        .copyWith(fontSize: isDesktop ? 12 : 10),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                      10,
                                                      vertical:
                                                      5),
                                                  child:
                                                  Text(
                                                    'آدرس : ',
                                                    style: AppTextStyle
                                                        .labelText
                                                        .copyWith(fontSize: isDesktop ? 12 : 10),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                      10,
                                                      vertical:
                                                      5),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(
                                                          7),
                                                      color:
                                                      AppColor.textColor),
                                                  child:
                                                  Text(
                                                    controller.headerInfoUserTransactionModel?.accountName ??
                                                        "",
                                                    style: AppTextStyle.labelText.copyWith(
                                                        fontSize: isDesktop
                                                            ? 12
                                                            : 10,
                                                        color:
                                                        AppColor.backGroundColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                      10,
                                                      vertical:
                                                      5),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(
                                                          7),
                                                      color:
                                                      AppColor.textColor),
                                                  child:
                                                  Text(
                                                    controller.headerInfoUserTransactionModel?.tell ??
                                                        "",
                                                    style: AppTextStyle.labelText.copyWith(
                                                        fontSize: isDesktop
                                                            ? 12
                                                            : 10,
                                                        color:
                                                        AppColor.backGroundColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                      10,
                                                      vertical:
                                                      5),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(
                                                          7),
                                                      color:
                                                      AppColor.textColor),
                                                  child:
                                                  Text(
                                                    controller.headerInfoUserTransactionModel?.accountGroup ??
                                                        "",
                                                    style: AppTextStyle.labelText.copyWith(
                                                        fontSize: isDesktop
                                                            ? 12
                                                            : 10,
                                                        color:
                                                        AppColor.backGroundColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                      10,
                                                      vertical:
                                                      5),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(
                                                          7),
                                                      color:
                                                      AppColor.textColor),
                                                  child:
                                                  Text(
                                                    controller.headerInfoUserTransactionModel!.startDate !=
                                                        null
                                                        ? controller.headerInfoUserTransactionModel!.startDate!.toPersianDate().toString()
                                                        :
                                                    "",
                                                    style: AppTextStyle.labelText.copyWith(
                                                        fontSize: isDesktop
                                                            ? 12
                                                            : 10,
                                                        color:
                                                        AppColor.backGroundColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                      10,
                                                      vertical:
                                                      5),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(
                                                          7),
                                                      color:
                                                      AppColor.textColor),
                                                  child:
                                                  Text(
                                                    controller.headerInfoUserTransactionModel?.deposit ??
                                                        "",
                                                    style: AppTextStyle.labelText.copyWith(
                                                        fontSize: isDesktop
                                                            ? 12
                                                            : 10,
                                                        color:
                                                        AppColor.accentColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                      10,
                                                      vertical:
                                                      5),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(
                                                          7),
                                                      color:
                                                      AppColor.textColor),
                                                  child:
                                                  Text(
                                                    controller.headerInfoUserTransactionModel?.address ??
                                                        "",
                                                    style: AppTextStyle.labelText.copyWith(
                                                        fontSize: isDesktop
                                                            ? 12
                                                            : 10,
                                                        color:
                                                        AppColor.backGroundColor),
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
                              Row(mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                              confirm:
                                              Obx(() {
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

                                                return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    if (hasTelegram)
                                                      GestureDetector(
                                                        onTap: () async {
                                                          Get.back();
                                                          await controller.sendBalanceToTelegram();
                                                        },
                                                        child: SvgPicture.asset(
                                                          'assets/svg/telegram.svg',height: 24,
                                                          colorFilter: ColorFilter.mode(Color(0xff0ab6f0), BlendMode.srcIn) ,
                                                        ),
                                                      ),
                                                    if (hasWhatsApp)
                                                      GestureDetector(
                                                        onTap: () {
                                                          // TODO: Implement WhatsApp send logic
                                                          Get.back();
                                                        },
                                                        child: SvgPicture.asset(
                                                          'assets/svg/whatsapp.svg',height: 24,
                                                        ),
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
                                            'assets/svg/send.svg',height: 22,
                                            colorFilter: ColorFilter.mode(AppColor.secondary3Color , BlendMode.srcIn),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: Get.width*0.3,
                                    child: RepaintBoundary(
                                      key: _balanceKey,
                                      child: BalanceUserWidget(title: "${controller.headerInfoUserTransactionModel?.accountName} ${Jalali.now().year}/${Jalali.now().month.toString().padLeft(2, '0')}/${Jalali.now().day.toString().padLeft(2, '0')}",
                                        listBalance:
                                        controller.balanceList,
                                        size: Get.width * 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceAround,
                            children: [
                              TabelInfoWidget(
                                list: controller.headerInfoUserTransactionModel?.inventorys??[],
                                title: 'دریافت و پرداخت',
                                title1: 'دریافت',
                                title2: 'پرداخت',
                                typeSel1: 'receive',
                                typeSel2: 'payment',
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              TabelInfoWidget(
                                list: controller
                                    .headerInfoUserTransactionModel?.orders??[],
                                title: 'خرید و فروش',
                                title1: 'خرید',
                                title2: 'فروش',
                                typeSel1: 'buy',
                                typeSel2: 'sell',
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              TabelInfoWidget(
                                list: controller
                                    .headerInfoUserTransactionModel?.remmitances??[],
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
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(7),
                          color: AppColor.backGroundColor),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
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
                                            style: AppTextStyle
                                                .labelText
                                                .copyWith(
                                                fontSize:
                                                isDesktop
                                                    ? 14
                                                    : 13),
                                          ),
                                        ),
                                        // خروجی اکسل
                                        GestureDetector(
                                          onTap: () {
                                            showGeneralDialog(
                                                context: context,
                                                barrierDismissible: true,
                                                barrierLabel: MaterialLocalizations
                                                    .of(context)
                                                    .modalBarrierDismissLabel,
                                                barrierColor: Colors
                                                    .black45,
                                                transitionDuration: const Duration(
                                                    milliseconds: 200),
                                                pageBuilder: (
                                                    BuildContext buildContext,
                                                    Animation animation,
                                                    Animation secondaryAnimation) {
                                                  return Center(
                                                    child: Material(
                                                      color: Colors
                                                          .transparent,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius
                                                                .circular(
                                                                8),
                                                            color: AppColor
                                                                .backGroundColor
                                                        ),
                                                        width: isDesktop
                                                            ? Get
                                                            .width *
                                                            0.2
                                                            : Get
                                                            .height *
                                                            0.5,
                                                        height: isDesktop
                                                            ? Get
                                                            .height *
                                                            0.5
                                                            : Get
                                                            .height *
                                                            0.7,
                                                        padding: EdgeInsets
                                                            .all(
                                                            20),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                  .all(
                                                                  8.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment
                                                                    .center,
                                                                children: [
                                                                  Text(
                                                                    'خروجی اکسل',
                                                                    style: AppTextStyle
                                                                        .labelText
                                                                        .copyWith(
                                                                      fontSize: 15,
                                                                      fontWeight: FontWeight
                                                                          .normal,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              color: AppColor
                                                                  .textColor,
                                                              height: 0.2,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 10),
                                                              child: Column(
                                                                children: [
                                                                  SizedBox(
                                                                      height: 8),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment
                                                                        .start,
                                                                    children: [
                                                                      Text(
                                                                        'از تاریخ',
                                                                        style: AppTextStyle
                                                                            .labelText
                                                                            .copyWith(
                                                                            fontSize: 13,
                                                                            fontWeight: FontWeight
                                                                                .normal,
                                                                            color: AppColor
                                                                                .textColor),
                                                                      ),
                                                                      Container(
                                                                        //height: 50,
                                                                        padding: EdgeInsets
                                                                            .only(
                                                                            bottom: 5),
                                                                        child: IntrinsicHeight(
                                                                          child: TextFormField(
                                                                            validator: (
                                                                                value) {
                                                                              if (value ==
                                                                                  null ||
                                                                                  value
                                                                                      .isEmpty) {
                                                                                return 'لطفا تاریخ را انتخاب کنید';
                                                                              }
                                                                              return null;
                                                                            },
                                                                            controller: controller
                                                                                .dateStartController,
                                                                            readOnly: true,
                                                                            style: AppTextStyle
                                                                                .labelText,
                                                                            decoration: InputDecoration(
                                                                              suffixIcon: Icon(
                                                                                  Icons
                                                                                      .calendar_month,
                                                                                  color: AppColor
                                                                                      .textColor),
                                                                              border: OutlineInputBorder(
                                                                                borderRadius: BorderRadius
                                                                                    .circular(
                                                                                    10),
                                                                              ),
                                                                              filled: true,
                                                                              fillColor: AppColor
                                                                                  .textFieldColor,
                                                                              errorMaxLines: 1,
                                                                            ),
                                                                            onTap: () async {
                                                                              Jalali? pickedDate = await showPersianDatePicker(
                                                                                context: context,
                                                                                initialDate: Jalali
                                                                                    .now(),
                                                                                firstDate: Jalali(
                                                                                    1400,
                                                                                    1,
                                                                                    1),
                                                                                lastDate: Jalali(
                                                                                    1450,
                                                                                    12,
                                                                                    29),
                                                                                initialEntryMode: PersianDatePickerEntryMode
                                                                                    .calendar,
                                                                                initialDatePickerMode: PersianDatePickerMode
                                                                                    .day,
                                                                                locale: Locale(
                                                                                    "fa",
                                                                                    "IR"),
                                                                              );
                                                                              Gregorian gregorian = pickedDate!
                                                                                  .toGregorian();
                                                                              controller
                                                                                  .startDateFilter
                                                                                  .value =
                                                                              "${gregorian
                                                                                  .year}-${gregorian
                                                                                  .month
                                                                                  .toString()
                                                                                  .padLeft(
                                                                                  2,
                                                                                  '0')}-${gregorian
                                                                                  .day
                                                                                  .toString()
                                                                                  .padLeft(
                                                                                  2,
                                                                                  '0')}";

                                                                              controller
                                                                                  .dateStartController
                                                                                  .text =
                                                                              "${pickedDate
                                                                                  .year}/${pickedDate
                                                                                  .month
                                                                                  .toString()
                                                                                  .padLeft(
                                                                                  2,
                                                                                  '0')}/${pickedDate
                                                                                  .day
                                                                                  .toString()
                                                                                  .padLeft(
                                                                                  2,
                                                                                  '0')}";
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                      height: 8),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment
                                                                        .start,
                                                                    children: [
                                                                      Text(
                                                                        'تا تاریخ',
                                                                        style: AppTextStyle
                                                                            .labelText
                                                                            .copyWith(
                                                                            fontSize: 13,
                                                                            fontWeight: FontWeight
                                                                                .normal,
                                                                            color: AppColor
                                                                                .textColor),
                                                                      ),
                                                                      Container(
                                                                        //height: 50,
                                                                        padding: EdgeInsets
                                                                            .only(
                                                                            bottom: 5),
                                                                        child: IntrinsicHeight(
                                                                          child: TextFormField(
                                                                            validator: (
                                                                                value) {
                                                                              if (value ==
                                                                                  null ||
                                                                                  value
                                                                                      .isEmpty) {
                                                                                return 'لطفا تاریخ را انتخاب کنید';
                                                                              }
                                                                              return null;
                                                                            },
                                                                            controller: controller
                                                                                .dateEndController,
                                                                            readOnly: true,
                                                                            style: AppTextStyle
                                                                                .labelText,
                                                                            decoration: InputDecoration(
                                                                              suffixIcon: Icon(
                                                                                  Icons
                                                                                      .calendar_month,
                                                                                  color: AppColor
                                                                                      .textColor),
                                                                              border: OutlineInputBorder(
                                                                                borderRadius: BorderRadius
                                                                                    .circular(
                                                                                    10),
                                                                              ),
                                                                              filled: true,
                                                                              fillColor: AppColor
                                                                                  .textFieldColor,
                                                                              errorMaxLines: 1,
                                                                            ),
                                                                            onTap: () async {
                                                                              Jalali? pickedDate = await showPersianDatePicker(
                                                                                context: context,
                                                                                initialDate: Jalali
                                                                                    .now(),
                                                                                firstDate: Jalali(
                                                                                    1400,
                                                                                    1,
                                                                                    1),
                                                                                lastDate: Jalali(
                                                                                    1450,
                                                                                    12,
                                                                                    29),
                                                                                initialEntryMode: PersianDatePickerEntryMode
                                                                                    .calendar,
                                                                                initialDatePickerMode: PersianDatePickerMode
                                                                                    .day,
                                                                                locale: Locale(
                                                                                    "fa",
                                                                                    "IR"),
                                                                              );
                                                                              // DateTime date=DateTime.now();
                                                                              Gregorian gregorian = pickedDate!
                                                                                  .toGregorian();
                                                                              controller
                                                                                  .endDateFilter
                                                                                  .value =
                                                                              "${gregorian
                                                                                  .year}-${gregorian
                                                                                  .month
                                                                                  .toString()
                                                                                  .padLeft(
                                                                                  2,
                                                                                  '0')}-${gregorian
                                                                                  .day
                                                                                  .toString()
                                                                                  .padLeft(
                                                                                  2,
                                                                                  '0')}";

                                                                              controller
                                                                                  .dateEndController
                                                                                  .text =
                                                                              "${pickedDate
                                                                                  .year}/${pickedDate
                                                                                  .month
                                                                                  .toString()
                                                                                  .padLeft(
                                                                                  2,
                                                                                  '0')}/${pickedDate
                                                                                  .day
                                                                                  .toString()
                                                                                  .padLeft(
                                                                                  2,
                                                                                  '0')}";
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
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 20,
                                                                  vertical: 10),
                                                              width: double
                                                                  .infinity,
                                                              height: 40,
                                                              child: ElevatedButton(
                                                                style: ButtonStyle(
                                                                    padding: WidgetStatePropertyAll(
                                                                        EdgeInsets
                                                                            .symmetric(
                                                                            horizontal: 23,
                                                                            )),
                                                                    // elevation: WidgetStatePropertyAll(5),
                                                                    backgroundColor:
                                                                    WidgetStatePropertyAll(
                                                                        AppColor
                                                                            .appBarColor),
                                                                    shape: WidgetStatePropertyAll(
                                                                        RoundedRectangleBorder(
                                                                            side: BorderSide(
                                                                                color: AppColor
                                                                                    .textColor),
                                                                            borderRadius: BorderRadius
                                                                                .circular(
                                                                                5)))),
                                                                onPressed: () async {
                                                                  controller.getGoldExcel();
                                                                  Get.back();
                                                                },
                                                                child: controller
                                                                    .isLoading
                                                                    .value
                                                                    ?
                                                                CircularProgressIndicator(
                                                                  valueColor: AlwaysStoppedAnimation<
                                                                      Color>(
                                                                      AppColor
                                                                          .textColor),
                                                                )
                                                                    :
                                                                Text(
                                                                  'ثبت',
                                                                  style: AppTextStyle
                                                                      .labelText
                                                                      .copyWith(
                                                                      fontSize: isDesktop
                                                                          ? 12
                                                                          : 10),
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
                                          child: SvgPicture.asset(
                                            'assets/svg/excel.svg',
                                            height: 30,
                                          ),
                                        ),
                                        SizedBox(width: 17,),
                                        // خروجی pdf
                                        GestureDetector(
                                          onTap: () {
                                            showGeneralDialog(
                                                context: context,
                                                barrierDismissible: true,
                                                barrierLabel: MaterialLocalizations.of(context)
                                                    .modalBarrierDismissLabel,
                                                barrierColor: Colors.black45,
                                                transitionDuration: const Duration(milliseconds: 200),
                                                pageBuilder: (BuildContext buildContext,
                                                    Animation animation,
                                                    Animation secondaryAnimation) {
                                                  return Center(
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(8),
                                                            color: AppColor.backGroundColor
                                                        ),
                                                        width:isDesktop?  Get.width * 0.2:Get.height * 0.5,
                                                        height:isDesktop?  Get.height * 0.5:Get.height * 0.7,
                                                        padding: EdgeInsets.all(20),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.all(8.0),
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
                                                            Container(
                                                              color: AppColor.textColor,height: 0.2,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                                              child: Column(
                                                                children: [
                                                                  SizedBox(height: 8),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        'از تاریخ',
                                                                        style: AppTextStyle.labelText.copyWith(fontSize: 13,
                                                                            fontWeight: FontWeight.normal,color: AppColor.textColor ),
                                                                      ),
                                                                      Container(
                                                                        //height: 50,
                                                                        padding: EdgeInsets.only(bottom: 5),
                                                                        child: IntrinsicHeight(
                                                                          child: TextFormField(
                                                                            validator: (value){
                                                                              if(value==null || value.isEmpty){
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
                                                                                firstDate: Jalali(1400,1,1),
                                                                                lastDate: Jalali(1450,12,29),
                                                                                initialEntryMode: PersianDatePickerEntryMode.calendar,
                                                                                initialDatePickerMode: PersianDatePickerMode.day,
                                                                                locale: Locale("fa","IR"),
                                                                              );
                                                                              Gregorian gregorian= pickedDate!.toGregorian();
                                                                              controller.startDateFilter.value =
                                                                              "${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(2, '0')}";

                                                                              controller.dateStartController.text =
                                                                              "${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(2, '0')}";

                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: 8),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        'تا تاریخ',
                                                                        style: AppTextStyle.labelText.copyWith(fontSize: 13,
                                                                            fontWeight: FontWeight.normal,color: AppColor.textColor ),
                                                                      ),
                                                                      Container(
                                                                        //height: 50,
                                                                        padding: EdgeInsets.only(bottom: 5),
                                                                        child: IntrinsicHeight(
                                                                          child: TextFormField(
                                                                            validator: (value){
                                                                              if(value==null || value.isEmpty){
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
                                                                                firstDate: Jalali(1400,1,1),
                                                                                lastDate: Jalali(1450,12,29),
                                                                                initialEntryMode: PersianDatePickerEntryMode.calendar,
                                                                                initialDatePickerMode: PersianDatePickerMode.day,
                                                                                locale: Locale("fa","IR"),
                                                                              );
                                                                              // DateTime date=DateTime.now();
                                                                              Gregorian gregorian= pickedDate!.toGregorian();
                                                                              controller.endDateFilter.value =
                                                                              "${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(2, '0')}";

                                                                              controller.dateEndController.text =
                                                                              "${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(2, '0')}";

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
                                                              margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                                              width: double.infinity,
                                                              height: 40,
                                                              child: ElevatedButton(
                                                                style: ButtonStyle(
                                                                    padding: WidgetStatePropertyAll(
                                                                        EdgeInsets.symmetric(horizontal: 23)),
                                                                    // elevation: WidgetStatePropertyAll(5),
                                                                    backgroundColor:
                                                                    WidgetStatePropertyAll(AppColor.appBarColor),
                                                                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(side: BorderSide(color: AppColor.textColor),
                                                                        borderRadius: BorderRadius.circular(5)))),
                                                                onPressed: () async {
                                                                  controller.exportGetGoldPdf(controller.id.value.toString());
                                                                  Get.back();
                                                                },
                                                                child: controller.isLoading.value?
                                                                CircularProgressIndicator(
                                                                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.textColor),
                                                                ) :
                                                                Text(
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
                                          child: SvgPicture.asset(
                                            'assets/svg/pdf.svg',
                                            height: 30,
                                          ),
                                        ),
                                      ],
                                    ),
                                    /*Row(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 80,
                                              height: 35,
                                              padding: EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  10,
                                                  vertical:
                                                  7),
                                              margin: EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  10,
                                                  vertical:
                                                  0),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      7),
                                                  color: AppColor
                                                      .primaryColor),
                                              child: Row(
                                                children: [
                                                  SvgPicture.asset(
                                                      'assets/svg/edit.svg',
                                                      height:
                                                      17,
                                                      colorFilter:
                                                      ColorFilter.mode(
                                                        AppColor
                                                            .textColor,
                                                        BlendMode
                                                            .srcIn,
                                                      )),
                                                  SizedBox(
                                                    width: 2,
                                                  ),
                                                  Text(
                                                    'ویرایش',
                                                    style: AppTextStyle
                                                        .labelText
                                                        .copyWith(
                                                        fontSize: isDesktop ? 12 : 10),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 80,
                                              height: 35,
                                              padding: EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  10,
                                                  vertical:
                                                  7),
                                              margin: EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  5,
                                                  vertical:
                                                  0),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      7),
                                                  color: AppColor
                                                      .secondary2Color),
                                              child: Row(
                                                children: [
                                                  // SvgPicture.asset('assets/svg/edit.svg',height: 17,
                                                  //     colorFilter: ColorFilter.mode(
                                                  //       AppColor.textColor,
                                                  //       BlendMode.srcIn,
                                                  //     )),
                                                  // SizedBox(width: 5,),
                                                  Text(
                                                    'صدور فاکتور',
                                                    style: AppTextStyle
                                                        .labelText
                                                        .copyWith(
                                                        fontSize: isDesktop ? 12 : 10),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 35,
                                              padding: EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  10,
                                                  vertical:
                                                  7),
                                              margin: EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  5,
                                                  vertical:
                                                  0),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      7),
                                                  color: AppColor
                                                      .accentColor),
                                              child: Row(
                                                children: [
                                                  // SvgPicture.asset('assets/svg/edit.svg',height: 17,
                                                  //     colorFilter: ColorFilter.mode(
                                                  //       AppColor.textColor,
                                                  //       BlendMode.srcIn,
                                                  //     )),
                                                  // SizedBox(width: 5,),
                                                  Text(
                                                    'صدور فاکتور جدید',
                                                    style: AppTextStyle
                                                        .labelText
                                                        .copyWith(
                                                        fontSize: isDesktop ? 12 : 10),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // صدور فاکتور جدید
                                            ElevatedButton(
                                              style: ButtonStyle(
                                                  padding: WidgetStatePropertyAll(
                                                    EdgeInsets.symmetric(
                                                        horizontal: 15,vertical: 7
                                                    ),
                                                  ),
                                                  elevation: WidgetStatePropertyAll(5),
                                                  fixedSize: WidgetStatePropertyAll(Size(120,30)),
                                                  backgroundColor:
                                                  WidgetStatePropertyAll(AppColor.accentColor),
                                                  shape: WidgetStatePropertyAll(
                                                      RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(5)))),
                                              onPressed: () {
                                                Get.toNamed('/invoicePreview', parameters: {
                                                  'accountId': controller.id.value.toString(),
                                                });
                                              },
                                              child: Text(
                                                'صدور فاکتور جدید',
                                                style: AppTextStyle.labelText.copyWith(color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),*/
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColor.secondary3Color.withAlpha(20),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF64748B)),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      /*CircleAvatar(
                                        radius: 40,
                                        backgroundColor:
                                        AppColor
                                            .textFieldColor,
                                        backgroundImage:
                                        AssetImage(
                                            "assets/images/boy.png"),
                                      ),*/
                                      Container(
                                        // width: 300,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal:
                                                          10,
                                                          vertical:
                                                          5),
                                                      child:
                                                      Text(
                                                        'نام : ',
                                                        style: AppTextStyle.labelText.copyWith(
                                                            fontSize: isDesktop ? 12 : 10,
                                                            fontWeight: FontWeight.normal),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal:
                                                          10,
                                                          vertical:
                                                          5),
                                                      child:
                                                      Text(
                                                        'شماره : ',
                                                        style: AppTextStyle
                                                            .labelText
                                                            .copyWith(fontSize: isDesktop ? 12 : 10),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal:
                                                          10,
                                                          vertical:
                                                          5),
                                                      child:
                                                      Text(
                                                        'نقش : ',
                                                        style: AppTextStyle
                                                            .labelText
                                                            .copyWith(fontSize: isDesktop ? 12 : 10),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal:
                                                          10,
                                                          vertical:
                                                          5),
                                                      child:
                                                      Text(
                                                        'تاریخ عضویت : ',
                                                        style: AppTextStyle
                                                            .labelText
                                                            .copyWith(fontSize: isDesktop ? 12 : 10),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal:
                                                          10,
                                                          vertical:
                                                          5),
                                                      child:
                                                      Text(
                                                        'بیعانه : ',
                                                        style: AppTextStyle
                                                            .labelText
                                                            .copyWith(fontSize: isDesktop ? 12 : 10),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal:
                                                          10,
                                                          vertical:
                                                          5),
                                                      child:
                                                      Text(
                                                        'آدرس : ',
                                                        style: AppTextStyle
                                                            .labelText
                                                            .copyWith(fontSize: isDesktop ? 12 : 10),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Row(mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Container(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal:
                                                            10,
                                                            vertical:
                                                            5),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius.circular(7),
                                                            color: AppColor.textColor),
                                                        child:
                                                        Text(
                                                          controller.headerInfoUserTransactionModel?.accountName ??
                                                              "",
                                                          style: AppTextStyle.labelText.copyWith(
                                                              fontSize: isDesktop ? 12 : 10,
                                                              color: AppColor.backGroundColor),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal:
                                                          10,
                                                          vertical:
                                                          5),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius.circular(7),
                                                          color: AppColor.textColor),
                                                      child:
                                                      Text(
                                                        controller.headerInfoUserTransactionModel?.tell ??
                                                            "",
                                                        style: AppTextStyle.labelText.copyWith(
                                                            fontSize: isDesktop ? 12 : 10,
                                                            color: AppColor.backGroundColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal:
                                                          10,
                                                          vertical:
                                                          5),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius.circular(7),
                                                          color: AppColor.textColor),
                                                      child:
                                                      Text(
                                                        controller.headerInfoUserTransactionModel?.accountGroup ??
                                                            "",
                                                        style: AppTextStyle.labelText.copyWith(
                                                            fontSize: isDesktop ? 12 : 10,
                                                            color: AppColor.backGroundColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal:
                                                          10,
                                                          vertical:
                                                          5),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius.circular(7),
                                                          color: AppColor.textColor),
                                                      child:
                                                      Text(
                                                        // controller.headerInfoUserTransactionModel!.startDate!.toPersianDate().toString(),
                                                        "",
                                                        style: AppTextStyle.labelText.copyWith(
                                                            fontSize: isDesktop ? 12 : 10,
                                                            color: AppColor.backGroundColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal:
                                                          10,
                                                          vertical:
                                                          5),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius.circular(7),
                                                          color: AppColor.textColor),
                                                      child:
                                                      Text(
                                                        controller.headerInfoUserTransactionModel?.deposit ??
                                                            "",
                                                        style: AppTextStyle.labelText.copyWith(
                                                            fontSize: isDesktop ? 12 : 10,
                                                            color: AppColor.accentColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal:
                                                          10,
                                                          vertical:
                                                          5),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius.circular(7),
                                                          color: AppColor.textColor),
                                                      child:
                                                      Text(
                                                        controller.headerInfoUserTransactionModel?.address ??
                                                            "",
                                                        style: AppTextStyle.labelText.copyWith(
                                                            fontSize: isDesktop ? 12 : 10,
                                                            color: AppColor.backGroundColor),
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
                                  SizedBox(
                                    height: 10,
                                  ),

                                  Column(mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                                    confirm:
                                                    Obx(() {
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

                                                      return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          if (hasTelegram)
                                                            GestureDetector(
                                                              onTap: () async {
                                                                Get.back();
                                                                await controller.sendBalanceToTelegram();
                                                              },
                                                              child: SvgPicture.asset(
                                                                'assets/svg/telegram.svg',height: 24,
                                                                colorFilter: ColorFilter.mode(Color(0xff0ab6f0), BlendMode.srcIn) ,
                                                              ),
                                                            ),
                                                          if (hasWhatsApp)
                                                            GestureDetector(
                                                              onTap: () {
                                                                // TODO: Implement WhatsApp send logic
                                                                Get.back();
                                                              },
                                                              child: SvgPicture.asset(
                                                                'assets/svg/whatsapp.svg',height: 24,
                                                              ),
                                                            ),
                                                        ],
                                                      );
                                                    })
                                                );
                                              }
                                            },
                                            child: Tooltip(
                                              message: "ارسال مانده حساب",
                                              child: SvgPicture.asset(
                                                'assets/svg/send.svg',height: 22,
                                                colorFilter: ColorFilter.mode(AppColor.secondary3Color , BlendMode.srcIn) ,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      RepaintBoundary(
                                        key: _balanceKey,
                                        child: BalanceUserWidget(title:" ${(controller.headerInfoUserTransactionModel?.accountName?.length ?? 0) > 27 ?
                                        controller.headerInfoUserTransactionModel?.accountName?.substring(0, 27) : controller.headerInfoUserTransactionModel?.accountName}"
                                            "${Jalali.now().year}/${Jalali.now().month.toString().padLeft(2, '0')}/${Jalali.now().day.toString().padLeft(2, '0')}",
                                          listBalance: controller
                                              .balanceList,
                                          size: Get.width * 0.9,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            /*Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceAround,
                                  children: [
                                    TabelInfoWidget(
                                      list: controller
                                          .headerInfoUserTransactionModel?.inventorys ?? [],
                                      title:
                                      'دریافت و پرداخت',
                                      title1: 'دریافت',
                                      title2: 'پرداخت',
                                      typeSel1: 'receive',
                                      typeSel2: 'payment',
                                    ),
                                    // / SizedBox(width: 30,),
                                    TabelInfoWidget(
                                      list: controller
                                          .headerInfoUserTransactionModel?.orders ?? [],
                                      title: 'خرید و فروش',
                                      title1: 'خرید',
                                      title2: 'فروش',
                                      typeSel1: 'buy',
                                      typeSel2: 'sell',
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                ),
                                TabelInfoWidget(
                                  list: controller
                                      .headerInfoUserTransactionModel?.remmitances ?? [],
                                  title: 'حواله',
                                  title1: 'حواله',
                                  title2: 'رسید',
                                  typeSel1: 'issue',
                                  typeSel2: 'reciept',
                                ),
                              ],
                            ),*/
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
                    ):
                    controller.transactionInfoGoldList.isEmpty
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
                              controller.hasActiveFilters()
                                  ? 'نتیجه فیلتر خالی است'
                                  : 'هیچ تراکنشی یافت نشد',
                              style: AppTextStyle.labelText.copyWith(
                                fontSize: 16,
                                color: AppColor.textColor.withOpacity(0.7),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              controller.hasActiveFilters()
                                  ? 'لطفاً فیلترهای خود را تغییر دهید'
                                  : 'تراکنش‌های طلا در این حساب موجود نیست',
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
                              child: Text('تلاش مجدد',
                                style: AppTextStyle.bodyText.copyWith(
                                  fontSize: 16,
                                  color: AppColor.accentColor,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        :
                    isDesktop ?
                    GoldTransactionDesktopBody(controller: controller) :
                    GoldTransactionMobileList(controller: controller),
                  ],
                ),
              ),
            )
                :
            ErrPage(
              callback: () {
                controller.getTransactionInfoGoldListPager(controller.id.value.toString());
                controller.clearFilter();
              },
              title: "خطا در دریافت لیست تراکنش ها",
              des: 'برای دریافت لیست تراکنش ها مجددا تلاش کنید',
            ),
          ),
          isDesktop ?
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              controller.paginated.value != null ? Container(
                  height: 70,
                  margin: EdgeInsets.symmetric(
                      horizontal: 50, vertical: 10),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  //color: AppColor.appBarColor.withOpacity(0.5),
                  alignment: Alignment.bottomCenter,
                  child: PagerWidget(
                    countPage: controller.paginated.value
                        ?.totalCount ?? 0, callBack: (int index) {
                    controller.isChangePage(index);
                  },)) : SizedBox(),
            ],
          ) : SizedBox.shrink(),
        ],
      ),
      floatingActionButton: const ChatFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    ));
  }



  /*void _showImageGallery(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 200), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: AppColor.backGroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.photo_library,
                        color: AppColor.primaryColor,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'گالری تصاویر',
                        style: AppTextStyle.smallTitleText.copyWith(
                          color: AppColor.primaryColor,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(Icons.close, color: AppColor.textColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Image viewer
                  SizedBox(
                    width: 500,
                    height: 500,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: controller.pageController,
                          itemCount: controller.imageList.length,
                          onPageChanged: (index) =>
                          controller.currentImagePage.value = index,
                          itemBuilder: (context, index) {
                            final attachment = controller.imageList[index];
                            return Column(
                              children: [
                                if (kIsWeb)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 50),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.download, color: AppColor.dividerColor),
                                          onPressed: () => controller.downloadImage(attachment),
                                        ),
                                      ],
                                    ),
                                  ),
                                Expanded(
                                  child: Image.network(
                                    "${BaseUrl.baseUrl}Attachment/downloadAttachment?fileName=$attachment",
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(child: CircularProgressIndicator());
                                    },
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.error, color: Colors.red),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // Navigation arrows
                        Obx(() => Positioned(
                          left: 10,
                          top: 0,
                          bottom: 0,
                          child: Visibility(
                            visible: controller.currentImagePage.value > 0,
                            child: IconButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(Colors.black54),
                                shape: WidgetStateProperty.all(CircleBorder()),
                                padding: WidgetStateProperty.all(EdgeInsets.all(8)),
                              ),
                              icon: Icon(Icons.chevron_left, color: Colors.white, size: 40),
                              onPressed: () {
                                controller.pageController.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ),
                        )),

                        Obx(() => Positioned(
                          right: 10,
                          top: 0,
                          bottom: 0,
                          child: Visibility(
                            visible: controller.currentImagePage.value <
                                (controller.imageList.length - 1),
                            child: IconButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(Colors.black54),
                                shape: WidgetStateProperty.all(CircleBorder()),
                                padding: WidgetStateProperty.all(EdgeInsets.all(8)),
                              ),
                              icon: Icon(Icons.chevron_right, color: Colors.white, size: 40),
                              onPressed: () {
                                controller.pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),

                  // Page indicators
                  SizedBox(height: 16),
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      controller.imageList.length,
                          (index) => Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.currentImagePage.value == index
                              ? AppColor.primaryColor
                              : Colors.grey,
                        ),
                      ),
                    ),
                  )),

                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text("بستن", style: AppTextStyle.bodyText),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }*/

/*Widget buildPaginationControls() {
    return Obx(() => Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: controller.currentPageIndex.value > 1
                ? controller.previousPage
                : null,
          ),
          Text(
            'صفحه ${controller.currentPageIndex.value}',
            style: AppTextStyle.bodyText,
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed:
            controller.hasMore.value ? controller.nextPage : null,
          ),
        ],
      ),
    ));
  }*/
}

