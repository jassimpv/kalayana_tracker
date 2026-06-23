import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/app_bar.dart';
import 'package:kalayanaexpresstracker/app/routes/app_pages.dart';

const _webGoogleClientId =
    '1097547412500-kghp41ghv639fqkujrhc91vgpio1cro5.apps.googleusercontent.com';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalScaffold(
      title: 'Privacy Policy',
      subtitle: 'How Kalyanam360 – Planner & Budget handles your information.',
      children: [
        _PolicySection(title: 'Last updated', body: 'May 21, 2026'),
        _PolicySection(
          title: 'Information we collect',
          body:
              'We collect the information you add to your account, including your name, email address, wedding profile details, expenses, reminders, purchases, notes, and optional invoice or receipt images that you choose to scan.',
        ),
        _PolicySection(
          title: 'How we use information',
          body:
              'We use your information to create your account, save your wedding planning data, sync it across your devices, generate dashboard summaries, and extract invoice details when you use bill scanning.',
        ),
        _PolicySection(
          title: 'Authentication and storage',
          body:
              'The app uses Firebase Authentication for sign in and Google sign in, and stores app data in Cloud Firestore under your user account.',
        ),
        _PolicySection(
          title: 'Third-party processing',
          body:
              'When you scan an invoice or receipt, the selected image may be sent to Google Gemini so invoice fields can be extracted for your expense entry. Google sign in and Firebase services are also provided by Google.',
        ),
        _PolicySection(
          title: 'Sharing',
          body:
              'We do not sell your personal information. Your data is used to provide the app features and may be processed by service providers needed to run authentication, cloud storage, and invoice extraction.',
        ),
        _PolicySection(
          title: 'Data retention',
          body:
              'We keep your account and planning data while your account remains active. You can request deletion from the Delete Account page, which removes your app profile and saved dashboard data.',
        ),
        _PolicySection(
          title: 'Your choices',
          body:
              'You can update profile details in the app, sign out at any time, and delete your account after verification at /delete-account.',
        ),
        _PolicySection(
          title: 'Contact',
          body:
              'For privacy questions or account deletion help, contact the app owner or support channel listed in the app store listing.',
        ),
      ],
    );
  }
}

class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalScaffold(
      title: 'Terms & Conditions',
      subtitle: 'Terms for using Kalyanam360 – Planner & Budget.',
      children: [
        _PolicySection(title: 'Last updated', body: 'May 21, 2026'),
        _PolicySection(
          title: 'Use of the app',
          body:
              'Kalyanam360 – Planner & Budget helps you plan wedding expenses, purchases, reminders, and related dashboard information. You are responsible for the accuracy of the information you enter.',
        ),
        _PolicySection(
          title: 'Account access',
          body:
              'You must keep your sign-in credentials secure. If you use Google sign in or Firebase Authentication, those services may also apply their own terms.',
        ),
        _PolicySection(
          title: 'Planning information',
          body:
              'Budgets, totals, reminders, extracted invoice fields, and reports are provided for planning convenience and should be reviewed before financial decisions are made.',
        ),
        _PolicySection(
          title: 'Service availability',
          body:
              'The app may depend on network access, Firebase, Google sign in, and invoice extraction services. Features can be interrupted by service availability or device permissions.',
        ),
        _PolicySection(
          title: 'Account deletion',
          body:
              'You can request account deletion from the Delete Account page after verifying your current sign-in method.',
        ),
      ],
    );
  }
}

class DeleteAccountView extends StatefulWidget {
  const DeleteAccountView({super.key});

  @override
  State<DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends State<DeleteAccountView> {
  final _passwordController = TextEditingController();
  var _verified = false;
  var _loading = false;
  String? _message;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final usesPassword =
        user?.providerData.any(
          (provider) => provider.providerId == 'password',
        ) ??
        false;
    final usesGoogle =
        user?.providerData.any(
          (provider) => provider.providerId == 'google.com',
        ) ??
        false;

    return _LegalScaffold(
      title: 'Delete Account',
      subtitle: 'Verification is required before account deletion.',
      children: [
        _PolicySection(
          title: 'What will be deleted',
          body:
              'Deleting your account removes your Firebase Authentication account, app profile, and saved dashboard data including expenses, purchases, reminders, and wedding profile details.',
        ),
        if (user == null)
          _SignedOutDeletePanel()
        else ...[
          _AccountSummary(email: user.email ?? 'Signed-in account'),
          const _PolicySection(
            title: 'Verification required',
            body:
                'For your security, verify your current sign-in method first. The delete button is enabled only after verification succeeds.',
          ),
          if (usesPassword) ...[
            TextField(
              controller: _passwordController,
              obscureText: true,
              enabled: !_loading && !_verified,
              decoration: const InputDecoration(
                labelText: 'Current password',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loading || _verified
                  ? null
                  : () => _verifyWithPassword(user),
              icon: const Icon(Icons.verified_user_outlined),
              label: Text(_verified ? 'Verified' : 'Verify password'),
            ),
          ],
          if (usesGoogle) ...[
            FilledButton.icon(
              onPressed: _loading || _verified
                  ? null
                  : () => _verifyWithGoogle(user),
              icon: const Icon(Icons.g_mobiledata_rounded),
              label: Text(_verified ? 'Verified' : 'Verify with Google'),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _loading || !_verified
                ? null
                : () => _confirmDeleteUser(user),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              minimumSize: const Size.fromHeight(52),
            ),
            icon: _loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_forever_rounded),
            label: const Text('Permanently delete my account'),
          ),
          if (_message != null) ...[
            const SizedBox(height: 14),
            Text(
              _message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Future<void> _verifyWithPassword(User user) async {
    if ((user.email ?? '').isEmpty || _passwordController.text.trim().isEmpty) {
      _setMessage('Enter your current password to verify your account.');
      return;
    }
    await _runGuarded(() async {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _passwordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);
      setState(() {
        _verified = true;
        _message = null;
      });
    });
  }

  Future<void> _verifyWithGoogle(User user) async {
    await _runGuarded(() async {
      final googleUser = await GoogleSignIn(
        clientId: kIsWeb ? _webGoogleClientId : null,
      ).signIn();
      if (googleUser == null) {
        _setMessage('Google verification was cancelled.');
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(credential);
      setState(() {
        _verified = true;
        _message = null;
      });
    });
  }

  Future<void> _confirmDeleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This permanently deletes your account and saved dashboard data. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _deleteUser(user);
  }

  Future<void> _deleteUser(User user) async {
    await _runGuarded(() async {
      final uid = user.uid;
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      batch.delete(
        firestore
            .collection('users')
            .doc(uid)
            .collection('weddings')
            .doc('dashboard'),
      );
      batch.delete(firestore.collection('users').doc(uid));
      await batch.commit();
      await user.delete();
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(AppRoutes.auth);
      Get.snackbar(
        'Account deleted',
        'Your account and app data were deleted.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    });
  }

  Future<void> _runGuarded(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await action();
    } on FirebaseAuthException catch (error) {
      _setMessage(error.message ?? error.code);
    } catch (error) {
      _setMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _setMessage(String message) {
    if (!mounted) return;
    setState(() => _message = message);
  }
}

class _LegalScaffold extends StatelessWidget {
  const _LegalScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.scaffoldColor,
      appBar: CustomAppBar(
        title: title,
        onBack: () => Get.back(),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: ThemeColors.surfaceGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.privacy_tip_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 40,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                  height: 1.4,
                                ),
                          ),
                          const SizedBox(height: 24),
                          ...children,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSummary extends StatelessWidget {
  const _AccountSummary({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_circle_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignedOutDeletePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PolicySection(
          title: 'Sign in first',
          body:
              'Account deletion is available only after sign in, because we must verify ownership before deleting data.',
        ),
        FilledButton.icon(
          onPressed: () => Get.toNamed(AppRoutes.auth),
          icon: const Icon(Icons.login_rounded),
          label: const Text('Sign in to continue'),
        ),
      ],
    );
  }
}
