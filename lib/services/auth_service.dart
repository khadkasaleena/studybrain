import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config/constants.dart';
import 'firestore_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn? _googleSignIn;
  
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthService() {
    _initializeAuthState();
  }

  void _initializeAuthState() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserModel();
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserModel() async {
    if (_user == null) return;
    
    try {
      final firestoreService = FirestoreService();
      _userModel = await firestoreService.getUser(_user!.uid);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user model: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sign up with email and password
  Future<bool> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Create user account
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(name.trim());
        
        // Create user document in Firestore
        final userModel = UserModel(
          id: result.user!.uid,
          name: name.trim(),
          email: email.trim(),
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        final firestoreService = FirestoreService();
        await firestoreService.createUser(userModel);
        
        // Save first launch preference
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.isFirstLaunchKey, false);

        _setLoading(false);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      debugPrint('Sign up error: $e');
    }

    _setLoading(false);
    return false;
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        // Update last login time
        final firestoreService = FirestoreService();
        await firestoreService.updateUserLastLogin(result.user!.uid);
        
        _setLoading(false);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      debugPrint('Sign in error: $e');
    }

    _setLoading(false);
    return false;
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      // Trigger the authentication flow
      _googleSignIn ??= GoogleSignIn();
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      
      if (googleUser == null) {
        _setLoading(false);
        return false; // User cancelled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result = await _auth.signInWithCredential(credential);

      if (result.user != null) {
        final user = result.user!;
        
        // Check if this is a new user
        if (result.additionalUserInfo?.isNewUser == true) {
          // Create user document in Firestore
          final userModel = UserModel(
            id: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            profileImageUrl: user.photoURL,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );

          final firestoreService = FirestoreService();
          await firestoreService.createUser(userModel);
          
          // Save first launch preference
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(AppConstants.isFirstLaunchKey, false);
        } else {
          // Update last login time for existing user
          final firestoreService = FirestoreService();
          await firestoreService.updateUserLastLogin(user.uid);
        }

        _setLoading(false);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _setError('Google sign in failed. Please try again.');
      debugPrint('Google sign in error: $e');
    }

    _setLoading(false);
    return false;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (_googleSignIn != null) await _googleSignIn!.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _auth.sendPasswordResetEmail(email: email.trim());
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _setError('Failed to send password reset email. Please try again.');
      debugPrint('Password reset error: $e');
    }

    _setLoading(false);
    return false;
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    if (_user == null) return false;

    try {
      _setLoading(true);
      _setError(null);

      // Update Firebase Auth profile
      if (name != null) {
        await _user!.updateDisplayName(name);
      }
      if (profileImageUrl != null) {
        await _user!.updatePhotoURL(profileImageUrl);
      }

      // Update Firestore document
      final firestoreService = FirestoreService();
      await firestoreService.updateUser(_user!.uid, {
        if (name != null) 'name': name,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      });

      await _loadUserModel(); // Reload user model
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update profile. Please try again.');
      debugPrint('Update profile error: $e');
    }

    _setLoading(false);
    return false;
  }

  // Delete user account
  Future<bool> deleteAccount() async {
    if (_user == null) return false;

    try {
      _setLoading(true);
      _setError(null);

      // Delete user data from Firestore
      final firestoreService = FirestoreService();
      await firestoreService.deleteUser(_user!.uid);

      // Delete Firebase Auth account
      await _user!.delete();
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _setError('Failed to delete account. Please try again.');
      debugPrint('Delete account error: $e');
    }

    _setLoading(false);
    return false;
  }

  // Check if user needs to be reauthenticated
  bool get needsReauthentication {
    if (_user == null) return false;
    
    final metadata = _user!.metadata;
    final lastSignInTime = metadata.lastSignInTime;
    
    if (lastSignInTime == null) return true;
    
    final now = DateTime.now();
    final timeDifference = now.difference(lastSignInTime);
    
    // Require reauthentication if last sign in was more than 5 minutes ago
    return timeDifference.inMinutes > 5;
  }

  // Check if first time launch
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.isFirstLaunchKey) ?? true;
  }

  // Update study streak
  Future<void> updateStudyStreak() async {
    if (_userModel == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int newStreak = _userModel!.studyStreak;
    
    if (_userModel!.lastStudyDate == null) {
      // First time studying
      newStreak = 1;
    } else {
      final lastStudyDay = DateTime(
        _userModel!.lastStudyDate!.year,
        _userModel!.lastStudyDate!.month,
        _userModel!.lastStudyDate!.day,
      );
      
      final daysDifference = today.difference(lastStudyDay).inDays;
      
      if (daysDifference == 1) {
        // Consecutive day - increment streak
        newStreak = _userModel!.studyStreak + 1;
      } else if (daysDifference > 1) {
        // Streak broken - reset to 1
        newStreak = 1;
      }
      // If daysDifference == 0, it's the same day, so streak stays the same
    }

    // Update in Firestore
    final firestoreService = FirestoreService();
    await firestoreService.updateUser(_user!.uid, {
      'studyStreak': newStreak,
      'lastStudyDate': Timestamp.fromDate(now),
    });

    // Update local model
    _userModel = _userModel!.copyWith(
      studyStreak: newStreak,
      lastStudyDate: now,
    );
    
    notifyListeners();
  }

  // Helper method to get user-friendly error messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}