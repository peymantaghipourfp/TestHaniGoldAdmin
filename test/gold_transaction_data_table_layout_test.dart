import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_info_detail_gold_transaction.controller.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_desktop_body.widget.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() {
  tearDown(Get.reset);

  testWidgets(
    'GoldTransactionDesktopBody build tree has no horizontal SingleChildScrollView',
    (tester) async {
      final controller = UserInfoDetailGoldTransactionController();

      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        GetMaterialApp(
          home: ResponsiveBreakpoints.builder(
            child: Scaffold(
              body: GoldTransactionDesktopBody(controller: controller),
            ),
            breakpoints: const [
              Breakpoint(start: 0, end: 450, name: MOBILE),
              Breakpoint(start: 451, end: 800, name: TABLET),
              Breakpoint(start: 801, end: 1920, name: DESKTOP),
              Breakpoint(start: 1921, end: double.infinity, name: '4K'),
            ],
          ),
        ),
      );
      await tester.pump();

      final horizontalScrollViews = find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.horizontal,
      );

      expect(horizontalScrollViews, findsNothing);
    },
  );
}
