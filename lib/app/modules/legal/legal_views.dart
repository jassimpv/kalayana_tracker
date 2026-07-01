import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kalayanaexpresstracker/app/core/services/account_deletion_service.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/app_bar.dart';
import 'package:kalayanaexpresstracker/app/routes/app_pages.dart';
import 'package:package_info_plus/package_info_plus.dart';

const _webGoogleClientId =
    '1097547412500-kghp41ghv639fqkujrhc91vgpio1cro5.apps.googleusercontent.com';
const _supportEmail = 'support@wedding360.app';
final Future<String> _appVersionFuture = _loadAppVersion();

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalScaffold(
      title: 'Help & Support',
      subtitle: 'Find answers, contact support, and manage legal settings.',
      icon: Icons.help_outline_rounded,
      children: [
        const _PolicySection(
          title: 'FAQ',
          body:
              'Wedding360 helps you track expenses, payments, reminders, shopping, guests, RSVP responses, and collaborators in one shared planning space. If your data does not appear immediately, check your internet connection and sign in with the same account or shared workspace.',
        ),
        const _PolicySection(
          title: 'Contact / Support Email',
          body:
              'For help with your account, data, billing questions, or deletion requests, email $_supportEmail.',
        ),
        _SupportLinkTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'Review how your information is handled',
          onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
        ),
        _SupportLinkTile(
          icon: Icons.description_outlined,
          title: 'Terms & Conditions',
          subtitle: 'Read the terms for using the app',
          onTap: () => Get.toNamed(AppRoutes.termsConditions),
        ),
        _SupportLinkTile(
          icon: Icons.delete_forever_outlined,
          title: 'Delete Account',
          subtitle: 'Request account deletion after verification',
          destructive: true,
          onTap: () => Get.toNamed(AppRoutes.deleteAccount),
        ),
        const SizedBox(height: 4),
        const _AppVersionSection(),
      ],
    );
  }
}

Future<String> _loadAppVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  if (packageInfo.buildNumber.trim().isEmpty) {
    return packageInfo.version;
  }
  return '${packageInfo.version}+${packageInfo.buildNumber}';
}

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalScaffold(
      title: 'Privacy Policy',
      subtitle: 'How Wedding360 – Planner & Budget handles your information.',
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
              'We keep your account and planning data while your account remains active. When you request account deletion, the request is scheduled for 90 days later. If you sign in during that 90-day period, the deletion request is automatically cancelled.',
        ),
        _PolicySection(
          title: 'Your choices',
          body:
              'You can update profile details in the app, sign out at any time, and request account deletion after verification at /delete-account. After the 90-day waiting period, account data will be moved to the deleted account database for future reference.',
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
      subtitle: 'Terms for using Wedding360 – Planner & Budget.',
      children: [
        _PolicySection(title: 'Last updated', body: 'May 21, 2026'),
        _PolicySection(
          title: 'Use of the app',
          body:
              'Wedding360 – Planner & Budget helps you plan wedding expenses, purchases, reminders, and related dashboard information. You are responsible for the accuracy of the information you enter.',
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
              'You can request account deletion from the Delete Account page after verifying your current sign-in method. The request is scheduled for 90 days. Signing in again during that period automatically revokes the request, and you must submit a new request if you still want deletion.',
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
          title: 'What happens next',
          body:
              'Your account deletion request will be scheduled for 90 days after verification. During this period you can still sign in. Signing in automatically revokes the deletion request, so you must submit a new request if you still want the account deleted.',
        ),
        if (user == null)
          _SignedOutDeletePanel()
        else ...[
          _AccountSummary(email: user.email ?? 'Signed-in account'),
          const _PolicySection(
            title: 'Verification required',
            body:
                'For your security, verify your current sign-in method first. The deletion request button is enabled only after verification succeeds.',
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
                : () => _confirmScheduleDeletion(user),
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
            label: const Text('Request account deletion'),
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

  Future<void> _confirmScheduleDeletion(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Account Deletion'),
        content: const Text(
          'Your account will be scheduled for deletion after 90 days. If you sign in during that period, the request will be cancelled. Continue?',
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
            child: const Text('Request deletion'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _scheduleAccountDeletion(user);
  }

  Future<void> _scheduleAccountDeletion(User user) async {
    await _runGuarded(() async {
      final scheduledAt = await AccountDeletionService.scheduleDeletion(user);
      await FirebaseAuth.instance.signOut();
      if (!kIsWeb) await GoogleSignIn().signOut();
      Get.offAllNamed(AppRoutes.auth);
      Get.snackbar(
        'Deletion requested',
        'Your account is scheduled for deletion on ${_formatLegalDate(scheduledAt)}. Signing in before then cancels the request.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 7),
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

String _formatLegalDate(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$day/$month/${local.year}';
}

class _LegalScaffold extends StatelessWidget {
  const _LegalScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    this.icon = Icons.privacy_tip_outlined,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.scaffoldColor,
      appBar: CustomAppBar(title: title, onBack: () => Get.back()),
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
                            icon,
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

class _SupportLinkTile extends StatelessWidget {
  const _SupportLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: destructive ? color : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppVersionSection extends StatelessWidget {
  const _AppVersionSection();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _appVersionFuture,
      builder: (context, snapshot) {
        return _PolicySection(
          title: 'App Version',
          body: snapshot.data ?? 'Loading...',
        );
      },
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
