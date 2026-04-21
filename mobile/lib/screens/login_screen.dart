// LoginScreen — email + password sign-in against /api/login.

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'outfit_manager_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget
{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
{
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose()
  {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Validates inputs, calls AuthService.login, and either routes to OutfitManager or
  // surfaces the backend error in a SnackBar.
  Future<void> _submit() async
  {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty)
    {
      _showError('Enter an email and password');
      return;
    }

    setState(() => _submitting = true);
    final result = await AuthService.login(email, password);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (!result.success)
    {
      _showError(result.error ?? 'Login failed');
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OutfitManagerScreen()),
    );
  }

  void _showError(String message)
  {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Log in'),
            ),
            TextButton(
              onPressed: _submitting
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
