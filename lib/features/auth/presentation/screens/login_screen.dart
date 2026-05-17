import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../../core/config/secure_storage_provider.dart';

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

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.apartment, size: 80, color: Color(0xFFF4A225)),
                const SizedBox(height: 24),
                Text(
                  l10n.loginTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.loginSubtitle,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.emailLabel,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) => value != null && value.isNotEmpty
                      ? null
                      : l10n.requiredField,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.passwordLabel,
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) => value != null && value.isNotEmpty
                      ? null
                      : l10n.requiredField,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('تذكر بيانات الدخول'),
                  value: _rememberMe,
                  onChanged: (val) {
                    setState(() {
                      _rememberMe = val ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: loginState.isLoading ? null : _login,
                  child: loginState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.loginButton),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.go('/forgot_password');
                  },
                  child: const Text('نسيت كلمة المرور؟'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
