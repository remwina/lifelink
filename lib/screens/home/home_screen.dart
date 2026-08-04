import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/blood_drop_icon.dart';
import 'widgets/eligibility_card.dart';
import 'widgets/blood_supply_grid.dart';
import 'widgets/impact_card.dart';
import 'widgets/nearby_centers_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // Still loading the user profile from Firestore
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: false,
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 16,
            toolbarHeight: 52,
            title: Row(
              children: [
                const BloodDropIcon(size: 20, color: AppColors.primary),
                const SizedBox(width: 7),
                Text(
                  'LifeLink',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 19,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: provider.showPulseAlert,
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + bottomPad),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Greeting
                Text(
                  'Good morning,',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 24,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.bloodType,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Eligibility card
                EligibilityCard(user: user),
                const SizedBox(height: 14),

                // Blood supply — two rows of 4
                BloodSupplyGridWidget(),
                const SizedBox(height: 14),

                // Impact
                ImpactCard(user: user),
                const SizedBox(height: 14),

                // Nearby centers
                NearbyCentersCard(
                  centers: provider.centers,
                  onBook: (center) {
                    provider.selectCenter(center);
                    provider.setIndex(2); // Book tab is index 2
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
