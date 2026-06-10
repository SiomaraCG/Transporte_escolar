import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/navigation/routes.dart';
import '../../data/models/app_user.dart';
import '../../data/services/mock_database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _keepMeSignedIn = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final db = Provider.of<MockDatabase>(context, listen: false);
    final success = await db.login(_emailController.text, _passwordController.text);
    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        // Navigate based on user role
        switch (db.currentUser?.role) {
          case UserRole.admin:
            Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
            break;
          case UserRole.driver:
            Navigator.pushReplacementNamed(context, AppRoutes.driverDashboard);
            break;
          case UserRole.parent:
            Navigator.pushReplacementNamed(context, AppRoutes.parentDashboard);
            break;
          default:
            Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales incorrectas. Intenta de nuevo.'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Minimalist App Header Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_bus_rounded,
                      size: 64,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Page Title
                const Text(
                  'Iniciar Sesión',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ingresa tus credenciales para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 36),

                // Form Fields (Email & Password)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor ingrese su correo';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Ingrese un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor ingrese su contraseña';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Keep me signed in & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _keepMeSignedIn,
                          activeColor: AppColors.accent,
                          onChanged: (val) {
                            setState(() {
                              _keepMeSignedIn = val ?? true;
                            });
                          },
                        ),
                        const Text(
                          'Mantener sesión iniciada',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enlace para restablecer contraseña enviado.')),
                        );
                      },
                      child: const Text(
                        '¿Olvidó su contraseña?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDark),
                        )
                      : const Text('Iniciar Sesión'),
                ),
                const SizedBox(height: 24),

                // Social separator
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'O ingresa con',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 24),

                // Continue with Google button
                OutlinedButton(
                  onPressed: () async {
                    // Quick log in as parent for convenience
                    final navigator = Navigator.of(context);
                    setState(() => _isLoading = true);
                    final db = Provider.of<MockDatabase>(context, listen: false);
                    await db.login('padre@transporte.com', 'parent123');
                    setState(() => _isLoading = false);
                    navigator.pushReplacementNamed(AppRoutes.parentDashboard);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.g_mobiledata_rounded, size: 36, color: AppColors.accent),
                      const SizedBox(width: 8),
                      const Text(
                        'Continuar con Google',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Create account redirect link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes una cuenta? ',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: const Text(
                        'Crear una cuenta',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Admin/Driver Quick info panel
                Card(
                  elevation: 0,
                  color: Colors.grey[100],
                  margin: const EdgeInsets.only(top: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Cuentas de demostración:',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '• Admin: admin@transporte.com (Clave: admin123)\n'
                          '• Conductor: conductor@transporte.com (Clave: driver123)\n'
                          '• Padre: padre@transporte.com (Clave: parent123)',
                          style: TextStyle(fontSize: 10, color: AppColors.textMuted, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
