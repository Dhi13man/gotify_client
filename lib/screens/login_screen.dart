import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gotify_client/providers/auth_provider.dart';
import 'package:gotify_client/models/auth_models.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _useToken = false;

  @override
  void dispose() {
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final config = _createAuthConfig();
    final success =
        await Provider.of<AuthProvider>(context, listen: false).login(config);
    if (!success && mounted) {
      _showLoginError();
    }
  }

  AuthConfig _createAuthConfig() {
    return AuthConfig(
      serverUrl: _serverUrlController.text.trim(),
      username: _useToken ? null : _usernameController.text,
      password: _useToken ? null : _passwordController.text,
      clientToken: _useToken ? _tokenController.text : null,
    );
  }

  void _showLoginError() {
    final errorMessage =
        Provider.of<AuthProvider>(context, listen: false).error ??
            'Login failed';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildLoginCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    final colorScheme = Theme.of(context).colorScheme;
    colorScheme;

    return Card(
      elevation: 3,
      surfaceTintColor: Colors.white,
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_active,
                    size: 28,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Gotify Client',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildServerUrlField(),
              const SizedBox(height: 24),
              _buildAuthMethodSelector(),
              const SizedBox(height: 24),
              _useToken ? _buildTokenField() : _buildCredentialFields(),
              const SizedBox(height: 32),
              _buildLoginButton(),
              _buildErrorMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerUrlField() {
    return TextFormField(
      controller: _serverUrlController,
      decoration: InputDecoration(
        labelText: 'Server URL',
        hintText: 'https://gotify.example.com',
        prefixIcon:
            Icon(Icons.link, color: Theme.of(context).colorScheme.primary),
      ),
      validator: AuthFormValidator.validateServerUrl,
      keyboardType: TextInputType.url,
    );
  }

  Widget _buildAuthMethodSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(color: colorScheme.outline.withValues(alpha: 0.5)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Authentication Method',
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: colorScheme.outline.withValues(alpha: 0.5)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
            color: colorScheme.surface,
          ),
          child: SwitchListTile(
            title: Text(
              _useToken ? 'Using Client Token' : 'Using Username & Password',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            activeColor: colorScheme.primary,
            value: _useToken,
            onChanged: (useToken) => setState(() => _useToken = useToken),
          ),
        ),
      ],
    );
  }

  Widget _buildTokenField() {
    return TextFormField(
      controller: _tokenController,
      decoration: InputDecoration(
        labelText: 'Client Token',
        prefixIcon:
            Icon(Icons.vpn_key, color: Theme.of(context).colorScheme.primary),
      ),
      validator: AuthFormValidator.validateToken,
      obscureText: true,
    );
  }

  Widget _buildCredentialFields() {
    return Column(
      children: [
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person,
                color: Theme.of(context).colorScheme.primary),
          ),
          validator: AuthFormValidator.validateUsername,
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon:
                Icon(Icons.lock, color: Theme.of(context).colorScheme.primary),
          ),
          validator: AuthFormValidator.validatePassword,
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    final authProvider = Provider.of<AuthProvider>(context);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : _login,
        child: authProvider.isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : const Text(
                'Login',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    final error = Provider.of<AuthProvider>(context).error;
    if (error == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        error,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Form validator for authentication
class AuthFormValidator {
  static String? validateServerUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter server URL';
    }
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      return 'URL must start with http:// or https://';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter username';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    return null;
  }

  static String? validateToken(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter client token';
    }
    return null;
  }
}
