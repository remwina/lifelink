import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart' as ap;
import 'screens/auth/login_screen.dart';
import 'services/firestore_service.dart';
import 'shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Detect whether Firebase has been configured by checking for placeholder values
  bool firebaseReady = false;
  if (DefaultFirebaseOptions.android.apiKey != 'YOUR_ANDROID_API_KEY') {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseReady = true;

      // Seed static collections on first run — failures here are non-fatal
      // (e.g. Firestore not yet created, or no network). The app still opens.
      try {
        final db = FirestoreService();
        await Future.wait([
          db.seedCentersIfEmpty(),
          db.seedBloodSupplyIfEmpty(),
        ]);
      } catch (_) {
        // Seeding failed — app will retry next launch or show empty state
      }
    } catch (_) {
      firebaseReady = false;
    }
  }

  runApp(LifeLinkApp(firebaseReady: firebaseReady));
}

class LifeLinkApp extends StatelessWidget {
  final bool firebaseReady;
  const LifeLinkApp({super.key, required this.firebaseReady});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ap.AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'LifeLink',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: firebaseReady ? const _AuthGate() : const _SetupBanner(),
      ),
    );
  }
}

// ── Auth gate — listens to auth state and routes accordingly ─────────────────
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<ap.AuthProvider>().status;
    final appProvider = context.read<AppProvider>();
    final firebaseUser = context.read<ap.AuthProvider>().firebaseUser;

    switch (authStatus) {
      case ap.AuthStatus.unknown:
        // Splash / loading state
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );

      case ap.AuthStatus.authenticated:
        // Start Firestore listeners for this user
        if (firebaseUser != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appProvider.startSession(firebaseUser.uid);
          });
        }
        return const AppShell();

      case ap.AuthStatus.unauthenticated:
        // Clear provider state on sign-out
        WidgetsBinding.instance.addPostFrameCallback((_) {
          appProvider.clearSession();
        });
        return const LoginScreen();
    }
  }
}

// ── Setup banner — shown before flutterfire configure is run ─────────────────
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
