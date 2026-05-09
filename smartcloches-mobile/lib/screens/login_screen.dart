import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import '../widgets/glass_card.dart';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() => _error = 'Username tidak boleh kosong');
      return;
    }
    if (username.length < 3) {
      setState(() => _error = 'Username minimal 3 karakter');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Save locally
    await SupabaseService.saveUsername(username);

    // Register to Supabase
    final success = await SupabaseService.upsertUser(username: username);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Gagal terhubung ke server. Cek koneksi internet.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentPrimary.withValues(alpha: 0.12),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Smart Clothesline',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Masukkan username untuk memulai',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 36),

                // Username input
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'USERNAME',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textTertiary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'contoh: rizky_gm',
                          hintStyle: TextStyle(
                            color: AppTheme.textTertiary.withValues(alpha: 0.5),
                          ),
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppTheme.textTertiary,
                            size: 22,
                          ),
                          filled: true,
                          fillColor: AppTheme.bgColor,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppTheme.divider),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppTheme.accentPrimary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppTheme.danger),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppTheme.danger,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          errorText: _error,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Mulai',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Username digunakan untuk sistem peringatan hujan\ndi sekitar lokasi anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary.withValues(alpha: 0.7),
                    height: 1.5,
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
