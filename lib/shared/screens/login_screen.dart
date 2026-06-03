import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/database/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;
  String? _localError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _localError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final notifier = ref.read(authStateProvider.notifier);
    bool success;

    if (_isSignUp) {
      success = await notifier.register(username, password);
    } else {
      success = await notifier.login(username, password);
    }

    if (!success && mounted) {
      final state = ref.read(authStateProvider);
      setState(() {
        _localError = state.errorMessage ?? 'Authentication failed';
      });
    }
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _localError = null;
      _formKey.currentState?.reset();
      _usernameController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authStateProvider);

    // Deep Dark Theme / Charcoal HSL Hue 240, 10%, 6%
    const backgroundColor = Color(0xFF0F0F12);
    const surfaceColor = Color(0xFF1E1E24);
    const accentColor = Color(0xFF00E5FF); // Glowing Neon Cyan
    const secondaryAccentColor = Color(0xFF651FFF); // Neon Purple

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 1) Accent Neon Glows in the background
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.12),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: secondaryAccentColor.withValues(alpha: 0.12),
                    blurRadius: 90,
                    spreadRadius: 45,
                  ),
                ],
              ),
            ),
          ),

          // 2) Content Form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Logo
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: Image.asset(
                          'tinda_tract_icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const CircleAvatar(
                            backgroundColor: surfaceColor,
                            child: Icon(
                              Icons.storefront_rounded,
                              size: 40,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Tinda Tracker',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtitle
                    Text(
                      'Smart Pocket Ledger & Sales Tracker',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Glassmorphic Form Card Container
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                              width: 1.5,
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isSignUp ? 'Sign Up' : 'Sign In',
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Username field
                                Text(
                                  'USERNAME',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.4),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _usernameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your username',
                                    hintStyle: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.25),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person_outline_rounded,
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor:
                                        Colors.white.withValues(alpha: 0.02),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color:
                                            Colors.white.withValues(alpha: 0.08),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color:
                                            Colors.white.withValues(alpha: 0.08),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: accentColor,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().length < 4) {
                                      return 'Username must be at least 4 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Password field
                                Text(
                                  'PASSWORD',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.4),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    hintStyle: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.25),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline_rounded,
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor:
                                        Colors.white.withValues(alpha: 0.02),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color:
                                            Colors.white.withValues(alpha: 0.08),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color:
                                            Colors.white.withValues(alpha: 0.08),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: accentColor,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Error display
                                if (_localError != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.redAccent
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          color: Colors.redAccent,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _localError!,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],

                                // Submit Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed:
                                        state.isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      foregroundColor: backgroundColor,
                                      disabledBackgroundColor:
                                          accentColor.withValues(alpha: 0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: state.isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: backgroundColor,
                                            ),
                                          )
                                        : Text(
                                            _isSignUp
                                                ? 'CREATE ACCOUNT'
                                                : 'SIGN IN',
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Toggle mode button
                    TextButton(
                      onPressed: state.isLoading ? null : _toggleMode,
                      child: Text(
                        _isSignUp
                            ? 'Already have an account? Sign In'
                            : "Don't have an account? Sign Up",
                        style: GoogleFonts.inter(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
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
