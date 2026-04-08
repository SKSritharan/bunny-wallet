import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bunny_wallet/core/theme/app_theme.dart';
import 'package:bunny_wallet/core/theme/theme_provider.dart';
import 'package:bunny_wallet/core/router/app_router.dart';
import 'package:bunny_wallet/data/database/database_helper.dart';
import 'package:bunny_wallet/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  await DatabaseHelper.instance.database;
  await NotificationService.instance.init();

  runApp(const ProviderScope(child: BunnyWalletApp()));
}

class BunnyWalletApp extends ConsumerWidget {
  const BunnyWalletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Bunny Wallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
