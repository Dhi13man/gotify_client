import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gotify_client/providers/auth_provider.dart';
import 'package:gotify_client/models/auth_models.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
    final success = await _attemptLogin(config);

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

  Future<bool> _attemptLogin(AuthConfig config) async {
    return Provider.of<AuthProvider>(context, listen: false).login(config);
  }

  void _showLoginError() {
    final errorMessage =
        Provider.of<AuthProvider>(context, listen: false).error ??
            'Login failed';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _toggleAuthMethod(bool useToken) {
    setState(() => _useToken = useToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
    return Card(
      elevation: 8,
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
              const Text(
                'Gotify Client',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildServerUrlField(),
              const SizedBox(height: 16),
              _buildAuthMethodSelector(),
              const SizedBox(height: 16),
              _useToken ? _buildTokenField() : _buildCredentialFields(),
              const SizedBox(height: 24),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.link),
      ),
      validator: AuthFormValidator.validateServerUrl,
      keyboardType: TextInputType.url,
    );
  }

  Widget _buildAuthMethodSelector() {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Authentication Method'),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(
              _useToken ? 'Using Client Token' : 'Using Username & Password'),
          value: _useToken,
          onChanged: _toggleAuthMethod,
        ),
      ],
    );
  }

  Widget _buildTokenField() {
    return TextFormField(
      controller: _tokenController,
      decoration: InputDecoration(
        labelText: 'Client Token',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.vpn_key),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.person),
          ),
          validator: AuthFormValidator.validateUsername,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.lock),
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
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.blue[700],
        ),
        child: authProvider.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Login',
                style: TextStyle(fontSize: 18, color: Colors.white),
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
      child: Text(error, style: const TextStyle(color: Colors.red)),
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
