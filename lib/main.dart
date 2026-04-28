import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'core/data/app_database.dart';
import 'core/network/api_client.dart';
import 'core/sync/sync_service.dart';
import 'features/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.init();
  ApiClient.instance.init();
  await SyncService.instance.init();
  await SyncService.instance.syncOnLaunch();
  runApp(const TindaTrackApp());
}

class TindaTrackApp extends StatelessWidget {
  const TindaTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TindaTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShell(),
    ); //yes von
  }
}
