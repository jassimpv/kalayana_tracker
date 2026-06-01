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
    return Scaffold(
      backgroundColor: ThemeColors.scaffoldColor,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: ThemeColors.surfaceGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: ThemeColors.logoGold.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.primary.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.72),
            blurRadius: 18,
            offset: const Offset(-8, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
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
                    const SizedBox(height: 30),
                    if (controller.isCreate.value) ...[
                      const _FieldLabel('Name'),
                      TextFormField(
                        controller: controller.name,
                        decoration: const InputDecoration(
                          hintText: 'Enter your name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 16),
                    ],
                    const _FieldLabel('Email'),
                    TextFormField(
                      controller: controller.email,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: _required,
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel('Password'),
                    TextFormField(
                      controller: controller.password,
                      obscureText: controller.obscurePassword.value,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
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
                    if (!controller.isCreate.value) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: controller.loading.value
                              ? null
                              : controller.resetPassword,
                          style: TextButton.styleFrom(
                            foregroundColor: ThemeColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: const Size(48, 38),
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                    if (controller.isCreate.value) ...[
                      const SizedBox(height: 16),
                      const _FieldLabel('Wedding date'),
                      TextFormField(
                        readOnly: true,
                        onTap: controller.pickWeddingDate,
                        decoration: InputDecoration(
                          hintText: controller.weddingDate.value == null
                              ? 'Wedding date'
                              : formatDate(controller.weddingDate.value!),
                          prefixIcon: const Icon(Icons.calendar_month_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller.groom,
                              decoration: const InputDecoration(
                                hintText: 'Groom',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: controller.bride,
                              decoration: const InputDecoration(
                                hintText: 'Bride',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 22),
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              controller.isCreate.value
                                  ? 'Create account'
                                  : 'Login',
                            ),
                    ),
                    const SizedBox(height: 18),
                    const _DividerLabel(),
                    const SizedBox(height: 18),
                    OutlinedButton(
                      onPressed: controller.loading.value
                          ? null
                          : controller.signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemeColors.logoDeep,
                        backgroundColor: Colors.white.withValues(alpha: 0.58),
                        side: BorderSide(
                          color: ThemeColors.logoGold.withValues(alpha: 0.28),
                        ),
                        minimumSize: const Size.fromHeight(54),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _GoogleGlyph(),
                          SizedBox(width: 12),
                          Text('Google'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 38),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            controller.isCreate.value
                                ? 'Already have an account? '
                                : "Don't have an account? ",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: controller.loading.value
                                ? null
                                : () => controller.isCreate.toggle(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                controller.isCreate.value
                                    ? 'Sign in'
                                    : 'Sign up',
                                style: TextStyle(
                                  color: ThemeColors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
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
    return Column(
      children: [
        const _WeddingRingMark(size: 88),
        const SizedBox(height: 12),
        Text(
          'Kalyana',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: ThemeColors.logoDeep,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Expense Tracker',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: ThemeColors.logoDeep,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        text,
        style: TextStyle(
          color: ThemeColors.logoDeep,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: ThemeColors.logoGold.withValues(alpha: 0.28)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'or continue with',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: ThemeColors.logoGold.withValues(alpha: 0.28)),
        ),
      ],
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 22,
      child: CustomPaint(painter: _GoogleGlyphPainter()),
    );
  }
}

class _GoogleGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    void arc(Color color, double start, double sweep) {
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt,
      );
    }

    arc(const Color(0xFF4285F4), -0.10, 1.40);
    arc(const Color(0xFF34A853), 1.30, 1.30);
    arc(const Color(0xFFFBBC05), 2.60, 1.05);
    arc(const Color(0xFFEA4335), 3.65, 1.70);

    final blue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(size.width * 0.54, size.height * 0.50),
      Offset(size.width * 0.94, size.height * 0.50),
      blue,
    );
    canvas.drawLine(
      Offset(size.width * 0.78, size.height * 0.50),
      Offset(size.width * 0.78, size.height * 0.67),
      blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WeddingRingMark extends StatelessWidget {
  const _WeddingRingMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _WeddingRingPainter()),
    );
  }
}

class _WeddingRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFFF8D77A), Color(0xFFC37B16), Color(0xFFFFE39A)],
      ).createShader(Offset.zero & size);
    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..color = ThemeColors.primary.withValues(alpha: 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final left = Rect.fromCircle(
      center: Offset(size.width * 0.42, size.height * 0.58),
      radius: size.width * 0.23,
    );
    final right = Rect.fromCircle(
      center: Offset(size.width * 0.58, size.height * 0.58),
      radius: size.width * 0.23,
    );
    canvas.drawOval(left, shadow);
    canvas.drawOval(right, shadow);
    canvas.drawOval(left, gold);
    canvas.drawOval(right, gold);

    final gem = Path()
      ..moveTo(size.width * 0.50, size.height * 0.10)
      ..lineTo(size.width * 0.66, size.height * 0.25)
      ..lineTo(size.width * 0.50, size.height * 0.38)
      ..lineTo(size.width * 0.34, size.height * 0.25)
      ..close();
    final gemPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFE39A), Color(0xFFD99A3F)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(gem, gemPaint);
    canvas.drawLine(
      Offset(size.width * 0.39, size.height * 0.25),
      Offset(size.width * 0.61, size.height * 0.25),
      gemPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.10),
      Offset(size.width * 0.50, size.height * 0.38),
      gemPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
