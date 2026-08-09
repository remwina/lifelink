import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart' as ap;
import 'services/reminder_service.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/auth/login_screen.dart';
import 'shell.dart';

const String _adminEmail = 'admin@lifelink.app';
// Set to false when Firebase is configured and ready for integration testing.
const bool demoMode = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await ReminderService.initialize();

  bool firebaseReady = false;
  if (!demoMode && DefaultFirebaseOptions.android.apiKey != 'YOUR_ANDROID_API_KEY') {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseReady = true;
      // NOTE: Seeding is now done after sign-in inside AppProvider.startSession
      // so it runs with auth context. Do NOT seed here.
    } catch (_) {
      firebaseReady = false;
    }
  }

  runApp(LifeLinkApp(firebaseReady: firebaseReady, demoMode: demoMode));
}

class LifeLinkApp extends StatelessWidget {
  final bool firebaseReady;
  final bool demoMode;
  const LifeLinkApp({
    super.key,
    required this.firebaseReady,
    required this.demoMode,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ap.AuthProvider(demoMode: demoMode)),
        ChangeNotifierProvider(
            create: (_) => AppProvider(demoMode: demoMode)),
      ],
      child: MaterialApp(
        title: 'LifeLink',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: demoMode || firebaseReady ? const _AuthGate() : const _SetupBanner(),
      ),
    );
  }
}

// ── Auth gate ─────────────────────────────────────────────────────────────────
// Fix #1 & #14: Use a StatefulWidget with a flag so startSession and
// clearSession are only ever called once per auth-state transition,
// not on every rebuild.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  String? _activeUid; // uid whose session is currently running

  @override
  Widget build(BuildContext context) {
    // Watch both providers so we rebuild on auth changes
    final authProvider = context.watch<ap.AuthProvider>();
    final appProvider = context.read<AppProvider>();

    switch (authProvider.status) {
      case ap.AuthStatus.unknown:
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );

      case ap.AuthStatus.authenticated:
        final uid = authProvider.currentUid;
        final email = authProvider.currentEmail ?? authProvider.firebaseUser?.email ?? '';
        final isAdmin = email == _adminEmail;

        // Only start a new session when the uid actually changes
        if (uid != null && uid != _activeUid) {
          _activeUid = uid;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Admin doesn't need AppProvider streams
            if (!isAdmin && mounted) appProvider.startSession(uid);
          });
        }
         return isAdmin ? AdminScreen(demoMode: demoMode) : const AppShell();

      case ap.AuthStatus.unauthenticated:
        // Only clear once when transitioning away from a session
        if (_activeUid != null) {
          _activeUid = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) appProvider.clearSession();
          });
        }
        return const LoginScreen();
    }
  }
}

// ── Setup banner ──────────────────────────────────────────────────────────────
class _SetupBanner extends StatelessWidget {
  const _SetupBanner();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 56),
                const SizedBox(height: 20),
                Text(
                  'Firebase not configured',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Run the FlutterFire CLI to connect this app to your '
                  'Firebase project, then rebuild.\n\n'
                  '  dart pub global activate flutterfire_cli\n'
                  '  flutterfire configure',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
