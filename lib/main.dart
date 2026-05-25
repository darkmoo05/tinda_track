import 'dart:async';

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
import 'shared/widgets/app_loading_modal.dart';
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
      await SyncService.instance.syncAll();
    } catch (_) {
      // Startup should continue even if first sync attempt fails.
    } finally {
      if (!mounted) {
        return;
      }
      loading.close();
      setState(() {
        _ready = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: SizedBox.expand());
    }
    return const AppModeHost();
  }
}

class AppModeHost extends StatefulWidget {
  const AppModeHost({super.key});

  @override
  State<AppModeHost> createState() => _AppModeHostState();
}

class _AppModeHostState extends State<AppModeHost> with WidgetsBindingObserver {
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
      SyncService.instance.syncAll().whenComplete(() {
        _exitSyncInFlight = false;
      });
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _exitSyncInFlight = false;
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
