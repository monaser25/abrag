import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../../core/config/secure_storage_provider.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final storage = ref.read(secureStorageProvider);
    final savedEmail = await storage.read(key: 'saved_email');
    final savedPassword = await storage.read(key: 'saved_password');
    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final storage = ref.read(secureStorageProvider);
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_rememberMe) {
        await storage.write(key: 'saved_email', value: email);
        await storage.write(key: 'saved_password', value: password);
      } else {
        await storage.delete(key: 'saved_email');
        await storage.delete(key: 'saved_password');
      }

      ref.read(loginControllerProvider.notifier).login(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    ref.listen<AsyncValue<void>>(loginControllerProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.loginError(error.toString())),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
      );
    });

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            const AbragLogo(size: 84, radius: 26, glow: true),
                            const SizedBox(height: 14),
                            Text(
                              l10n.loginTitle,
                              style: AppTextStyles.h1.copyWith(
                                color: colors.ink,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.loginSubtitle,
                              style: AppTextStyles.bodyS.copyWith(
                                color: colors.ink2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        AppTextField(
                          label: l10n.emailLabel,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          prefixIcon: Icons.mail_outline,
                          validator: (value) =>
                              value != null && value.isNotEmpty
                              ? null
                              : l10n.requiredField,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: l10n.passwordLabel,
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          prefixIcon: Icons.lock_outline,
                          suffix: IconButton(
                            onPressed: () =>
                                setState(() => _showPassword = !_showPassword),
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: _showPassword ? colors.brand : colors.ink3,
                            ),
                          ),
                          validator: (value) =>
                              value != null && value.isNotEmpty
                              ? null
                              : l10n.requiredField,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () =>
                                  setState(() => _rememberMe = !_rememberMe),
                              child: Row(
                                children: [
                                  Switch(
                                    value: _rememberMe,
                                    onChanged: (val) =>
                                        setState(() => _rememberMe = val),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'تذكر بيانات الدخول',
                                    style: AppTextStyles.bodyS.copyWith(
                                      color: colors.ink2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => context.go('/forgot_password'),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  'نسيت كلمة المرور؟',
                                  style: AppTextStyles.bodyS.copyWith(
                                    color: colors.brand,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: l10n.loginButton,
                          expand: true,
                          loading: loginState.isLoading,
                          onPressed: loginState.isLoading ? null : _login,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SkylineAccent(height: 48, opacity: 0.08),
          ],
        ),
      ),
    );
  }
}
