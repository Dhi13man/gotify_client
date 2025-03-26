import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gotify_client/providers/auth_provider.dart';
import 'package:gotify_client/models/auth_models.dart';
import 'package:gotify_client/components/login_screen/logo_header.dart';
import 'package:gotify_client/components/login_screen/login_form.dart';
import 'package:gotify_client/components/login_screen/helper_links.dart';
import 'package:gotify_client/components/login_screen/version_info.dart';
import 'package:gotify_client/components/login_screen/help_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverUrlController = TextEditingController();
  final _tokenController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showAdvancedLogin = false;

  @override
  void dispose() {
    _serverUrlController.dispose();
    _tokenController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final config = _createAuthConfig();

    // Store ScaffoldMessenger before the async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(config);

    if (!mounted) return;

    if (!success) {
      final errorMessage = authProvider.error ?? 'Login failed';
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  AuthConfig _createAuthConfig() {
    return AuthConfig(
      serverUrl: _serverUrlController.text.trim(),
      username: _showAdvancedLogin ? _usernameController.text : null,
      password: _showAdvancedLogin ? _passwordController.text : null,
      clientToken: _showAdvancedLogin ? null : _tokenController.text,
    );
  }

  void _toggleLoginMethod() =>
      setState(() => _showAdvancedLogin = !_showAdvancedLogin);

  void _showHelpDialog() =>
      showDialog(context: context, builder: (context) => const HelpDialog());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              LogoHeader(showAdvancedLogin: _showAdvancedLogin),
              const SizedBox(height: 32),
              LoginForm(
                formKey: _formKey,
                serverUrlController: _serverUrlController,
                tokenController: _tokenController,
                usernameController: _usernameController,
                passwordController: _passwordController,
                showAdvancedLogin: _showAdvancedLogin,
                onLoginMethodToggle: _toggleLoginMethod,
                onLoginPressed: _login,
              ),
              const SizedBox(height: 16),
              HelperLinks(onHelpPressed: _showHelpDialog),
              const SizedBox(height: 24),
              const VersionInfo(),
            ],
          ),
        ),
      ),
    );
  }
}
