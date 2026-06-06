import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbku_app/presentation/screens/welcome/login_sucess_screen.dart';
import 'package:sbku_app/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // ValueNotifier avoids full-tree rebuild on password toggle
  final _obscurePassword = ValueNotifier<bool>(true);
  // Track focus for field glow animation
  final _emailFocused = ValueNotifier<bool>(false);
  final _passwordFocused = ValueNotifier<bool>(false);
  // Track button press scale
  final _buttonPressed = ValueNotifier<bool>(false);

  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final AnimationController _logoController;

  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _headerSlideAnim;
  late final Animation<Offset> _emailSlideAnim;
  late final Animation<Offset> _passwordSlideAnim;
  late final Animation<Offset> _buttonSlideAnim;
  late final Animation<double> _logoScaleAnim;

  static const _primary = Color(0xFFE84E0F);
  static const _primaryDark = Color(0xFFBF3B08);
  static const _primaryLight = Color(0xFFFFF3EF);

  @override
  void initState() {
    super.initState();

    // Faster overall fade: 500ms
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    // Staggered slide: 600ms total window
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    // Logo bounce-in: 550ms
    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    // Stagger each element by slicing the 0..1 interval
    _headerSlideAnim = _makeSlide(_slideController, 0.0, 0.55);
    _emailSlideAnim = _makeSlide(_slideController, 0.20, 0.75);
    _passwordSlideAnim = _makeSlide(_slideController, 0.35, 0.85);
    _buttonSlideAnim = _makeSlide(_slideController, 0.50, 1.0);

    _logoScaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));

    _emailFocus.addListener(() {
      _emailFocused.value = _emailFocus.hasFocus;
    });
    _passwordFocus.addListener(() {
      _passwordFocused.value = _passwordFocus.hasFocus;
    });

    // Kick off all animations together
    _fadeController.forward();
    _slideController.forward();
    _logoController.forward();
  }

  Animation<Offset> _makeSlide(
      AnimationController ctrl, double startInterval, double endInterval) {
    return Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: ctrl,
      curve: Interval(startInterval, endInterval, curve: Curves.easeOutCubic),
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _obscurePassword.dispose();
    _emailFocused.dispose();
    _passwordFocused.dispose();
    _buttonPressed.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Dismiss keyboard immediately
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => LoginSuccessScreen(
            userName: authProvider.user?.name,
          ),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(authProvider.errorMessage ?? 'Login failed')),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Resize so keyboard doesn't shift content abruptly
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo with elastic bounce-in
                        ScaleTransition(
                          scale: _logoScaleAnim,
                          child: _buildLogo(),
                        ),
                        const SizedBox(height: 28),
                        // Header with its own stagger
                        SlideTransition(
                          position: _headerSlideAnim,
                          child: _buildHeader(),
                        ),
                        const SizedBox(height: 32),
                        // Email field stagger
                        SlideTransition(
                          position: _emailSlideAnim,
                          child: _buildEmailField(),
                        ),
                        const SizedBox(height: 12),
                        // Password field stagger
                        SlideTransition(
                          position: _passwordSlideAnim,
                          child: _buildPasswordField(),
                        ),
                        const SizedBox(height: 24),
                        // Button stagger
                        SlideTransition(
                          position: _buttonSlideAnim,
                          child: _buildLoginButton(),
                        ),
                        const SizedBox(height: 18),
                        _buildFooterNote(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(children: [
      Positioned(
        top: -80,
        right: -60,
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: _primary.withOpacity(0.08)),
        ),
      ),
      Positioned(
        bottom: -100,
        left: -60,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: _primary.withOpacity(0.06)),
        ),
      ),
      Positioned(
        top: 160,
        left: 30,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: _primary.withOpacity(0.25)),
        ),
      ),
      Positioned(
        bottom: 200,
        right: 40,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: _primary.withOpacity(0.2)),
        ),
      ),
    ]);
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.28),
              blurRadius: 28,
              spreadRadius: -4,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            'assets/images/logo.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: _primaryLight,
              child:
                  const Icon(Icons.school_rounded, color: _primary, size: 48),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(children: [
      Text(
        'Welcome Back',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Sign in to continue',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500),
      ),
    ]);
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
    required bool isFocused,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;
    final focusedBorderColor = _primary;
    final fillColor = isDark
        ? (isFocused ? const Color(0xFF253043) : const Color(0xFF1E293B))
        : (isFocused ? const Color(0xFFFFF8F6) : Colors.grey.shade50);
    final iconBg = isFocused
        ? _primary.withOpacity(0.12)
        : (isDark ? const Color(0xFF253043) : _primaryLight);

    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(
          color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
          fontSize: 14),
      labelStyle: TextStyle(
          color: isFocused
              ? _primary
              : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500),
          fontSize: 14),
      prefixIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(left: 14, right: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            color: isFocused ? _primary : _primary.withOpacity(0.7), size: 18),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: suffix,
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: focusedBorderColor, width: 1.8)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.8)),
    );
  }

  Widget _buildEmailField() {
    return ValueListenableBuilder<bool>(
      valueListenable: _emailFocused,
      builder: (context, isFocused, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: _primary.withOpacity(0.18),
                      blurRadius: 16,
                      spreadRadius: -2,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: TextFormField(
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_passwordFocus),
            decoration: _fieldDecoration(
              label: 'Email',
              hint: 'your@email.com',
              icon: Icons.email_outlined,
              isFocused: isFocused,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your email';
              if (!v.contains('@')) return 'Please enter a valid email';
              return null;
            },
          ),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return ValueListenableBuilder<bool>(
      valueListenable: _passwordFocused,
      builder: (context, isFocused, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: _primary.withOpacity(0.18),
                      blurRadius: 16,
                      spreadRadius: -2,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: ValueListenableBuilder<bool>(
            valueListenable: _obscurePassword,
            builder: (context, obscure, _) {
              return TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: obscure,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _login(),
                decoration: _fieldDecoration(
                  label: 'Password',
                  hint: '••••••••',
                  icon: Icons.lock_outlined,
                  isFocused: isFocused,
                  suffix: IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        key: ValueKey(obscure),
                        color: isFocused
                            ? _primary.withOpacity(0.7)
                            : Colors.grey.shade400,
                        size: 20,
                      ),
                    ),
                    onPressed: () =>
                        _obscurePassword.value = !_obscurePassword.value,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Please enter your password';
                  return null;
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isLoading = authProvider.isLoading;
        return ValueListenableBuilder<bool>(
          valueListenable: _buttonPressed,
          builder: (context, pressed, _) {
            return GestureDetector(
              onTapDown: isLoading ? null : (_) => _buttonPressed.value = true,
              onTapUp: isLoading ? null : (_) => _buttonPressed.value = false,
              onTapCancel: () => _buttonPressed.value = false,
              child: AnimatedScale(
                scale: pressed && !isLoading ? 0.96 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: pressed && !isLoading
                          ? [_primaryDark, _primaryDark]
                          : [_primary, _primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: pressed || isLoading
                        ? []
                        : [
                            BoxShadow(
                              color: _primary.withOpacity(0.38),
                              blurRadius: 20,
                              spreadRadius: -4,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: isLoading ? null : _login,
                      splashColor: Colors.white.withOpacity(0.1),
                      highlightColor: Colors.white.withOpacity(0.05),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded,
                                      color: Colors.white, size: 18),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFooterNote() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline_rounded,
                size: 14,
                color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400),
            const SizedBox(width: 6),
            Text(
              'Contact admin to create an account',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
