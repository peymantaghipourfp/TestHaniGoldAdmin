import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hanigold_admin/src/domain/users/controller/user_info_detail_gold_transaction.controller.dart';
import 'package:hanigold_admin/src/domain/users/model/transaction_report_gold.model.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_data_table.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_description_cell.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_desktop_body.widget.dart';
import 'package:hanigold_admin/src/domain/users/widgets/user_info_gold_transaction/gold_transaction_grouped_header.widget.dart';
import 'package:responsive_framework/responsive_framework.dart';

TransactionReportGoldModel _denseSellTx({
  required DateTime date,
  String itemName =
      'طلای آبشده ۱۸ عیار آزمایشگاهی با نام بسیار بلند برای تست overflow شرح',
}) {
  return TransactionReportGoldModel.fromJson({
    'date': date.toIso8601String(),
    'type': 'sell',
    'amount': 12.345,
    'mesghalPrice': 123456789,
    'rowNum': 1,
    'checked': false,
    'toAccount': {'name': 'مقصد'},
    'account': {'name': 'مبدا'},
    'item': {
      'name': itemName,
      'id': 1,
      'itemUnit': {'id': 2, 'name': 'گرم'},
    },
  });
}

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
      // SelectableText has no overflow in this SDK; Flexible/_fitRow + maxLines
      // prevent RenderFlex overflow (ClipRect clips residual paint).
      expect(source.contains('_fitRow'), isTrue);
      expect(source.contains('Flexible'), isTrue);

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

  testWidgets(
    'dense description at ~1280 width budget does not throw overflow',
    (tester) async {
      FlutterErrorDetails? overflowError;
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.exceptionAsString();
        if (msg.contains('overflowed') || msg.contains('RenderFlex')) {
          overflowError = details;
        }
        oldHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final trans = _denseSellTx(date: DateTime(2024, 6, 15, 10, 30));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 160,
                child: GoldTransactionDescriptionCell(
                  trans: trans,
                  maxWidth: 160,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(overflowError, isNull);

      final horizontal = find.byWidgetPredicate(
        (w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      );
      expect(horizontal, findsNothing);
    },
  );

  test(
    'onSortColum at visual index 2 sorts by date/time',
    () {
      final controller = UserInfoDetailGoldTransactionController();
      final older = _denseSellTx(date: DateTime(2024, 1, 1));
      final newer = _denseSellTx(date: DateTime(2024, 6, 1));
      controller.transactionInfoGoldList.assignAll([newer, older]);

      controller.onSortColum(
        UserInfoDetailGoldTransactionController.dateSortColumnIndex,
        true,
      );
      expect(controller.transactionInfoGoldList[0].date, older.date);
      expect(controller.transactionInfoGoldList[1].date, newer.date);

      controller.onSortColum(
        GoldTransactionDataTable.dateSortVisualIndex,
        false,
      );
      expect(controller.transactionInfoGoldList[0].date, newer.date);
      expect(controller.transactionInfoGoldList[1].date, older.date);

      expect(
        UserInfoDetailGoldTransactionController.dateSortColumnIndex,
        GoldTransactionDataTable.dateSortVisualIndex,
      );
    },
  );
}
