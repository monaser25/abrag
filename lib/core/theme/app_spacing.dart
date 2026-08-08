import 'package:flutter/widgets.dart';

/// 4pt spacing scale from the prototype (`--s1`…`--s9`).
class AppSpacing {
  AppSpacing._();

  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s7 = 32;
  static const double s8 = 40;
  static const double s9 = 56;

  /// Screen body padding (`.body` in the prototype: 0 16px 28px).
  static const EdgeInsetsDirectional body = EdgeInsetsDirectional.fromSTEB(
    s4,
    0,
    s4,
    28,
  );

  /// App bar horizontal padding (`.appbar`: 18px).
  static const double appBarH = 18;
}
