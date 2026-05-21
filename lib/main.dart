import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinda_track/l10n/app_localizations.dart';
import 'core/app_theme.dart';
import 'core/database/app_database.dart';
import 'core/sync/sync_service.dart';
import 'core/l10n/l10n_extension.dart';
import 'core/l10n/locale_provider.dart';
import 'pocket_ledger/app/main_shell.dart';
import 'tinda_tracker/app/tinda_tracker_shell.dart';

enum AppMode { pocketLedger, tindaTracker }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.init();
  await LocaleProvider.instance.load();
  runApp(const ProviderScope(child: TindaTrackApp()));
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
  @override
  void initState() {
    super.initState();
    // Sync runs in the background — never block the UI on it.
    // The app reads from local SQLite and is fully usable offline.
    // Any data pulled from the server will refresh providers via
    // the periodic sync timer in AppModeHost.
    SyncService.instance.syncAll().ignore();
  }

  @override
  Widget build(BuildContext context) {
    return const AppModeHost();
  }
}

class AppModeHost extends StatefulWidget {
  const AppModeHost({super.key});

  @override
  State<AppModeHost> createState() => _AppModeHostState();
}

class _AppModeHostState extends State<AppModeHost> {
  AppMode _mode = AppMode.pocketLedger;

  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;
  Timer? _syncDebounce;
  Timer? _periodicSync;
  // Track previous state so we only sync on offline → online transitions.
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
    // Sync every 60 s while the app is open and online.
    _periodicSync = Timer.periodic(const Duration(seconds: 60), (_) {
      if (!_wasOffline) SyncService.instance.syncAll();
    });
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final isOffline = results.every((r) => r == ConnectivityResult.none);
    if (_wasOffline && !isOffline) {
      // Came back online — debounce 3 s then sync.
      _syncDebounce?.cancel();
      _syncDebounce = Timer(const Duration(seconds: 3), () {
        SyncService.instance.syncAll();
      });
    }
    _wasOffline = isOffline;
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    _syncDebounce?.cancel();
    _periodicSync?.cancel();
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
