import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory BloodSupplyEntry.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BloodSupplyEntry(
      type: d['type'] as String? ?? doc.id,
      percentage: (d['percentage'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'type': type,
        'percentage': percentage,
      };
}

// ── Seed data — written once to Firestore, editable by admin in console ───────
final List<Map<String, dynamic>> seedBloodSupply = [
  {'type': 'A+', 'percentage': 72},
  {'type': 'A−', 'percentage': 34},
  {'type': 'B+', 'percentage': 58},
  {'type': 'B−', 'percentage': 21},
  {'type': 'AB+', 'percentage': 65},
  {'type': 'AB−', 'percentage': 18},
  {'type': 'O+', 'percentage': 47},
  {'type': 'O−', 'percentage': 8},
];
