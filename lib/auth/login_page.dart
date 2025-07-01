// lib/auth/login_page.dart
import 'package:flutter/material.dart';
import 'package:appflutter_supabase_chat/services/supabase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabaseService = SupabaseService();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await _supabaseService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (response.user != null) {
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/chat', (route) => false);
          }
        } else if (response.session == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: Verifique sus credenciales')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error de inicio de sesión: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const Icon(Icons.chat_bubble, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 24),
                const Text(
                  'Iniciar Sesión',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  validator: (value) => (value == null || !value.contains('@')) ? 'Email inválido' : null,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 6) ? 'La contraseña debe tener al menos 6 caracteres' : null,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text('Entrar'),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/register'),
                  child: const Text('¿No tienes cuenta? Regístrate'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
