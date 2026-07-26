import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';

/// Shared panel / toolbar decorations for the user-balance transaction list.
class UserBalancePageChrome {
  UserBalancePageChrome._();

  static const double radiusLg = 16;
  static const double radiusMd = 12;
  static const Color slateBorder = Color(0xFF64748B);

  static BoxDecoration panelDecoration({Color? color}) => BoxDecoration(
        color: (color ?? AppColor.backGroundColor1).withAlpha(150),
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: slateBorder.withAlpha(120)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  /// Soft toolbar strip — matches order/withdraw `appBarColor.withAlpha(30)` panels.
  static BoxDecoration toolbarDecoration({Color? color}) => BoxDecoration(
        color: (color ?? AppColor.appBarColor).withAlpha(30),
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: slateBorder.withAlpha(120)),
      );
}
