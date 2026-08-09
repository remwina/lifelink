import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Manages authentication state and the current user session.
class AuthProvider extends ChangeNotifier {
  final bool demoMode;
  late final AuthService _auth;
  late final FirestoreService _db;

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  User? _firebaseUser;
  User? get firebaseUser => _firebaseUser;
  String? get currentUid =>
      _firebaseUser?.uid ?? (demoMode ? 'demo-donor' : null);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _currentEmail;
  String? get currentEmail => _currentEmail;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider({this.demoMode = false}) {
    if (!demoMode) {
      _auth = AuthService();
      _db = FirestoreService();
    }
    if (demoMode) {
      _status = AuthStatus.authenticated;
      return;
    }
    // Listen for Firebase auth state changes
    _auth.authStateChanges.listen((user) {
      _firebaseUser = user;
      _status = user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      debugPrint('AuthProvider: status=$_status email=${user?.email}');
      notifyListeners();
    });
  }

  // ── Sign in ────────────────────────────────────────────────────────────────

  Future<bool> signIn({required String email, required String password}) async {
    if (demoMode) {
      _currentEmail = email.trim();
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    }
    _setLoading(true);
    try {
      await _auth.signIn(email: email, password: password);
      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.friendlyError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String bloodType,
  }) async {
    if (demoMode) {
      _currentEmail = email.trim();
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    }
    _setLoading(true);
    try {
      final credential = await _auth.register(
        email: email,
        password: password,
        name: name,
      );
      final uid = credential.user!.uid;

      // Create Firestore profile and seed initial data
      final profile = UserProfile.newUser(
        uid: uid,
        name: name.trim(),
        email: email.trim(),
        bloodType: bloodType,
      );
      await _db.createUserProfile(profile);

      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.friendlyError(e);
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Sign out ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    if (demoMode) {
      _currentEmail = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    await _auth.signOut();
  }

  // ── Forgot password ────────────────────────────────────────────────────────

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _auth.sendPasswordReset(email);
      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.friendlyError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
