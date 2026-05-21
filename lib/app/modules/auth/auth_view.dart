import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/modules/auth/auth_controller.dart';
import 'package:kalayanaexpresstracker/app/routes/app_pages.dart';

class AuthView extends GetView<AuthController> {
  AuthView({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: ThemeColors.appBarGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: _AuthForm(formKey: _formKey),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthForm extends GetView<AuthController> {
  const _AuthForm({required this.formKey});

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: formKey,
          child: Obx(
            () => AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _AuthHeader(),
                  const SizedBox(height: 22),
                  Text(
                    controller.isCreate.value ? 'Create account' : 'Sign in',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    controller.isCreate.value
                        ? 'Set up your wedding planner.'
                        : 'Welcome back to Kalyana.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (controller.isCreate.value) ...[
                    TextFormField(
                      controller: controller.name,
                      decoration: const InputDecoration(
                        labelText: 'Your name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: controller.email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.alternate_email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controller.password,
                    obscureText: controller.obscurePassword.value,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () => controller.obscurePassword.toggle(),
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: _required,
                  ),
                  if (controller.isCreate.value) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      readOnly: true,
                      onTap: controller.pickWeddingDate,
                      decoration: InputDecoration(
                        labelText: controller.weddingDate.value == null
                            ? 'Wedding date'
                            : formatDate(controller.weddingDate.value!),
                        prefixIcon: const Icon(Icons.calendar_month_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.groom,
                            decoration: const InputDecoration(
                              labelText: 'Groom',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: controller.bride,
                            decoration: const InputDecoration(
                              labelText: 'Bride',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: controller.loading.value
                        ? null
                        : () => controller.submit(formKey),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: controller.loading.value
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            controller.isCreate.value
                                ? 'Create account'
                                : 'Sign in',
                          ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: controller.loading.value
                        ? null
                        : controller.signInWithGoogle,
                    icon: const Icon(Icons.g_mobiledata_rounded),
                    label: const Text('Continue with Google'),
                  ),
                  TextButton(
                    onPressed: controller.loading.value
                        ? null
                        : () => controller.isCreate.toggle(),
                    child: Text(
                      controller.isCreate.value
                          ? 'Already have an account? Sign in'
                          : 'New here? Create an account',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.privacyPolicy),
                        child: const Text('Privacy Policy'),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.deleteAccount),
                        child: const Text('Delete Account'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: ThemeColors.appBarGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(Icons.favorite_rounded, color: scheme.onPrimary),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kalyana',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              'Expense Tracker',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.outline),
            ),
          ],
        ),
      ],
    );
  }
}
