part of '../configs.dart';

/// [AppText] is a class that contains the text styles for the app.
class AppText {
  /// Font Size 26
  static late TextStyle h1;

  /// Font Size 26, Bold
  static late TextStyle h1b;

  /// Font Size 20
  static late TextStyle h2;

  /// Font Size 20, Bold
  static late TextStyle h2b;

  /// Font Size 16
  static late TextStyle h3;

  /// Font Size 16, Bold
  static late TextStyle h3b;

  /// Font Size 14
  static late TextStyle b1;

  /// Font Size 14, Bold
  static late TextStyle b1b;

  /// Font Size 12
  static late TextStyle b2;

  /// Font Size 12, Bold
  static late TextStyle b2b;

  /// Font Size 10
  static late TextStyle l1;

  /// Font Size 10, Bold
  static late TextStyle l1b;

  /// Large streak counter & stat displays (Bricolage Grotesque 28pt Bold)
  static late TextStyle stat;

  /// Hero streak counter display (Bricolage Grotesque 56pt Heavy)
  static late TextStyle heroStat;

  static void init() {
    const base = TextStyle(fontFamily: FontFamily.hanken);
    const headingBase = TextStyle(fontFamily: FontFamily.bricolage);

    heroStat = headingBase.copyWith(
      fontSize: 56,
      fontWeight: FontWeight.w800,
    );

    stat = headingBase.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w700,
    );

    h1 = headingBase.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w700,
    );

    h1b = h1.copyWith(fontWeight: FontWeight.w800);

    h2 = headingBase.copyWith(fontSize: 20, fontWeight: FontWeight.w600);
    h2b = h2.copyWith(fontWeight: FontWeight.w700);

    h3 = headingBase.copyWith(fontSize: 16, fontWeight: FontWeight.w600);
    h3b = h3.copyWith(fontWeight: FontWeight.w700);

    b1 = base.copyWith(fontSize: 14, fontWeight: FontWeight.w400);
    b1b = base.copyWith(fontSize: 14, fontWeight: FontWeight.w600);

    b2 = base.copyWith(fontSize: 12, fontWeight: FontWeight.w400);
    b2b = base.copyWith(fontSize: 12, fontWeight: FontWeight.w600);

    l1 = base.copyWith(fontSize: 11, fontWeight: FontWeight.w500);
    l1b = base.copyWith(fontSize: 11, fontWeight: FontWeight.w600);
  }
}
