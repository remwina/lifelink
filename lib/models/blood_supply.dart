import 'package:flutter/material.dart';
import '../core/theme.dart';

class BloodSupplyEntry {
  final String type;
  final int percentage;

  const BloodSupplyEntry({required this.type, required this.percentage});

  bool get isLow => percentage < 20;
  bool get isMid => percentage >= 20 && percentage < 50;
  bool get isHigh => percentage >= 50;

  Color get levelColor {
    if (isHigh) return AppColors.levelHigh;
    if (isMid) return AppColors.levelMid;
    return AppColors.levelLow;
  }
}

final List<BloodSupplyEntry> bloodSupplyData = const [
  BloodSupplyEntry(type: 'A+', percentage: 72),
  BloodSupplyEntry(type: 'A−', percentage: 34),
  BloodSupplyEntry(type: 'B+', percentage: 58),
  BloodSupplyEntry(type: 'B−', percentage: 21),
  BloodSupplyEntry(type: 'AB+', percentage: 65),
  BloodSupplyEntry(type: 'AB−', percentage: 18),
  BloodSupplyEntry(type: 'O+', percentage: 47),
  BloodSupplyEntry(type: 'O−', percentage: 8),
];
