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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Bold Background Shapes
          Positioned(
            top: -150,
            right: -100,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(60),
                ),
              ),
            ),
          ),
          if (isDark)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.2), // Subtle dimming for dark mode contrast
              ),
            ),
            
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    
                    // Brutalist/Premium Typography Header
                    Text(
                      'ACCESO.',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.textDark,
                        letterSpacing: -2,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'TRANSPORTE ESCOLAR',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDark ? AppColors.primary : AppColors.accent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 64),

                    // Form Fields (Email & Password)
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
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
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
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
                    const SizedBox(height: 20),

                    // Keep me signed in & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _keepMeSignedIn,
                                activeColor: AppColors.primary,
                                checkColor: AppColors.textDark,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) {
                                  setState(() {
                                    _keepMeSignedIn = val ?? true;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Recordarme',
                              style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Enlace para restablecer contraseña enviado.')),
                            );
                          },
                          child: Text(
                            '¿Olvidó su clave?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.primary : AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Login Button (Massive, High Contrast)
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.textDark),
                            )
                          : const Text(
                              'ENTRAR AHORA',
                              style: TextStyle(letterSpacing: 1.5, fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 32),

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
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 2),
                        foregroundColor: textColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.g_mobiledata_rounded, size: 28, color: textColor),
                          const SizedBox(width: 8),
                          Text(
                            'CONTINUAR CON GOOGLE',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              fontSize: 13,
                              letterSpacing: 0.5,
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
                          '¿No tienes acceso? ',
                          style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: Text(
                            'Regístrate',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.primary : AppColors.accent,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Admin/Driver Quick info panel
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CREDENCIALES DE DEMO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Admin: admin@transporte.com (admin123)\n'
                            'Conductor: conductor@transporte.com (driver123)\n'
                            'Padre: padre@transporte.com (parent123)',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
