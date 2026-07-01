import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kalayanaexpresstracker/app/core/services/account_deletion_service.dart';
import 'package:kalayanaexpresstracker/app/core/utils/currency_symbols.dart';
import 'package:kalayanaexpresstracker/app/routes/app_pages.dart';

const _webGoogleClientId =
    '1097547412500-kghp41ghv639fqkujrhc91vgpio1cro5.apps.googleusercontent.com';

class AuthController extends GetxController {
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final groom = TextEditingController();
  final bride = TextEditingController();

  final isCreate = false.obs;
  final loading = false.obs;
  final obscurePassword = true.obs;
  final weddingDate = Rxn<DateTime>();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        if (Get.currentRoute != AppRoutes.auth) Get.offAllNamed(AppRoutes.auth);
      } else if (_requiresEmailVerification(user)) {
        await _auth.signOut();
        if (Get.currentRoute != AppRoutes.auth) Get.offAllNamed(AppRoutes.auth);
      } else {
        await _openDashboardAfterSignIn(user);
      }
    });
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    name.dispose();
    groom.dispose();
    bride.dispose();
    super.onClose();
  }

  Future<void> submit(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;
    loading.value = true;
    try {
      if (isCreate.value) {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
        );
        final createdUser = credential.user;
        await createdUser?.updateDisplayName(name.text.trim());
        final fullNameValue = name.text.trim();
        final emailValue = email.text.trim();
        final groomValue = groom.text.trim();
        final brideValue = bride.text.trim();
        final user = createdUser ?? _auth.currentUser!;
        final regionCurrency = CurrencySymbolApi.fromDeviceRegion();

        await _saveUserProfile({
          'fullName': fullNameValue,
          'email': emailValue.isEmpty ? user.email : emailValue,
          'groomName': groomValue.isEmpty ? null : groomValue,
          'brideName': brideValue.isEmpty ? null : brideValue,
          'marriageDate': weddingDate.value?.toIso8601String(),
          'currencyCode': regionCurrency.code,
          'currencySymbol': regionCurrency.symbol,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await user.sendEmailVerification();
        await _auth.signOut();
        Get.snackbar(
          'Verify your email',
          'We sent a verification link to ${user.email ?? emailValue}. Please verify your email before signing in.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 6),
        );
      } else {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
        );
        final user = credential.user;
        await user?.reload();
        final refreshedUser = _auth.currentUser ?? user;
        if (refreshedUser != null &&
            _requiresEmailVerification(refreshedUser)) {
          await refreshedUser.sendEmailVerification();
          await _auth.signOut();
          _showError(
            'Please verify your email before signing in. We sent a new verification link to ${refreshedUser.email}.',
          );
          return;
        }
      }
    } on FirebaseAuthException catch (error) {
      _showError(error.message ?? error.code);
    } catch (error) {
      _showError(error.toString());
    } finally {
      loading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    loading.value = true;
    try {
      final UserCredential userCredential;
      if (kIsWeb) {
        // The legacy google_sign_in popup flow doesn't reliably return an ID
        // token on web (Google deprecated it in favor of Identity Services).
        // Firebase's own popup flow is the supported path on web/desktop.
        userCredential = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        // serverClientId is required on Android/iOS to receive an idToken.
        final googleUser = await GoogleSignIn(
          serverClientId: _webGoogleClientId,
        ).signIn();
        if (googleUser == null) return;
        final googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;
        if (idToken == null) {
          _showError(
            'Google sign-in failed: could not retrieve ID token. Check Firebase SHA fingerprint configuration.',
          );
          return;
        }
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }
      final user = userCredential.user ?? _auth.currentUser!;
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      await _saveUserProfile({
        'fullName': user.displayName,
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
        if (isNewUser) ...{
          'currencyCode': CurrencySymbolApi.fromDeviceRegion().code,
          'currencySymbol': CurrencySymbolApi.fromDeviceRegion().symbol,
          'createdAt': FieldValue.serverTimestamp(),
        },
      });
    } on FirebaseAuthException catch (error) {
      _showError(error.message ?? error.code);
    } catch (error) {
      _showError('Google sign-in failed: $error');
    } finally {
      loading.value = false;
    }
  }

  Future<void> resetPassword() async {
    final emailValue = email.text.trim();
    if (emailValue.isEmpty) {
      _showError('Enter your email address first.');
      return;
    }
    loading.value = true;
    try {
      await _auth.sendPasswordResetEmail(email: emailValue);
      Get.snackbar(
        'Password reset',
        'A reset link has been sent to $emailValue.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } on FirebaseAuthException catch (error) {
      _showError(error.message ?? error.code);
    } catch (error) {
      _showError(error.toString());
    } finally {
      loading.value = false;
    }
  }

  Future<void> pickWeddingDate() async {
    final context = Get.context;
    if (context == null) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: weddingDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked != null) weddingDate.value = picked;
  }

  Future<void> _saveUserProfile(Map<String, dynamic> userData) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .set(userData, SetOptions(merge: true));
  }

  bool _requiresEmailVerification(User user) {
    final usesPassword = user.providerData.any(
      (provider) => provider.providerId == EmailAuthProvider.PROVIDER_ID,
    );
    return usesPassword && !user.emailVerified;
  }

  Future<void> _openDashboardAfterSignIn(User user) async {
    final revoked = await AccountDeletionService.revokeIfScheduled(user);
    Get.offAllNamed(AppRoutes.dashboard);
    if (revoked) {
      Get.snackbar(
        'Deletion request cancelled',
        'Your account deletion request was revoked because you signed in.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void _showError(String message) {
    if (kDebugMode) debugPrint('Authentication Error: $message');

    Get.snackbar(
      'Authentication',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
