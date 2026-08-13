import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/donation_center.dart';
import '../../providers/app_provider.dart';

// Manila, Philippines — initial map center
const _manilaCenter = LatLng(14.5995, 120.9842);
const _initialZoom = 13.0;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  DonationCenter? _selected;
  String _filter = 'All';
  final _filters = ['All', 'Slots open', 'Nearby'];
  final _searchController = TextEditingController();
  final _mapController = MapController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  List<DonationCenter> _applyFilters(List<DonationCenter> all) {
    var result = all.where((c) {
      if (_query.isNotEmpty) {
        return c.name.toLowerCase().contains(_query) ||
            c.address.toLowerCase().contains(_query);
      }
      return true;
    }).toList();

    if (_filter == 'Slots open') {
      result = result.where((c) => c.slotStatus == SlotStatus.open).toList();
    } else if (_filter == 'Nearby') {
      result = result
          .where((c) => c.distanceKm <= 3.0)
          .toList()
        ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    }
    return result;
  }

  void _selectCenter(DonationCenter c) {
    setState(() => _selected = c);
    // Pan map to the selected center
    _mapController.move(LatLng(c.lat, c.lng), _mapController.camera.zoom);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final allCenters = provider.centers;
    final filtered = _applyFilters(allCenters);
    final filteredIds = filtered.map((c) => c.id).toSet();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // ── Map area ────────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Real OpenStreetMap
                FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    initialCenter: _manilaCenter,
                    initialZoom: _initialZoom,
                    minZoom: 10,
                    maxZoom: 18,
                    interactionOptions: InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    // OSM tile layer
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.lifelink.app',
                      maxZoom: 19,
                    ),

                    // Donation center markers
                    MarkerLayer(
                      markers: allCenters.map((c) {
                        final isSelected = _selected?.id == c.id;
                        final dimmed = !filteredIds.contains(c.id);
                        return Marker(
                          point: LatLng(c.lat, c.lng),
                          width: isSelected ? 140 : 40,
                          height: 48,
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: dimmed ? null : () => _selectCenter(c),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: dimmed ? 0.3 : 1.0,
                              child: _MapPin(
                                  center: c, isSelected: isSelected),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // OSM attribution (required by OSM usage policy)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4, right: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '© OpenStreetMap contributors',
                          style: GoogleFonts.dmSans(
                            fontSize: 8,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Search + filter bar floats on top
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SearchBar(controller: _searchController),
                        const SizedBox(height: 10),
                        _FilterRow(
                          filters: _filters,
                          selected: _filter,
                          onSelect: (f) => setState(() => _filter = f),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom sheet ────────────────────────────────────────────────
          _BottomCenterList(
            centers: filtered,
            allCount: allCenters.length,
            selected: _selected,
            onSelect: _selectCenter,
            onBook: (c) {
              provider.selectCenter(c);
              provider.setIndex(2);
            },
          ),
        ],
      ),
    );
  }
}

// ── Map pin widget ────────────────────────────────────────────────────────────
class _MapPin extends StatelessWidget {
  final DonationCenter center;
  final bool isSelected;

  const _MapPin({required this.center, required this.isSelected});

  Color get _statusColor {
    switch (center.slotStatus) {
      case SlotStatus.open:
        return AppColors.success;
      case SlotStatus.limited:
        return AppColors.warning;
      case SlotStatus.full:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: isSelected
                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                : const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(isSelected ? 20 : 10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: isSelected ? 0.28 : 0.18),
                  blurRadius: isSelected ? 10 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_hospital_rounded,
                          color: Colors.white, size: 12),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          center.name.split(' ').first,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.local_hospital_rounded,
                          color: AppColors.primary, size: 16),
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          // Pin tail
          CustomPaint(
            size: const Size(10, 6),
            painter: _TailPainter(
                color: isSelected ? AppColors.primary : Colors.white),
          ),
        ],
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  final Color color;
  const _TailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      ui.Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_TailPainter old) => old.color != color;
}

// ── Search bar ────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style:
            GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search donation centers…',
          hintStyle:
              GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textMuted, size: 20),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, _) => v.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted, size: 18),
                    onPressed: controller.clear,
                  ),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

// ── Filter chips ──────────────────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final void Function(String) onSelect;

  const _FilterRow(
      {required this.filters,
      required this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: filters
          .map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onSelect(f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: f == selected
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      f,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: f == selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

// ── Bottom center list ────────────────────────────────────────────────────────
class _BottomCenterList extends StatelessWidget {
  final List<DonationCenter> centers;
  final int allCount;
  final DonationCenter? selected;
  final void Function(DonationCenter) onSelect;
  final void Function(DonationCenter) onBook;

  const _BottomCenterList({
    required this.centers,
    required this.allCount,
    required this.selected,
    required this.onSelect,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                Text(
                  centers.isEmpty
                      ? 'No centers found'
                      : '${centers.length} of $allCount centers nearby',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Cards
          SizedBox(
            height: 220,
            child: centers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            color: AppColors.textMuted, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different filter or search',
                          style: GoogleFonts.dmSans(
                              fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: centers.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final c = centers[i];
                      final isSelected = selected?.id == c.id;
                      return GestureDetector(
                        onTap: () => onSelect(c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 200,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryLight
                                : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.local_hospital_rounded,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.primary,
                                      size: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    c.distanceLabel,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                c.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${c.address} · ${c.hours}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: c.slotStatus == SlotStatus.open
                                      ? AppColors.successLight
                                      : AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  c.slotLabel,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: c.slotStatus == SlotStatus.open
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => onBook(c),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    textStyle: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  child: const Text('Book'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: bottomInset),
        ],
      ),
    );
  }
}
