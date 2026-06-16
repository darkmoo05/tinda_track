import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/google_fonts_shim.dart';

import '../../core/database/providers/auth_providers.dart';
import '../../core/l10n/l10n_extension.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  String _businessType = 'retail';

  bool _isSignUp = false;
  bool _obscurePassword = true;
  String? _localError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  String _getLocalizedAuthError(String err) {
    if (err == 'authErrorConnection') {
      return context.l10n.authErrorConnection;
    } else if (err == 'authErrorTimeout') {
      return context.l10n.authErrorTimeout;
    } else if (err == 'authErrorInvalidCredentials') {
      return context.l10n.authErrorInvalidCredentials;
    } else if (err == 'authErrorUsernameTaken') {
      return context.l10n.authErrorUsernameTaken;
    } else if (err == 'authErrorGeneric') {
      return context.l10n.authErrorGeneric;
    }
    return err.isNotEmpty ? err : context.l10n.authErrorGeneric;
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
      success = await notifier.register(
        username,
        password,
        businessName: _businessNameController.text.trim(),
        businessType: _businessType,
      );
    } else {
      success = await notifier.login(username, password);
    }

    if (!success && mounted) {
      final state = ref.read(authStateProvider);
      setState(() {
        _localError = _getLocalizedAuthError(state.errorMessage ?? '');
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? const Color(0xFF0F0F12) : const Color(0xFFF8FAFC);
    final surfaceColor = isDark ? const Color(0xFF1E1E24) : Colors.white;
    final accentColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF2563EB);
    final secondaryAccentColor = isDark ? const Color(0xFF651FFF) : const Color(0xFF059669);

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF475569);
    final textFormFillColor = isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF1F5F9);
    final borderAndDividerColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFCBD5E1);
    final labelColor = isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF475569);
    final dropdownColor = isDark ? surfaceColor : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
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
                    color: accentColor.withValues(alpha: isDark ? 0.12 : 0.03),
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
                    color: secondaryAccentColor.withValues(alpha: isDark ? 0.12 : 0.03),
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
                              CircleAvatar(
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
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtitle
                    Text(
                      'Smart Pocket Ledger & Sales Tracker',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: subtitleColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Glassmorphic Form Card Container
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: isDark ? 12 : 0, sigmaY: isDark ? 12 : 0),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.03) : surfaceColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.08) : borderAndDividerColor,
                              width: 1.5,
                            ),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
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
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                 // Username field
                                Text(
                                  'USERNAME',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: labelColor,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _usernameController,
                                  style: TextStyle(color: textColor),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your username',
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.25)
                                          : Colors.black.withValues(alpha: 0.38),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person_outline_rounded,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.4)
                                          : const Color(0xFF64748B),
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor: textFormFillColor,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: borderAndDividerColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: borderAndDividerColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: accentColor,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().length < 4) {
                                      return context.l10n.usernameValidator;
                                    }
                                    final regex = RegExp(r'^[a-zA-Z0-9]+$');
                                    if (!regex.hasMatch(v.trim())) {
                                      return context.l10n.usernameValidator;
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
                                    color: labelColor,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(color: textColor),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.25)
                                          : Colors.black.withValues(alpha: 0.38),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline_rounded,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.4)
                                          : const Color(0xFF64748B),
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.4)
                                            : const Color(0xFF64748B),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    filled: true,
                                    fillColor: textFormFillColor,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: borderAndDividerColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: borderAndDividerColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: accentColor,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.length < 6) {
                                      return context.l10n.passwordValidator;
                                    }
                                    return null;
                                  },
                                ),
                                if (_isSignUp) ...[
                                  const SizedBox(height: 20),
                                  Text(
                                    'BUSINESS NAME',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: labelColor,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _businessNameController,
                                    style: TextStyle(color: textColor),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your business name',
                                      hintStyle: TextStyle(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.25)
                                            : Colors.black.withValues(alpha: 0.38),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.storefront_outlined,
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.4)
                                            : const Color(0xFF64748B),
                                        size: 20,
                                      ),
                                      filled: true,
                                      fillColor: textFormFillColor,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: borderAndDividerColor,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: borderAndDividerColor,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: accentColor,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (_isSignUp && (v == null || v.trim().length < 2)) {
                                        return 'Business name must be at least 2 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'BUSINESS TYPE',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: labelColor,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    initialValue: _businessType,
                                    dropdownColor: dropdownColor,
                                    style: TextStyle(color: textColor),
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.business_center_outlined,
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.4)
                                            : const Color(0xFF64748B),
                                        size: 20,
                                      ),
                                      filled: true,
                                      fillColor: textFormFillColor,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: borderAndDividerColor,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: borderAndDividerColor,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: accentColor,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    items: [
                                      DropdownMenuItem(value: 'retail', child: Text(context.l10n.businessTypeRetail)),
                                      DropdownMenuItem(value: 'food_service', child: Text(context.l10n.businessTypeFoodService)),
                                      DropdownMenuItem(value: 'auto_parts', child: Text(context.l10n.businessTypeAutoParts)),
                                      DropdownMenuItem(value: 'hardware', child: Text(context.l10n.businessTypeHardware)),
                                      DropdownMenuItem(value: 'marketplace', child: Text(context.l10n.businessTypeMarketplace)),
                                      DropdownMenuItem(value: 'general', child: Text(context.l10n.businessTypeGeneral)),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _businessType = val;
                                        });
                                      }
                                    },
                                  ),
                                ],
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
                                      foregroundColor: isDark ? backgroundColor : Colors.white,
                                      disabledBackgroundColor:
                                          accentColor.withValues(alpha: 0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: state.isLoading
                                        ? SizedBox(
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
