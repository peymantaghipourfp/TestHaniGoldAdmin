import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_info_detail_gold_transaction.controller.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_data_table.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_desktop_body.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_grouped_header.widget.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() {
  tearDown(Get.reset);

  Future<void> pumpDesktopBody(WidgetTester tester) async {
    final controller = UserInfoDetailGoldTransactionController();

    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      GetMaterialApp(
        home: ResponsiveBreakpoints.builder(
          child: Scaffold(
            body: SingleChildScrollView(
              child: GoldTransactionDesktopBody(controller: controller),
            ),
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
  }

  testWidgets(
    'GoldTransactionDesktopBody build tree has no horizontal SingleChildScrollView',
    (tester) async {
      await pumpDesktopBody(tester);

      final horizontalScrollViews = find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.horizontal,
      );

      expect(horizontalScrollViews, findsNothing);
    },
  );

  testWidgets(
    'GoldTransactionDataTable has 14 columns with 4 grouped + 4 مانده headers',
    (tester) async {
      await pumpDesktopBody(tester);

      expect(
        find.byKey(const Key('gold_transaction_data_table')),
        findsOneWidget,
      );
      expect(find.byType(GoldTransactionDataTable), findsOneWidget);

      final dataTable = tester.widget<DataTable>(find.byType(DataTable));
      expect(dataTable.columns.length, 14);

      expect(find.byType(GoldTransactionGroupedHeader), findsNWidgets(4));
      expect(find.text('طلا'), findsOneWidget);
      expect(find.text('تمام‌سکه'), findsOneWidget);
      expect(find.text('نیم‌ربع'), findsOneWidget);
      expect(find.text('ریال'), findsOneWidget);

      expect(find.text('مانده طلایی'), findsOneWidget);
      expect(find.text('مانده تمام‌سکه'), findsOneWidget);
      expect(find.text('مانده نیم‌ربع'), findsOneWidget);
      expect(find.text('مانده ریالی'), findsOneWidget);

      expect(find.text('طلا بدهکار'), findsNothing);
      expect(find.text('طلا بستانکار'), findsNothing);

      expect(find.text('تاریخ/ساعت'), findsOneWidget);
      expect(find.text('ساعت'), findsNothing);
    },
  );

  testWidgets(
    'description cell avoids softWrap true; SelectableText uses maxLines 1',
    (tester) async {
      await pumpDesktopBody(tester);

      final descFile = File(
        'lib/src/domain/users/widgets/user_info_gold_transaction/'
        'gold_transaction_description_cell.widget.dart',
      );
      expect(descFile.existsSync(), isTrue);
      final source = descFile.readAsStringSync();
      expect(source.contains('softWrap: true'), isFalse);
      expect(source.contains('maxLines: 1'), isTrue);

      expect(find.text('شرح'), findsOneWidget);
      final sharh = tester.widget<Text>(find.text('شرح'));
      expect(sharh.softWrap, isFalse);

      final horizontal = find.byWidgetPredicate(
        (w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      );
      expect(horizontal, findsNothing);
    },
  );
}
