import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/app_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/pulse_alert/pulse_alert_overlay.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  // One AnimationController per tab for the switching animation
  late final List<AnimationController> _tabCtrls;
  int _prevIndex = 0;

  static const _screens = [
    HomeScreen(),
    NotificationsScreen(),
    BookingScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrls = List.generate(
      _screens.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 260),
      )..value = i == 0 ? 1.0 : 0.0,
    );
  }

  @override
  void dispose() {
    for (final c in _tabCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabSwitch(int newIndex) {
    if (newIndex == _prevIndex) return;
    _tabCtrls[_prevIndex].reverse();
    _tabCtrls[newIndex].forward();
    _prevIndex = newIndex;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final currentIndex = provider.currentIndex;

    // Trigger animation when index changes externally (e.g. from PulseAlert)
    if (currentIndex != _prevIndex) {
      _onTabSwitch(currentIndex);
    }

    return Stack(
      children: [
        Scaffold(
          body: Stack(
            children: List.generate(_screens.length, (i) {
              return AnimatedBuilder(
                animation: _tabCtrls[i],
                builder: (context, child) {
                  final anim = CurvedAnimation(
                    parent: _tabCtrls[i],
                    curve: Curves.easeOutCubic,
                  );
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.03),
                        end: Offset.zero,
                      ).animate(anim),
                      child: IgnorePointer(
                        ignoring: i != currentIndex,
                        child: child,
                      ),
                    ),
                  );
                },
                child: _screens[i],
              );
            }),
          ),
          bottomNavigationBar: _LifeLinkNavBar(
            currentIndex: currentIndex,
            unreadCount: provider.unreadCount,
            onTap: (i) {
              _onTabSwitch(i);
              provider.setIndex(i);
            },
          ),
        ),
        if (provider.pulseAlertVisible)
          const Positioned.fill(child: PulseAlertOverlay()),
      ],
    );
  }
}

// ── Bottom Navigation Bar ─────────────────────────────────────────────────────

class _LifeLinkNavBar extends StatelessWidget {
  final int currentIndex;
  final int unreadCount;
  final void Function(int) onTap;

  const _LifeLinkNavBar({
    required this.currentIndex,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      height: 72 + bottomInset,
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            index: 0,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.notifications_rounded,
            label: 'Alerts',
            index: 1,
            currentIndex: currentIndex,
            badge: unreadCount,
            onTap: onTap,
          ),
          _BookItem(index: 2, currentIndex: currentIndex, onTap: onTap),
          _NavItem(
            icon: Icons.map_rounded,
            label: 'Map',
            index: 3,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            index: 4,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final int badge;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    this.badge = 0,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.82).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.index == widget.currentIndex;
    final color = selected ? AppColors.primary : AppColors.textMuted;

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap(widget.index);
        },
        onTapCancel: () => _ctrl.reverse(),
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Animated selection indicator pill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    width: selected ? 36 : 0,
                    height: selected ? 4 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Icon(widget.icon,
                      color: color,
                      size: selected ? 24 : 22),
                  if (widget.badge > 0)
                    Positioned(
                      right: -5,
                      top: -3,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${widget.badge}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400,
                  color: color,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookItem extends StatefulWidget {
  final int index;
  final int currentIndex;
  final void Function(int) onTap;

  const _BookItem({
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_BookItem> createState() => _BookItemState();
}

class _BookItemState extends State<_BookItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.index == widget.currentIndex;
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap(widget.index);
        },
        onTapCancel: () => _ctrl.reverse(),
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.primaryLight,
                  shape: BoxShape.circle,
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: selected ? Colors.white : AppColors.primary,
                  size: selected ? 22 : 20,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                ),
                child: const Text('Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
