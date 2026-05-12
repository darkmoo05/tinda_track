import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tinda_track/l10n/app_localizations.dart';
import 'core/app_theme.dart';
import 'core/data/app_database.dart';
import 'core/data/sync_service.dart';
import 'core/l10n_extension.dart';
import 'core/locale_provider.dart';
import 'features/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.init();
  await LocaleProvider.instance.load();
  runApp(const TindaTrackApp());
}

class TindaTrackApp extends StatelessWidget {
  const TindaTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleProvider.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'PocketLedger',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          locale: LocaleProvider.instance.locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            // Falls back to English for locales not covered by the global
            // material/cupertino/widgets delegates (e.g. Cebuano).
            const _FallbackMaterialLocalizationsDelegate(),
            const _FallbackCupertinoLocalizationsDelegate(),
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('fil'), Locale('ceb')],
          home: const StartupSyncGate(),
        );
      },
    ); //yes von
  }
}

/// MaterialLocalizations delegate that falls back to English for any locale
/// not supported by [GlobalMaterialLocalizations] (e.g. Cebuano).
class _FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialLocalizationsDelegate();

  static final _delegate = GlobalMaterialLocalizations.delegate;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      _delegate.isSupported(locale)
      ? _delegate.load(locale)
      : _delegate.load(const Locale('en'));

  @override
  bool shouldReload(_FallbackMaterialLocalizationsDelegate old) => false;
}

/// CupertinoLocalizations delegate with the same English fallback.
class _FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _FallbackCupertinoLocalizationsDelegate();

  static final _delegate = GlobalCupertinoLocalizations.delegate;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      _delegate.isSupported(locale)
      ? _delegate.load(locale)
      : _delegate.load(const Locale('en'));

  @override
  bool shouldReload(_FallbackCupertinoLocalizationsDelegate old) => false;
}

class StartupSyncGate extends StatefulWidget {
  const StartupSyncGate({super.key});

  @override
  State<StartupSyncGate> createState() => _StartupSyncGateState();
}

class _StartupSyncGateState extends State<StartupSyncGate> {
  late final Future<SyncRunResult> _startupSync;

  @override
  void initState() {
    super.initState();
    _startupSync = _runStartupSync();
  }

  Future<SyncRunResult> _runStartupSync() async {
    try {
      return await SyncService.instance.syncAll();
    } catch (_) {
      return const SyncRunResult(pushed: 0, pulled: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SyncRunResult>(
      future: _startupSync,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StartupLoadingScreen();
        }

        return const MainShell();
      },
    );
  }
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryContainer],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Icon centered in expanded space
              Expanded(
                child: Center(
                  child: Image.asset(
                    'tinda_tract_icon.png',
                    width: 140,
                    height: 140,
                  ),
                ),
              ),
              // Spinner + label pinned to bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      context.l10n.syncingData,
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
