import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/blood_supply.dart';
import '../../models/booking.dart';
import '../../models/donation_center.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../services/firestore_service.dart';

class AdminScreen extends StatefulWidget {
  final bool demoMode;
  const AdminScreen({super.key, this.demoMode = false});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Admin Panel',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded,
                color: AppColors.textMuted, size: 20),
            tooltip: 'Sign out',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Sign out',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                  content: Text('Sign out of admin panel?',
                      style: GoogleFonts.dmSans()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text('Sign out',
                          style:
                              GoogleFonts.dmSans(color: AppColors.danger)),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await context.read<ap.AuthProvider>().signOut();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle:
              GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Blood Supply'),
            Tab(text: 'Centers'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          const _BloodSupplyTab(),
          const _CentersTab(),
          _AnalyticsTab(demoMode: widget.demoMode),
        ],
      ),
    );
  }
}

// ── Blood Supply Tab ──────────────────────────────────────────────────────────
class _BloodSupplyTab extends StatefulWidget {
  const _BloodSupplyTab();

  @override
  State<_BloodSupplyTab> createState() => _BloodSupplyTabState();
}

class _BloodSupplyTabState extends State<_BloodSupplyTab> {
  final _db = FirestoreService();
  List<BloodSupplyEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final snap =
          await _db.bloodSupplyCollection.orderBy('type').get();
      setState(() {
        _entries =
            snap.docs.map(BloodSupplyEntry.fromFirestore).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load: $e'),
          backgroundColor: AppColors.danger,
        ));
      }
    }
  }

  Future<void> _update(BloodSupplyEntry entry, int newPct) async {
    try {
      await _db.bloodSupplyCollection
          .doc(entry.type)
          .update({'percentage': newPct});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${entry.type} updated to $newPct%'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ));
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Update failed: $e'),
          backgroundColor: AppColors.danger,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFCC80)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.warning, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tap any blood type to edit its supply level.',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppColors.warning),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._entries.map((e) => _BloodSupplyRow(
              entry: e,
              onEdit: (pct) => _update(e, pct),
            )),
      ],
    );
  }
}

class _BloodSupplyRow extends StatelessWidget {
  final BloodSupplyEntry entry;
  final void Function(int) onEdit;

  const _BloodSupplyRow({required this.entry, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Blood type badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: entry.levelColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                entry.type,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: entry.levelColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${entry.percentage}%',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: entry.levelColor,
                      ),
                    ),
                    _StatusChip(entry: entry),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.percentage / 100,
                    backgroundColor: AppColors.levelBg,
                    color: entry.levelColor,
                    minHeight: 7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_rounded,
                color: AppColors.primary, size: 20),
            onPressed: () => _showEditDialog(context),
            tooltip: 'Edit ${entry.type}',
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    int current = entry.percentage;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(
            'Edit ${entry.type} Supply',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$current%',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 48,
                  color: entry.levelColor,
                ),
              ),
              Slider(
                value: current.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                activeColor: entry.levelColor,
                label: '$current%',
                onChanged: (v) => setS(() => current = v.round()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickBtn(label: 'Critical (5%)', value: 5, onTap: () => setS(() => current = 5)),
                  _QuickBtn(label: 'Low (15%)', value: 15, onTap: () => setS(() => current = 15)),
                  _QuickBtn(label: 'Ok (60%)', value: 60, onTap: () => setS(() => current = 60)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                onEdit(current);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onTap;
  const _QuickBtn(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 11, color: AppColors.textSecondary)),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final BloodSupplyEntry entry;
  const _StatusChip({required this.entry});

  @override
  Widget build(BuildContext context) {
    final label = entry.isLow
        ? 'LOW'
        : entry.isMid
            ? 'MID'
            : 'GOOD';
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: entry.levelColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: entry.levelColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Centers Tab ───────────────────────────────────────────────────────────────
class _CentersTab extends StatefulWidget {
  const _CentersTab();

  @override
  State<_CentersTab> createState() => _CentersTabState();
}

class _CentersTabState extends State<_CentersTab> {
  final _db = FirestoreService();
  List<_CenterEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final snap =
          await _db.centersCollection.orderBy('distanceKm').get();
      setState(() {
        _entries = snap.docs.map((doc) {
          final c = DonationCenter.fromFirestore(doc);
          return _CenterEntry(id: doc.id, center: c);
        }).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load: $e'),
          backgroundColor: AppColors.danger,
        ));
      }
    }
  }

  Future<void> _updateSlot(String docId, SlotStatus status) async {
    try {
      await _db.centersCollection
          .doc(docId)
          .update({'slotStatus': status.name});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Slot status updated to ${status.name}'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ));
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Update failed: $e'),
          backgroundColor: AppColors.danger,
        ));
      }
    }
  }

  Future<void> _updateHours(String docId, String hours) async {
    try {
      await _db.centersCollection.doc(docId).update({'hours': hours});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Hours updated'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ));
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Update failed: $e'),
          backgroundColor: AppColors.danger,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: _entries
          .map((e) => _CenterCard(
                entry: e,
                onSlotChange: (s) => _updateSlot(e.id, s),
                onHoursChange: (h) => _updateHours(e.id, h),
              ))
          .toList(),
    );
  }
}

class _CenterEntry {
  final String id;
  final DonationCenter center;
  const _CenterEntry({required this.id, required this.center});
}

class _CenterCard extends StatelessWidget {
  final _CenterEntry entry;
  final void Function(SlotStatus) onSlotChange;
  final void Function(String) onHoursChange;

  const _CenterCard({
    required this.entry,
    required this.onSlotChange,
    required this.onHoursChange,
  });

  Color _slotColor(SlotStatus s) {
    switch (s) {
      case SlotStatus.open:
        return AppColors.success;
      case SlotStatus.limited:
        return AppColors.warning;
      case SlotStatus.full:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = entry.center;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + distance
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_hospital_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${c.address} · ${c.distanceLabel}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Slot status selector
          Text('Slot Status',
              style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: SlotStatus.values.map((s) {
              final selected = c.slotStatus == s;
              final color = _slotColor(s);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: s != SlotStatus.full ? 8 : 0),
                  child: GestureDetector(
                    onTap: selected ? null : () => onSlotChange(s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withValues(alpha: 0.12)
                            : AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? color : AppColors.border,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          s.name[0].toUpperCase() + s.name.substring(1),
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? color
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Hours editor
          Text('Operating Hours',
              style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    c.hours,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit_rounded,
                    color: AppColors.primary, size: 20),
                onPressed: () => _showHoursDialog(context, c.hours),
                tooltip: 'Edit hours',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHoursDialog(BuildContext context, String currentHours) {
    final ctrl = TextEditingController(text: currentHours);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Operating Hours',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: GoogleFonts.dmSans(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g. Open until 8 PM',
            hintStyle: GoogleFonts.dmSans(color: AppColors.textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = ctrl.text.trim();
              if (val.isNotEmpty) {
                Navigator.of(ctx).pop();
                onHoursChange(val);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ── Analytics Tab ──────────────────────────────────────────────────────────────
class _AnalyticsTab extends StatefulWidget {
  final bool demoMode;
  const _AnalyticsTab({this.demoMode = false});

  @override
  State<_AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<_AnalyticsTab> {
  List<Map<String, dynamic>> _users = [];
  List<Appointment> _appointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    if (widget.demoMode) {
      _loadDemoData();
      return;
    }
    try {
      final db = FirestoreService();
      final userDocs = await db.getAllUsers();
      final appointmentDocs = await db.getAllAppointments();
      setState(() {
        _users = userDocs.map((d) => d.data()).toList();
        _appointments =
            appointmentDocs.map((d) => Appointment.fromFirestore(d)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load analytics: ${e.toString()}'),
          backgroundColor: AppColors.danger,
        ));
      }
    }
  }

  void _loadDemoData() {
    final now = DateTime.now();
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final demoUsers = <Map<String, dynamic>>[
      {'bloodType': 'O+'},
      {'bloodType': 'A+'},
      {'bloodType': 'B+'},
      {'bloodType': 'O+'},
      {'bloodType': 'AB+'},
      {'bloodType': 'A+'},
      {'bloodType': 'O−'},
      {'bloodType': 'B+'},
      {'bloodType': 'O+'},
      {'bloodType': 'A−'},
      {'bloodType': 'O+'},
      {'bloodType': 'AB+'},
    ];

    final tomorrow = now.add(const Duration(days: 1));
    final dayAfter = now.add(const Duration(days: 2));
    final day3 = now.add(const Duration(days: 3));
    final day4 = now.add(const Duration(days: 4));

    String fmt(DateTime d) =>
        '${dayNames[d.weekday - 1]}, ${monthNames[d.month - 1]} ${d.day}';

    final demoAppointments = <Appointment>[
      Appointment(
        id: 'demo-1',
        userId: 'u1',
        centerName: 'Philippine General Hospital',
        centerAddress: 'Taft Ave, Ermita',
        centerId: 'demo-pgh',
        date: fmt(tomorrow),
        time: '9:00 AM',
        status: AppointmentStatus.upcoming,
        createdAt: now,
      ),
      Appointment(
        id: 'demo-2',
        userId: 'u2',
        centerName: 'Red Cross — Manila Chapter',
        centerAddress: 'Port Area',
        centerId: 'demo-red-cross',
        date: fmt(tomorrow),
        time: '10:00 AM',
        status: AppointmentStatus.upcoming,
        createdAt: now,
      ),
      Appointment(
        id: 'demo-3',
        userId: 'u3',
        centerName: "St. Luke's Medical Center",
        centerAddress: 'E. Rodriguez Sr.',
        centerId: 'demo-slmc',
        date: fmt(dayAfter),
        time: '8:00 AM',
        status: AppointmentStatus.upcoming,
        createdAt: now,
      ),
      Appointment(
        id: 'demo-4',
        userId: 'u1',
        centerName: 'UST Hospital Blood Bank',
        centerAddress: 'España Blvd, Sampaloc',
        centerId: 'demo-ust',
        date: fmt(day3),
        time: '1:00 PM',
        status: AppointmentStatus.completed,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Appointment(
        id: 'demo-5',
        userId: 'u4',
        centerName: 'Philippine Red Cross HQ',
        centerAddress: 'Bonifacio Dr, Port Area',
        centerId: 'demo-prchq',
        date: fmt(day4),
        time: '2:00 PM',
        status: AppointmentStatus.cancelled,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Appointment(
        id: 'demo-6',
        userId: 'u2',
        centerName: 'Philippine General Hospital',
        centerAddress: 'Taft Ave, Ermita',
        centerId: 'demo-pgh',
        date: fmt(dayAfter),
        time: '11:00 AM',
        status: AppointmentStatus.completed,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    setState(() {
      _users = demoUsers;
      _appointments = demoAppointments;
      _loading = false;
    });
  }

  int get _totalUsers => _users.length;
  int get _totalAppointments => _appointments.length;
  int get _completedAppointments =>
      _appointments.where((a) => a.status == AppointmentStatus.completed).length;

  Map<AppointmentStatus, int> get _statusCounts {
    final counts = <AppointmentStatus, int>{};
    for (final appt in _appointments) {
      counts[appt.status] = (counts[appt.status] ?? 0) + 1;
    }
    return counts;
  }

  List<_BarData> _getTrendBars() {
    final now = DateTime.now();
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final bars = <_BarData>[];
    for (var i = 0; i < 7; i++) {
      final day = now.add(Duration(days: 1 + i));
      final dateStr =
          '${dayNames[day.weekday - 1]}, ${monthNames[day.month - 1]} ${day.day}';
      final count = _appointments.where((a) => a.date == dateStr).length;
      final label = i == 0 ? 'Tomorrow' : '${day.month}/${day.day}';
      bars.add(_BarData(label, count.toDouble(), AppColors.primary));
    }
    return bars;
  }

  List<_BarData> _getBloodTypeBars() {
    final counts = <String, int>{};
    for (final user in _users) {
      final bloodType = (user['bloodType'] as String?)?.trim();
      if (bloodType == null || bloodType.isEmpty) continue;
      counts[bloodType] = (counts[bloodType] ?? 0) + 1;
    }
    if (counts.isEmpty) return [];
    final colors = <String, Color>{
      'A+': AppColors.levelHigh,
      'A-': AppColors.levelHigh,
      'B+': AppColors.levelMid,
      'B-': AppColors.levelMid,
      'AB+': AppColors.accent,
      'AB-': AppColors.accent,
      'O+': AppColors.primary,
      'O-': AppColors.danger,
    };
    return counts.entries
        .map((e) => _BarData(e.key, e.value.toDouble(), colors[e.key]))
        .toList();
  }

  List<_BarData> _getCenterBars() {
    final counts = <String, int>{};
    for (final appt in _appointments) {
      final name = appt.centerName.trim();
      if (name.isEmpty) continue;
      counts[name] = (counts[name] ?? 0) + 1;
    }
    if (counts.isEmpty) return [];
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted
        .take(5)
        .map((e) => _BarData(e.key, e.value.toDouble(), AppColors.accent))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final trendBars = _getTrendBars();
    final bloodTypeBars = _getBloodTypeBars();
    final centerBars = _getCenterBars();
    final statusCounts = _statusCounts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _StatCard(
                title: 'Total Users',
                value: '$_totalUsers',
                icon: Icons.people_rounded,
                color: AppColors.primary,
              ),
              _StatCard(
                title: 'Appointments',
                value: '$_totalAppointments',
                icon: Icons.calendar_month_rounded,
                color: AppColors.accent,
              ),
              _StatCard(
                title: 'Completed',
                value: '$_completedAppointments',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
              _StatCard(
                title: 'Active Centers',
                value: '${centerBars.length}',
                icon: Icons.local_hospital_rounded,
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Bookings Trend
          _SectionHeader(title: 'Upcoming Bookings (Next 7 Days)'),
          _VerticalBarChart(bars: trendBars),
          const SizedBox(height: 28),

          // Blood Type Distribution
          _SectionHeader(title: 'Blood Type Distribution'),
          _HorizontalBarChart(bars: bloodTypeBars),
          const SizedBox(height: 28),

          // Center Performance
          _SectionHeader(title: 'Top Centers'),
          _HorizontalBarChart(bars: centerBars),
          const SizedBox(height: 28),

          // Appointment Status
          _SectionHeader(title: 'Appointment Status'),
          _StatusBar(statusCounts: statusCounts),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _BarData {
  final String label;
  final double value;
  final Color? color;
  const _BarData(this.label, this.value, [this.color]);
}

class _VerticalBarChart extends StatelessWidget {
  final List<_BarData> bars;
  const _VerticalBarChart({required this.bars});

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) {
      return Text('No data available',
          style: GoogleFonts.dmSans(color: AppColors.textMuted));
    }
    final maxVal = bars.map((b) => b.value).reduce(math.max);
    if (maxVal == 0) {
      return Text('No bookings yet',
          style: GoogleFonts.dmSans(color: AppColors.textMuted));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final barSpacing = 8.0;
        final barWidth =
            (constraints.maxWidth - barSpacing * (bars.length - 1)) / bars.length;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: bars.map((bar) {
            final height = (bar.value / maxVal) * 120;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: barSpacing / 2),
                child: Column(
                  children: [
                    Text(
                      bar.value.toInt().toString(),
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: barWidth,
                      height: height,
                      decoration: BoxDecoration(
                        color: bar.color ?? AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bar.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _HorizontalBarChart extends StatelessWidget {
  final List<_BarData> bars;
  const _HorizontalBarChart({required this.bars});

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) {
      return Text('No data available',
          style: GoogleFonts.dmSans(color: AppColors.textMuted));
    }
    final maxVal = bars.map((b) => b.value).reduce(math.max);
    if (maxVal == 0) {
      return Text('No data available',
          style: GoogleFonts.dmSans(color: AppColors.textMuted));
    }

    return Column(
      children: bars.map((bar) {
        final fraction = bar.value / maxVal;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  bar.label,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.levelBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: fraction,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 18,
                        decoration: BoxDecoration(
                          color: bar.color ?? AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text(
                  bar.value.toInt().toString(),
                  textAlign: TextAlign.end,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final Map<AppointmentStatus, int> statusCounts;
  const _StatusBar({required this.statusCounts});

  @override
  Widget build(BuildContext context) {
    final total = statusCounts.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return Text('No appointments yet',
          style: GoogleFonts.dmSans(color: AppColors.textMuted));
    }

    final upcoming = (statusCounts[AppointmentStatus.upcoming] ?? 0) / total;
    final completed = (statusCounts[AppointmentStatus.completed] ?? 0) / total;
    final cancelled = (statusCounts[AppointmentStatus.cancelled] ?? 0) / total;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                if (upcoming > 0)
                  Expanded(
                    flex: (upcoming * 100).round(),
                    child: Container(
                      height: 24,
                      color: AppColors.primary,
                    ),
                  ),
                if (completed > 0)
                  Expanded(
                    flex: (completed * 100).round(),
                    child: Container(
                      height: 24,
                      color: AppColors.success,
                    ),
                  ),
                if (cancelled > 0)
                  Expanded(
                    flex: (cancelled * 100).round(),
                    child: Container(
                      height: 24,
                      color: AppColors.danger,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _LegendDot(
              color: AppColors.primary,
              label: 'Upcoming',
              count: statusCounts[AppointmentStatus.upcoming] ?? 0,
            ),
            _LegendDot(
              color: AppColors.success,
              label: 'Completed',
              count: statusCounts[AppointmentStatus.completed] ?? 0,
            ),
            _LegendDot(
              color: AppColors.danger,
              label: 'Cancelled',
              count: statusCounts[AppointmentStatus.cancelled] ?? 0,
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendDot({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
