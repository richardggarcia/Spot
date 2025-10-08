import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/core/di/service_locator.dart';
import 'src/presentation/bloc/crypto/crypto_bloc.dart';
import 'src/presentation/bloc/crypto/crypto_event.dart';
import 'src/presentation/bloc/alerts/alerts_bloc.dart';
import 'src/presentation/bloc/alerts/alerts_event.dart';
import 'src/presentation/pages/spot_main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar inyección de dependencias
  await ServiceLocator.setup();

  runApp(const SpotTradingApp());
}

class SpotTradingApp extends StatelessWidget {
  const SpotTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ServiceLocator.get<CryptoBloc>()
            ..add(const GetAllCryptosWithMetrics()),
        ),
        BlocProvider(
          create: (context) =>
              AlertsBloc(getAlertsUseCase: ServiceLocator.get())
                ..add(const GetAllAlerts()),
        ),
      ],
      child: MaterialApp(
        title: 'spot',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
          Locale('es', ''), // Spanish, no country code
        ],
        home: const SpotMainPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
