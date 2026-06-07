import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tinda_track/l10n/app_localizations.dart';
import 'core/app_theme.dart';
import 'core/theme_provider.dart';
import 'core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'core/database/daos/app_meta_dao.dart';
import 'core/database/migrations/legacy_sqflite_importer.dart';
import 'core/database/providers/auth_providers.dart';
import 'shared/screens/login_screen.dart';
import 'core/network/api_client.dart';
import 'core/sync/background_sync_manager.dart';
import 'core/sync/sync_config.dart';
import 'core/sync/sync_orchestrator.dart';
import 'core/l10n/l10n_extension.dart';
import 'core/l10n/locale_provider.dart';
import 'shared/widgets/app_loading_modal.dart';
import 'pocket_ledger/app/main_shell.dart';
import 'tinda_tracker/app/tinda_tracker_shell.dart';

enum AppMode { pocketLedger, tindaTracker }

/// Applies sticky immersive full-screen mode (hides nav bar + status bar).
/// Call this from any lifecycle point where you want to (re-)enforce immersive.
/// Android will auto-restore nav bars on swipe; calling this re-hides them.
void _enforceImmersiveMode() {
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    // immersiveSticky: nav/status bars are hidden by default.
    // A swipe from the edge reveals them transiently — they fade back
    // automatically without triggering any layout shift in Flutter.
  );
}

Future<void> main() async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN');
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      // ── Immersive mode: set as early as possible, before first frame ──────────
      _enforceImmersiveMode();

      // Initialize background sync task scheduling
      try {
        await BackgroundSyncManager.initialize();
        await BackgroundSyncManager.registerPeriodicSync();
      } catch (e, st) {
        developer.log(
          'Failed to initialize background sync manager',
          name: 'startup.background_sync',
          error: e,
          stackTrace: st,
        );
      }

      // Lock to portrait (remove if you support landscape)
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      await LocaleProvider.instance.load();
      await ThemeProvider.instance.load();

      // Build a Riverpod container up-front so we can run one-time DB migrations
      // and hydrate the API base URL before the first widget is built.
      final container = ProviderContainer();
      await _runStartupMigrations(container);

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const TindaTrackApp(),
        ),
      );
    },
  );
}

Future<void> _runStartupMigrations(ProviderContainer container) async {
  // The legacy importer runs against the legacy (pre-per-user) DB file.
  // We open it directly rather than through the family provider because at
  // startup there is no logged-in user yet.
  AppDatabase? legacyDb;
  try {
    legacyDb = AppDatabase(); // opens legacy tinda_track_drift.sqlite
    final appMeta = AppMetaDao(legacyDb);
    await LegacyImporter(legacyDb, appMeta).runIfNeeded();
  } catch (e, st) {
    // BUG-13 fix: the importer marks `failed` so it retries next launch, but
    // we MUST leave a developer-log breadcrumb — a silent `catch (_) {}`
    // made stuck migrations impossible to diagnose in the field.
    developer.log(
      'Legacy import failed during startup; will retry next launch.',
      name: 'startup.legacy_import',
      error: e,
      stackTrace: st,
    );
  } finally {
    await legacyDb?.close();
  }

  // Hydrate the live ApiClient base URL from the persisted setting (or the
  // compile-time default when unset) so the first sync request hits the
  // right host.
  try {
    final appMeta = container.read(appMetaDaoProvider);
    final stored = await appMeta.getApiBaseUrl();
    final url = (stored != null && stored.trim().isNotEmpty)
        ? stored.trim()
        : SyncConfig.defaultBaseApiUrl;
    ApiClient.instance.dio.options = ApiClient.instance.dio.options.copyWith(
      baseUrl: url,
    );
  } catch (e, st) {
    developer.log(
      'Failed to hydrate ApiClient base URL; falling back to compile-time '
      'default (${SyncConfig.defaultBaseApiUrl}).',
      name: 'startup.api_base_url',
      error: e,
      stackTrace: st,
    );
  }
}

class TindaTrackApp extends StatelessWidget {
  const TindaTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([LocaleProvider.instance, ThemeProvider.instance]),
      builder: (context, _) {
        return MaterialApp(
          title: 'PocketLedger',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeProvider.instance.themeMode,
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
          home: const AuthGate(),
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

class StartupSyncGate extends ConsumerStatefulWidget {
  const StartupSyncGate({super.key});

  @override
  ConsumerState<StartupSyncGate> createState() => _StartupSyncGateState();
}

class _StartupSyncGateState extends ConsumerState<StartupSyncGate> {
  bool _ready = false;
  bool _startupTaskStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runStartupSync());
  }

  Future<void> _runStartupSync() async {
    if (_startupTaskStarted || !mounted) {
      return;
    }
    _startupTaskStarted = true;

    final loading = showAppLoadingModal(
      context,
      message: 'Syncing startup data...',
      caption: 'Please wait while we fetch your latest records.',
    );

    try {
      await ref.read(syncOrchestratorProvider).runOnce();
    } catch (_) {
      // Startup should continue even if first sync attempt fails.
    } finally {
      loading.close();
    }
    if (!mounted) return;
    setState(() {
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: SizedBox.expand());
    }
    return const AppModeHost();
  }
}

class AppModeHost extends ConsumerStatefulWidget {
  const AppModeHost({super.key});

  @override
  ConsumerState<AppModeHost> createState() => _AppModeHostState();
}

class _AppModeHostState extends ConsumerState<AppModeHost>
    with WidgetsBindingObserver {
  AppMode _mode = AppMode.pocketLedger;
  bool _exitSyncInFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Run one best-effort sync when the app is backgrounded/exiting.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (_exitSyncInFlight) {
        return;
      }
      _exitSyncInFlight = true;
      ref.read(syncOrchestratorProvider).runOnce().whenComplete(() {
        _exitSyncInFlight = false;
      });
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _exitSyncInFlight = false;
      // ── Re-enforce immersive mode when app comes back to foreground ───────
      // Android resets system UI flags when the app is paused. This call
      // restores sticky immersive mode reliably on every resume event,
      // including after the user navigates home and returns.
      _enforceImmersiveMode();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _switchTo(AppMode mode) => setState(() => _mode = mode);

  @override
  Widget build(BuildContext context) {
    return switch (_mode) {
      AppMode.pocketLedger => MainShell(
        onSwitchApp: () => _switchTo(AppMode.tindaTracker),
      ),
      AppMode.tindaTracker => TindaTrackerShell(
        onSwitchApp: () => _switchTo(AppMode.pocketLedger),
      ),
    };
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return switch (authState.status) {
      AuthStatus.initial || AuthStatus.loading => const Scaffold(
          backgroundColor: AppColors.loginBackground,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.loginNeonCyan),
          ),
        ),
      AuthStatus.authenticated => const StartupSyncGate(),
      AuthStatus.unauthenticated || AuthStatus.error => const LoginScreen(),
    };
  }
}
