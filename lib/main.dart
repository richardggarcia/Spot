import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'src/core/di/service_locator.dart';
import 'src/presentation/bloc/crypto/crypto_bloc.dart';
import 'src/presentation/bloc/crypto/crypto_event.dart';
import 'src/presentation/bloc/alerts/alerts_bloc.dart';
import 'src/presentation/bloc/alerts/alerts_event.dart';
import 'src/presentation/pages/spot_main_page.dart';
import 'src/presentation/theme/app_theme.dart';
import 'src/presentation/managers/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure dependency injection
  await ServiceLocator.setup();

  // Initialize theme manager
  final themeManager = ThemeManager();
  await themeManager.loadThemePreference();

  runApp(SpotTradingApp(themeManager: themeManager));
}

class SpotTradingApp extends StatelessWidget {
  final ThemeManager themeManager;

  const SpotTradingApp({
    super.key,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme management
        ChangeNotifierProvider.value(value: themeManager),

        // BLoC providers
        BlocProvider(
          create: (context) =>
              ServiceLocator.get<CryptoBloc>()
                ..add(const GetAllCryptosWithMetrics()),
        ),
        BlocProvider(
          create: (context) =>
              AlertsBloc(getAlertsUseCase: ServiceLocator.get())
                ..add(const GetAllAlerts()),
        ),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Buy The Dip',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeManager.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('es', ''), // Spanish
            ],
            home: const SpotMainPage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
