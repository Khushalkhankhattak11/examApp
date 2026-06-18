// lib/const/app_responsive.dart

import 'package:flutter/material.dart';

/// Call once per build:  final r = AppResponsive(context);
/// Then use: r.h10, r.w20, r.fs14, etc.
class AppResponsive {
  final BuildContext _context;

  AppResponsive(this._context);

  // ── Raw dimensions ─────────────────────────────────────────
  double get screenWidth => MediaQuery.of(_context).size.width;
  double get screenHeight => MediaQuery.of(_context).size.height;

  // ── Percentage helpers ─────────────────────────────────────
  double wp(double percent) => screenWidth * percent / 100;
  double hp(double percent) => screenHeight * percent / 100;

  // ── Adaptive scale (based on 375 × 812 baseline) ──────────
  double get _ws => screenWidth / 375;
  double get _hs => screenHeight / 812;
  double get _ts => (_ws + _hs) / 2; // text scale

  // ── Vertical SizedBox heights ──────────────────────────────
  double get h10 => hp(1.23); // ~10 on 812
  double get h20 => hp(2.46); // ~20
  double get h30 => hp(3.69); // ~30
  double get h40 => hp(4.93); // ~40
  double get h50 => hp(6.16); // ~50
  double get h100 => hp(12.32); // ~100

  // ── Horizontal SizedBox widths ─────────────────────────────
  double get w10 => wp(2.67); // ~10 on 375
  double get w20 => wp(5.33); // ~20
  double get w30 => wp(8.0); // ~30
  double get w40 => wp(10.67); // ~40
  double get w50 => wp(13.33); // ~50
  double get w100 => wp(26.67); // ~100

  // ── Font sizes ─────────────────────────────────────────────
  double get fs10 => 10 * _ts;
  double get fs11 => 11 * _ts;
  double get fs12 => 12 * _ts;
  double get fs13 => 13 * _ts;
  double get fs14 => 14 * _ts;
  double get fs15 => 15 * _ts;
  double get fs16 => 16 * _ts;
  double get fs17 => 17 * _ts;
  double get fs18 => 18 * _ts;
  double get fs20 => 20 * _ts;
  double get fs22 => 22 * _ts;
  double get fs24 => 24 * _ts;
  double get fs28 => 28 * _ts;
  double get fs32 => 32 * _ts;
  double get fs36 => 36 * _ts;
  double get fs42 => 42 * _ts;
  double get fs48 => 48 * _ts;

  // ── Spacing (padding / margin) ────────────────────────────
  double get sp4 => 4 * _ws;
  double get sp8 => 8 * _ws;
  double get sp12 => 12 * _ws;
  double get sp16 => 16 * _ws;
  double get sp20 => 20 * _ws;
  double get sp24 => 24 * _ws;
  double get sp28 => 28 * _ws;
  double get sp32 => 32 * _ws;

  // ── Pre-built SizedBox widgets ─────────────────────────────
  Widget get vBox10 => SizedBox(height: h10);
  Widget get vBox20 => SizedBox(height: h20);
  Widget get vBox30 => SizedBox(height: h30);
  Widget get vBox40 => SizedBox(height: h40);
  Widget get vBox50 => SizedBox(height: h50);
  Widget get vBox100 => SizedBox(height: h100);

  Widget get hBox10 => SizedBox(width: w10);
  Widget get hBox20 => SizedBox(width: w20);
  Widget get hBox30 => SizedBox(width: w30);
  Widget get hBox40 => SizedBox(width: w40);
  Widget get hBox50 => SizedBox(width: w50);
  Widget get hBox100 => SizedBox(width: w100);
}
