import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/theme_provider.dart';
import '../../core/l10n/l10n_extension.dart';
import '../../core/l10n/locale_provider.dart';

class DrawerItem {
  const DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class AppSwitcherConfig {
  const AppSwitcherConfig({
    required this.otherAppIcon,
    required this.otherAppColor,
    required this.otherAppLabel,
    required this.onSwitch,
  });

  final IconData otherAppIcon;
  final Color otherAppColor;
  final String otherAppLabel;
  final VoidCallback onSwitch;
}

class AppDrawerConfig {
  const AppDrawerConfig({
    required this.appIcon,
    required this.appColor,
    required this.appTitle,
    required this.appSubtitle,
    this.navItems = const [],
    this.settingsItems = const [],
    this.switcherConfig,
  });

  final IconData appIcon;
  final Color appColor;
  final String appTitle;
  final String appSubtitle;
  final List<DrawerItem> navItems;
  final List<DrawerItem> settingsItems;
  final AppSwitcherConfig? switcherConfig;
}

class AppSideDrawer extends StatelessWidget {
  const AppSideDrawer({super.key, required this.config});

  final AppDrawerConfig config;

  void _executeItem(BuildContext context, VoidCallback onTap) {
    Navigator.of(context).pop();
    onTap();
  }

  void _showLanguagePicker(BuildContext context) {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF161D30)
          : AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _LanguagePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : null,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF161D30)
                    : AppColors.surfaceContainerLow,
                border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.08)) : null,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: config.appColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(config.appIcon, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.appTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        config.appSubtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── Quick Navigation ──
            if (config.navItems.isNotEmpty) ...[
              for (final item in config.navItems)
                _DrawerItem(
                  icon: item.icon,
                  label: item.label,
                  onTap: () => _executeItem(context, item.onTap),
                ),
              Divider(
                indent: 16,
                endIndent: 16,
                height: 24,
                color: isDark ? Colors.white.withValues(alpha: 0.08) : null,
              ),
            ],
            // ── Settings ──
            for (final item in config.settingsItems)
              _DrawerItem(
                icon: item.icon,
                label: item.label,
                onTap: () => _executeItem(context, item.onTap),
              ),
            // ── Dark Theme Mode Switch ──
            ListenableBuilder(
              listenable: ThemeProvider.instance,
              builder: (context, _) {
                final isDark = ThemeProvider.instance.isDarkMode;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SwitchListTile(
                    secondary: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                    ),
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                      ),
                    ),
                    value: isDark,
                    activeTrackColor: const Color(0xFF60A5FA).withValues(alpha: 0.4),
                    activeThumbColor: const Color(0xFF60A5FA),
                    onChanged: (val) {
                      ThemeProvider.instance.toggleTheme();
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                );
              },
            ),
            // ── App Switcher ──
            if (config.switcherConfig != null)
              ..._buildSwitcherStrip(context, config.switcherConfig!),
            // ── Language (always present) ──
            _DrawerItem(
              icon: Icons.language_rounded,
              label: l10n.changeLanguage,
              onTap: () => _showLanguagePicker(context),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSwitcherStrip(BuildContext context, AppSwitcherConfig sw) {
    return [
      const Divider(indent: 16, endIndent: 16, height: 8),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
        child: Text(
          'Switch App',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: _AppChip(
                icon: config.appIcon,
                label: config.appTitle,
                color: config.appColor,
                isActive: true,
                onTap: null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _AppChip(
                icon: sw.otherAppIcon,
                label: sw.otherAppLabel,
                color: sw.otherAppColor,
                isActive: false,
                onTap: () {
                  Navigator.of(context).pop();
                  sw.onSwitch();
                },
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

class _LanguagePickerSheet extends StatefulWidget {
  const _LanguagePickerSheet();

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  late Locale _selected;

  @override
  void initState() {
    super.initState();
    _selected = LocaleProvider.instance.locale;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locales = LocaleProvider.supportedLocales;

    final languageLabels = {
      'en': l10n.languageEnglish,
      'fil': l10n.languageFilipino,
      'ceb': l10n.languageCebuano,
    };

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.15) : AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.language_rounded,
                color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.selectLanguage,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...locales.map((entry) {
            final isSelected =
                _selected.languageCode == entry.locale.languageCode;
            final label =
                languageLabels[entry.locale.languageCode] ?? entry.label;

            return _LanguageOption(
              label: label,
              nativeLabel: entry.nativeLabel,
              isSelected: isSelected,
              onTap: () {
                setState(() => _selected = entry.locale);
                LocaleProvider.instance.setLocale(entry.locale);
                Future.delayed(const Duration(milliseconds: 180), () {
                  if (context.mounted) Navigator.of(context).pop();
                });
              },
            );
          }),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.nativeLabel,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String nativeLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2563EB).withValues(alpha: 0.20)
                  : AppColors.primary.withValues(alpha: 0.10))
              : (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : AppColors.surfaceContainerLow),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF60A5FA)
                    : AppColors.primary)
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.outlineVariant.withValues(alpha: 0.35)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF60A5FA)
                              : AppColors.primary)
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (label != nativeLabel)
                    Text(
                      nativeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF60A5FA)
                    : AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
    );
  }
}

class _AppChip extends StatelessWidget {
  const _AppChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? color
              : (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : AppColors.surfaceContainerLow),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? color
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.outlineVariant),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? Colors.white
                  : (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF94A3B8)
                      : AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF94A3B8)
                        : AppColors.onSurfaceVariant),
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 2),
              Container(
                width: 16,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
