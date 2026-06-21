import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/core/utils/responsive_layout.dart';
import 'package:kalayanaexpresstracker/app/modules/auth/auth_controller.dart';
import 'package:kalayanaexpresstracker/app/routes/app_pages.dart';

const _authPrimary = Color(0xFF9D123F);
const _authPrimaryDark = Color(0xFF5B071B);
const _authGold = Color(0xFFE7AD4F);
const _authGoldDeep = Color(0xFFB87A25);
const _authInk = Color(0xFF421018);
const _authCream = Color(0xFFFFF7ED);
const _authCard = Color(0xFFFFFBF5);

class AuthView extends GetView<AuthController> {
  AuthView({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _authCream,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final topInset = MediaQuery.paddingOf(context).top;
            final safeTopInset = topInset == 0 ? 52.0 : topInset;
            final compact = constraints.maxHeight < 740;
            final heroHeight = compact ? 318.0 : 398.0;
            final sheetLift = compact ? -42.0 : -80.0;
            final desktop = isDesktop(context);

            return DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF2E2), Color(0xFFFFFBF5)],
                ),
              ),
              child: desktop
                  ? _DesktopAuthLayout(formKey: _formKey, compact: compact)
                  : SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom: 22 + MediaQuery.paddingOf(context).bottom,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 430),
                          child: Column(
                            children: [
                              _HeroSection(
                                height: heroHeight,
                                topInset: safeTopInset,
                                compact: compact,
                              ),
                              Transform.translate(
                                offset: Offset(0, sheetLift),
                                child: Column(
                                  children: [
                                    _AuthForm(
                                      formKey: _formKey,
                                      compact: compact,
                                    ),
                                    SizedBox(height: compact ? 8 : 12),
                                    const _LegalFooter(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _DesktopAuthLayout extends StatelessWidget {
  const _DesktopAuthLayout({required this.formKey, required this.compact});

  final GlobalKey<FormState> formKey;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          36,
          32,
          36,
          32 + MediaQuery.paddingOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _authCard.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
              boxShadow: [
                BoxShadow(
                  color: _authPrimaryDark.withValues(alpha: 0.14),
                  blurRadius: 46,
                  offset: const Offset(0, 24),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(flex: 6, child: _DesktopHeroPanel()),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(44, 42, 44, 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HeroCopy(compact: false),
                          const SizedBox(height: 24),
                          _AuthForm(
                            formKey: formKey,
                            compact: compact,
                            margin: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 18),
                          const _LegalFooter(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopHeroPanel extends StatelessWidget {
  const _DesktopHeroPanel();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/auth_wedding_hero.png',
          fit: BoxFit.cover,
          alignment: const Alignment(0.58, 0),
          filterQuality: FilterQuality.high,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xF25B071B), Color(0xB89D123F), Color(0x309D123F)],
              stops: [0, 0.56, 1],
            ),
          ),
        ),
        Positioned(left: 44, top: 42, child: _HeroBrand(compact: false)),
        Positioned(
          left: 44,
          right: 44,
          bottom: 44,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Plan your wedding budget with clarity',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Track expenses, reminders, shopping, and shared payments in one calm planning space.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.86),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.height,
    required this.topInset,
    required this.compact,
  });

  final double height;
  final double topInset;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeroArcClipper(),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/auth_wedding_hero.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xEA5B071B),
                    Color(0xB89D123F),
                    Color(0x389D123F),
                  ],
                  stops: [0, 0.50, 1],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    _authPrimary.withValues(alpha: 0.32),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              left: 30,
              top: topInset + (compact ? 22 : 42),
              child: _HeroBrand(compact: compact),
            ),
            Positioned(
              left: 30,
              right: 24,
              bottom: compact ? 56 : 100,
              child: _HeroCopy(compact: compact),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBrand extends StatelessWidget {
  const _HeroBrand({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/logo.png',
          width: compact ? 46 : 56,
          height: compact ? 46 : 56,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        SizedBox(height: compact ? 6 : 8),
        Text(
          'Kalyana',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            height: 0.96,
            fontSize: compact ? 22 : 26,
          ),
        ),
        SizedBox(height: compact ? 2 : 4),
        Text(
          'Expense Tracker',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFFFFD783),
            fontWeight: FontWeight.w500,
            fontSize: compact ? 13 : 15,
          ),
        ),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Get.find<AuthController>().isCreate.value
                ? 'Begin Your Plan'
                : 'Welcome Back ✨',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.08,
            ).copyWith(fontSize: compact ? 20 : 22),
          ),
          SizedBox(height: compact ? 4 : 6),
          Text(
            Get.find<AuthController>().isCreate.value
                ? 'Create your wedding command center'
                : 'Plan your forever beautifully',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              height: 1.2,
              fontSize: compact ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthForm extends GetView<AuthController> {
  const _AuthForm({
    required this.formKey,
    required this.compact,
    this.margin = const EdgeInsets.symmetric(horizontal: 28),
  });

  final GlobalKey<FormState> formKey;
  final bool compact;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final sidePadding = compact ? 16.0 : 18.0;
    final gap = compact ? 10.0 : 8.0;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: _authCard.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _authPrimaryDark.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: _authGold.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          sidePadding,
          compact ? 18 : 28,
          sidePadding,
          compact ? 18 : 28,
        ),
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
                  if (controller.isCreate.value) ...[
                    const _FieldLabel('Name'),
                    TextFormField(
                      controller: controller.name,
                      decoration: _authInputDecoration(
                        hintText: 'Enter your name',
                        icon: Icons.person_outline_rounded,
                        compact: compact,
                      ),
                      validator: _required,
                    ),
                    SizedBox(height: gap),
                  ],
                  const _FieldLabel('Email'),
                  TextFormField(
                    controller: controller.email,
                    decoration: _authInputDecoration(
                      hintText: 'Enter your email',
                      icon: Icons.mail_outline_rounded,
                      compact: compact,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _required,
                  ),
                  SizedBox(height: gap),
                  const _FieldLabel('Password'),
                  TextFormField(
                    controller: controller.password,
                    obscureText: controller.obscurePassword.value,
                    decoration: _authInputDecoration(
                      hintText: 'Enter your password',
                      icon: Icons.lock_outline_rounded,
                      compact: compact,
                      suffix: IconButton(
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: controller.loading.value
                            ? null
                            : controller.resetPassword,
                        style: TextButton.styleFrom(
                          foregroundColor: _authGoldDeep,
                          padding: const EdgeInsets.fromLTRB(12, 6, 0, 4),
                          minimumSize: const Size(0, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (controller.isCreate.value) ...[
                    SizedBox(height: gap),
                    const _FieldLabel('Wedding date'),
                    TextFormField(
                      readOnly: true,
                      onTap: controller.pickWeddingDate,
                      decoration: _authInputDecoration(
                        hintText: controller.weddingDate.value == null
                            ? 'Wedding date'
                            : formatDate(controller.weddingDate.value!),
                        icon: Icons.calendar_month_outlined,
                        compact: compact,
                      ),
                    ),
                    SizedBox(height: gap),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.groom,
                            decoration: _authInputDecoration(
                              hintText: 'Groom',
                              compact: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: controller.bride,
                            decoration: _authInputDecoration(
                              hintText: 'Bride',
                              compact: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: compact ? 18 : 16),
                  _PrimaryActionButton(formKey: formKey, compact: compact),
                  SizedBox(height: compact ? 16 : 24),
                  const _DividerLabel(),
                  SizedBox(height: compact ? 14 : 20),
                  _GoogleButton(compact: compact),
                  SizedBox(height: compact ? 12 : 20),
                  _AccountSwitch(compact: compact),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _authInputDecoration({
    required String hintText,
    IconData? icon,
    Widget? suffix,
    bool compact = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.64),
      contentPadding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 18,
        vertical: compact ? 13 : 17,
      ),
      prefixIcon: icon == null ? null : _InputIcon(icon, compact: compact),
      suffixIcon: suffix,
      prefixIconConstraints: BoxConstraints(
        minWidth: compact ? 58 : 68,
        maxWidth: compact ? 58 : 68,
        minHeight: compact ? 54 : 62,
      ),
      suffixIconColor: _authPrimary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: _authGold.withValues(alpha: 0.42)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: _authGold.withValues(alpha: 0.42)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _authGold, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: ThemeColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: ThemeColors.error, width: 1.4),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
}

class _InputIcon extends StatelessWidget {
  const _InputIcon(this.icon, {required this.compact});

  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 58 : 68,
      child: Center(
        child: Container(
          width: compact ? 36 : 42,
          height: compact ? 36 : 42,
          decoration: BoxDecoration(
            color: _authPrimary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _authPrimary, size: compact ? 20 : 22),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends GetView<AuthController> {
  const _PrimaryActionButton({required this.formKey, required this.compact});

  final GlobalKey<FormState> formKey;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _authPrimary.withValues(alpha: 0.34),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: compact ? 52 : 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF9A0D38), Color(0xFFE00C5B)],
            ),
          ),
          child: Obx(
            () => InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: controller.loading.value
                  ? null
                  : () => controller.submit(formKey),
              child: Center(
                child: controller.loading.value
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.isCreate.value
                                ? 'Create account'
                                : 'Login',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
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
}

class _GoogleButton extends GetView<AuthController> {
  const _GoogleButton({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => OutlinedButton(
        onPressed: controller.loading.value
            ? null
            : controller.signInWithGoogle,
        style: OutlinedButton.styleFrom(
          foregroundColor: _authInk,
          backgroundColor: Colors.white.withValues(alpha: 0.88),
          side: BorderSide(color: _authPrimaryDark.withValues(alpha: 0.06)),
          minimumSize: Size.fromHeight(compact ? 52 : 56),
          elevation: 6,
          shadowColor: _authPrimaryDark.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GoogleGlyph(),
            SizedBox(width: 16),
            Flexible(
              child: Text(
                'Continue with Google',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSwitch extends GetView<AuthController> {
  const _AccountSwitch({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            controller.isCreate.value
                ? 'Already have an account? '
                : "Don’t have an account? ",
            style: TextStyle(
              color: _authInk,
              fontSize: compact ? 15 : 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: controller.loading.value ? null : controller.isCreate.toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                controller.isCreate.value ? 'Sign in' : 'Sign up',
                style: TextStyle(
                  color: _authGoldDeep,
                  fontSize: compact ? 15 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalFooter extends StatelessWidget {
  const _LegalFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 18,
        runSpacing: 8,
        children: [
          _FooterLink(
            label: 'Privacy Policy',
            onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
          ),
          _FooterLink(
            label: 'Terms & Conditions',
            onTap: () => Get.toNamed(AppRoutes.termsConditions),
          ),
          _FooterLink(
            label: 'Delete Account',
            onTap: () => Get.toNamed(AppRoutes.deleteAccount),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: _authInk,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: _authInk,
          fontSize: 12,
          fontWeight: FontWeight.w500,
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
        Expanded(child: Divider(color: _authGold.withValues(alpha: 0.42))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: TextStyle(
              color: _authGoldDeep,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(child: Divider(color: _authGold.withValues(alpha: 0.42))),
      ],
    );
  }
}

class _HeroArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 72)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height + 36,
        size.width,
        size.height - 72,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 24,
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
