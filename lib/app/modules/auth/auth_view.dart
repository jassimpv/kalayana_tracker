import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
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
            final compact = constraints.maxHeight < 740;
            final heroHeight = compact ? 318.0 : 398.0;
            final sheetLift = compact ? -42.0 : -60.0;

            return DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF2E2), Color(0xFFFFFBF5)],
                ),
              ),
              child: SingleChildScrollView(
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
                          topInset: topInset,
                          compact: compact,
                        ),
                        Transform.translate(
                          offset: Offset(0, sheetLift),
                          child: Column(
                            children: [
                              _AuthForm(formKey: _formKey, compact: compact),
                              SizedBox(height: compact ? 16 : 24),
                              _WeddingQuote(compact: compact),
                              SizedBox(height: compact ? 12 : 22),
                              _AccountSwitch(compact: compact),
                              SizedBox(height: compact ? 12 : 24),
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
              alignment: const Alignment(0.62, -0.08),
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
              bottom: compact ? 56 : 92,
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
        _WeddingRingMark(size: compact ? 36 : 44, light: true),
        SizedBox(height: compact ? 4 : 6),
        Text(
          'Kalyana',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            height: 0.96,
            fontSize: compact ? 22 : 26,
          ),
        ),
        SizedBox(height: compact ? 2 : 4),
        Text(
          'Expense Tracker',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFFFFD783),
            fontWeight: FontWeight.w800,
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
              fontSize: 22,
              fontWeight: FontWeight.w700,
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
              fontWeight: FontWeight.w800,
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
  const _AuthForm({required this.formKey, required this.compact});

  final GlobalKey<FormState> formKey;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final sidePadding = compact ? 16.0 : 18.0;
    final gap = compact ? 10.0 : 16.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
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
                    SizedBox(height: compact ? 8 : 12),
                    const _LoginOptionsRow(),
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
                  SizedBox(height: compact ? 18 : 26),
                  _PrimaryActionButton(formKey: formKey, compact: compact),
                  SizedBox(height: compact ? 16 : 24),
                  const _DividerLabel(),
                  SizedBox(height: compact ? 14 : 20),
                  _GoogleButton(compact: compact),
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

class _LoginOptionsRow extends GetView<AuthController> {
  const _LoginOptionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _RememberMeControl()),
        Obx(
          () => TextButton(
            onPressed: controller.loading.value
                ? null
                : controller.resetPassword,
            style: TextButton.styleFrom(
              foregroundColor: _authGoldDeep,
              padding: EdgeInsets.zero,
              minimumSize: const Size(48, 34),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Forgot Password?',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}

class _RememberMeControl extends StatefulWidget {
  const _RememberMeControl();

  @override
  State<_RememberMeControl> createState() => _RememberMeControlState();
}

class _RememberMeControlState extends State<_RememberMeControl> {
  bool _remember = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => _remember = !_remember),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _remember ? _authPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _authPrimary, width: 1.6),
            ),
            child: _remember
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : null,
          ),
          const SizedBox(width: 10),
          const Flexible(
            child: Text(
              'Remember me',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _authInk,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
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
        borderRadius: BorderRadius.circular(28),
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
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          height: compact ? 52 : 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFF9A0D38), Color(0xFFE00C5B)],
            ),
          ),
          child: Obx(
            () => InkWell(
              borderRadius: BorderRadius.circular(28),
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
                                : 'Continue',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 22),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 28,
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
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
              fontWeight: FontWeight.w700,
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
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeddingQuote extends StatelessWidget {
  const _WeddingQuote({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 34 : 42),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Divider(color: _authGold.withValues(alpha: 0.42)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '♥',
                  style: TextStyle(color: _authGold, fontSize: 20),
                ),
              ),
              Expanded(
                child: Divider(color: _authGold.withValues(alpha: 0.42)),
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!compact) const _LeafSprig(flipped: false),
              if (!compact) const SizedBox(width: 16),
              Flexible(
                child: Text(
                  'Every beautiful wedding\nstarts with perfect planning.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _authPrimary,
                    fontFamily: 'Outfit',
                    fontSize: compact ? 16 : 20,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    height: 1.34,
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.76),
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              if (!compact) const SizedBox(width: 16),
              if (!compact) const _LeafSprig(flipped: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeafSprig extends StatelessWidget {
  const _LeafSprig({required this.flipped});

  final bool flipped;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(flipped ? -1.0 : 1.0, 1.0, 1.0),
      child: CustomPaint(
        size: const Size(28, 58),
        painter: _LeafSprigPainter(),
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
        spacing: 16,
        runSpacing: 8,
        children: [
          _FooterLink(
            label: 'Privacy Policy',
            onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
          ),
          const _FooterDivider(),
          _FooterLink(
            label: 'Terms & Conditions',
            onTap: () => Get.toNamed(AppRoutes.termsConditions),
          ),
          const _FooterDivider(),
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
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _FooterDivider extends StatelessWidget {
  const _FooterDivider();

  @override
  Widget build(BuildContext context) {
    return Text(
      '|',
      style: TextStyle(
        color: _authGoldDeep.withValues(alpha: 0.48),
        fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _authInk,
          fontSize: 14,
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
        Expanded(child: Divider(color: _authGold.withValues(alpha: 0.42))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: TextStyle(
              color: _authGoldDeep,
              fontSize: 13,
              fontWeight: FontWeight.w900,
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

class _WeddingRingMark extends StatelessWidget {
  const _WeddingRingMark({required this.size, this.light = false});

  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _WeddingRingPainter(light: light)),
    );
  }
}

class _WeddingRingPainter extends CustomPainter {
  _WeddingRingPainter({required this.light});

  final bool light;

  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.054
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: light
            ? const [Color(0xFFFFF0B0), Color(0xFFE7AD4F), Color(0xFFFFE5A0)]
            : const [Color(0xFFF8D77A), Color(0xFFC37B16), Color(0xFFFFE39A)],
      ).createShader(Offset.zero & size);
    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.066
      ..color = (light ? Colors.black : ThemeColors.primary).withValues(
        alpha: light ? 0.16 : 0.10,
      )
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

    final diamondPath = Path()
      ..moveTo(size.width * 0.50, size.height * 0.07)
      ..lineTo(size.width * 0.70, size.height * 0.25)
      ..lineTo(size.width * 0.50, size.height * 0.44)
      ..lineTo(size.width * 0.30, size.height * 0.25)
      ..close()
      ..moveTo(size.width * 0.30, size.height * 0.25)
      ..lineTo(size.width * 0.70, size.height * 0.25)
      ..moveTo(size.width * 0.50, size.height * 0.07)
      ..lineTo(size.width * 0.50, size.height * 0.44)
      ..moveTo(size.width * 0.39, size.height * 0.15)
      ..lineTo(size.width * 0.61, size.height * 0.35);
    canvas.drawPath(diamondPath, gold);
  }

  @override
  bool shouldRepaint(covariant _WeddingRingPainter oldDelegate) =>
      oldDelegate.light != light;
}

class _LeafSprigPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _authGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final leaf = Paint()
      ..color = _authGold
      ..style = PaintingStyle.fill;

    final stem = Path()
      ..moveTo(size.width * 0.78, size.height * 0.92)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.52,
        size.width * 0.54,
        size.height * 0.08,
      );
    canvas.drawPath(stem, paint);

    for (var i = 0; i < 6; i++) {
      final t = (i + 1) / 7;
      final x = size.width * (0.70 - t * 0.42);
      final y = size.height * (0.86 - t * 0.70);
      final leafPath = Path()
        ..moveTo(x, y)
        ..quadraticBezierTo(x - 13, y - 3, x - 13, y - 16)
        ..quadraticBezierTo(x + 1, y - 12, x, y)
        ..close();
      canvas.drawPath(leafPath, leaf);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
