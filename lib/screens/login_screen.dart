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
  final _tokenController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showAdvancedLogin = false;
  bool _obscureToken = true;
  bool _obscurePassword = true;

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildLogoHeader(),
              const SizedBox(height: 32),
              _buildLoginForm(),
              const SizedBox(height: 16),
              _buildHelperLinks(),
              const SizedBox(height: 24),
              _buildVersionInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_active,
            size: 40,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to Gotify',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _showAdvancedLogin
              ? 'Login with your credentials'
              : 'Enter your client token to continue',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Server URL field is common for both login methods
            _buildServerUrlField(),
            const SizedBox(height: 20),

            // Show either token field or username/password fields
            if (!_showAdvancedLogin)
              _buildTokenField()
            else
              _buildCredentialFields(),

            const SizedBox(height: 24),

            // Login button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: authProvider.isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: authProvider.isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Toggle between login methods
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showAdvancedLogin = !_showAdvancedLogin;
                  });
                },
                child: Text(
                  _showAdvancedLogin
                      ? 'Use token authentication instead'
                      : 'Use username & password instead',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerUrlField() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Server URL',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _serverUrlController,
          decoration: InputDecoration(
            hintText: 'https://gotify.example.com',
            prefixIcon: Icon(Icons.link, color: colorScheme.primary),
            suffixIcon: Icon(
              Icons.check_circle,
              color: colorScheme.primary.withValues(alpha: 0.5),
              size: 20,
            ),
          ),
          validator: AuthFormValidator.validateServerUrl,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildTokenField() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Client Token',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _tokenController,
          decoration: InputDecoration(
            hintText: 'Enter your client token',
            prefixIcon: Icon(Icons.vpn_key, color: colorScheme.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureToken ? Icons.visibility : Icons.visibility_off,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscureToken = !_obscureToken;
                });
              },
            ),
          ),
          validator: AuthFormValidator.validateToken,
          obscureText: _obscureToken,
          textInputAction: TextInputAction.done,
          onEditingComplete: _login,
        ),
      ],
    );
  }

  Widget _buildCredentialFields() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: 'Enter your username',
            prefixIcon: Icon(Icons.person, color: colorScheme.primary),
          ),
          validator: AuthFormValidator.validateUsername,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          validator: AuthFormValidator.validatePassword,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onEditingComplete: _login,
        ),
      ],
    );
  }

  Widget _buildHelperLinks() {
    final colorScheme = Theme.of(context).colorScheme;

    return TextButton.icon(
      onPressed: () {
        _showHelpDialog();
      },
      icon: Icon(
        Icons.help_outline,
        size: 18,
        color: colorScheme.primary,
      ),
      label: Text(
        'How to get a client token?',
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 14,
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Getting a Client Token'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'To get a client token:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Log in to your Gotify server web interface'),
              Text('2. Go to "CLIENTS" section'),
              Text('3. Create a new client or select an existing one'),
              Text('4. Copy the generated token'),
              SizedBox(height: 16),
              Text(
                'Note: Client tokens are used for logging into this app. '
                'They are different from application tokens, which are used for sending messages.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Text(
      'Gotify Client v1.0.0',
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
