import 'package:flutter/material.dart';
import 'package:gotify_client/components/common/form_field.dart';
import 'package:gotify_client/utils/form_validator.dart';
import 'package:provider/provider.dart';
import 'package:gotify_client/providers/auth_provider.dart';
import 'package:gotify_client/components/login_screen/credential_fields.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController serverUrlController;
  final TextEditingController tokenController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool showAdvancedLogin;
  final VoidCallback onLoginMethodToggle;
  final VoidCallback onLoginPressed;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.serverUrlController,
    required this.tokenController,
    required this.usernameController,
    required this.passwordController,
    required this.showAdvancedLogin,
    required this.onLoginMethodToggle,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AuthProvider authProvider = Provider.of<AuthProvider>(context);
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Server URL field is common for both login methods
            AppFormField(
              label: 'Server URL',
              hintText: 'https://gotify.example.com',
              controller: serverUrlController,
              prefixIcon: Icons.link,
              validator: AppFormValidator.validateServerUrl,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              suffixWidget: Icon(
                Icons.check_circle,
                color: colorScheme.primary.withValues(alpha: 0.5),
                size: 20,
              ),
            ),
            const SizedBox(height: 20),
            // Show either token field or username/password fields
            if (!showAdvancedLogin)
              ObscurableFormField(
                label: 'Client Token',
                hintText: 'Enter your client token',
                controller: tokenController,
                prefixIcon: Icons.vpn_key,
                validator: AppFormValidator.validateNotEmpty,
                textInputAction: TextInputAction.done,
                onEditingComplete: onLoginPressed,
              )
            else
              CredentialFields(
                usernameController: usernameController,
                passwordController: passwordController,
                onEditingComplete: onLoginPressed,
              ),
            const SizedBox(height: 24),
            // Login button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: authProvider.isLoading ? null : onLoginPressed,
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
                onPressed: onLoginMethodToggle,
                child: Text(
                  showAdvancedLogin
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
}
