import 'package:flutter/widgets.dart';

/// Radius scale derived from the logo's rounded square (base 18).
class AppRadius {
  AppRadius._();

  static const double sm = 9; // base * .5 — buttons, inputs, small cards
  static const double md = 18; // base — cards
  static const double lg = 27; // base * 1.5 — heroes, sheets
  static const double pill = 999;

  // Component-specific radii from the prototype chrome.
  static const double iconTile = 14;
  static const double iconTileSm = 11;
  static const double iconButton = 13;
  static const double fab = 18;
  static const double skeleton = 10;
  static const double paper = 14;
  static const double emptyOrb = 28;
  static const double segTrack = 14;
  static const double segItem = 10;

  static const BorderRadius rSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius rMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius rLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius rPill = BorderRadius.all(Radius.circular(pill));
}
