import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'router/app_router.dart';
import 'providers/expense_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/holding_provider.dart';
import 'theme/app_theme.dart';
// import 'services/ad_service.dart';
// import 'services/iap_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Uncomment when packages are installed
  // await AdService.initialize();
  // await IAPService.instance.initialize();
  runApp(const KakeiboApp());
}

class KakeiboApp extends StatelessWidget {
  const KakeiboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => HoldingProvider()),
      ],
      child: MaterialApp.router(
        title: 'Kakeibo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('tr', ''),
          Locale('es', ''),
          Locale('fr', ''),
          Locale('de', ''),
          Locale('it', ''),
          Locale('pt', ''),
          Locale('ja', ''),
          Locale('ko', ''),
          Locale('zh', ''),
        ],
      ),
    );
  }
}
