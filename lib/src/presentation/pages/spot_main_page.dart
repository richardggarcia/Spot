import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/crypto.dart';
import '../bloc/alerts/alerts_bloc.dart';
import '../bloc/alerts/alerts_event.dart';
import '../bloc/alerts/alerts_state.dart';
import '../bloc/crypto/crypto_bloc.dart';
import '../bloc/crypto/crypto_event.dart';
import '../bloc/crypto/crypto_state.dart';
import '../managers/card_position_manager.dart';

import '../widgets/alerts_widget.dart';
import '../widgets/crypto_card_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/premium_app_bar.dart';
import 'crypto_management_page.dart';
import 'historical_view_page.dart';
import 'notification_settings_page.dart';

/// Main spot trading page with premium UI
class SpotMainPage extends StatelessWidget {
  const SpotMainPage({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PremiumAppBar(
          title: 'Buy The Dip',
          additionalActions: [
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Gestionar Criptomonedas',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const CryptoManagementPage(),
                  ),
                );
              },
            ),
            // Solo mostrar configuración de notificaciones en móvil
            if (!kIsWeb)
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Configuración de Notificaciones',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const NotificationSettingsPage(),
                    ),
                  );
                },
              ),
          ],
          bottom: const PremiumTabBar(
            tabs: [
              Tab(text: 'Mercado', icon: Icon(Icons.trending_up)),
              Tab(text: 'Alertas', icon: Icon(Icons.notifications_active)),
              Tab(text: 'Oportunidades', icon: Icon(Icons.star)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_MarketTab(), _AlertsTab(), _OpportunitiesTab()],
        ),
      ),
    );
}

/// Tab de mercado, ahora con estado para manejar el ciclo de vida del WebSocket.
class _MarketTab extends StatefulWidget {
  const _MarketTab();

  @override
  State<_MarketTab> createState() => _MarketTabState();
}

class _MarketTabState extends State<_MarketTab> {
  List<String> _orderedSymbols = [];

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  @override
  void dispose() {
    // Detenemos las actualizaciones en tiempo real al salir de la pantalla.
    if (mounted) {
      try {
        context.read<CryptoBloc>().add(const StopRealtimeUpdates());
      } catch (e) {
        // Ignorar errores si el context ya no está disponible
      }
    }
    super.dispose();
  }

  Future<void> _loadOrder() async {
    final manager = CardPositionManager();
    final order = await manager.getCardOrder();
    if (order.isNotEmpty) {
      setState(() {
        _orderedSymbols = order;
      });
    }
  }

  Future<void> _saveOrder(List<String> symbols) async {
    final manager = CardPositionManager();
    await manager.saveCardOrder(symbols);
  }

  List<Crypto> _getOrderedList(List<Crypto> cryptos) {
    if (_orderedSymbols.isEmpty) return cryptos;

    final cryptoMap = {for (final c in cryptos) c.symbol: c};
    final ordered = <Crypto>[];

    // Agregar en el orden guardado
    for (final symbol in _orderedSymbols) {
      if (cryptoMap.containsKey(symbol)) {
        ordered.add(cryptoMap[symbol]!);
        cryptoMap.remove(symbol);
      }
    }

    // Agregar nuevos que no están en el orden guardado
    ordered.addAll(cryptoMap.values);

    return ordered;
  }

  @override
  Widget build(BuildContext context) => BlocListener<CryptoBloc, CryptoState>(
      listener: (context, state) {
        // Una vez que tenemos la lista de criptos, iniciamos el WebSocket.
        if (state is CryptoWithMetricsLoaded) {
          final symbols = state.cryptos.map((c) => c.symbol).toList();
          context.read<CryptoBloc>().add(StartRealtimeUpdates(symbols));
        }
      },
      // Escuchamos solo la primera vez que se carga.
      listenWhen: (previous, current) =>
          previous is! CryptoWithMetricsLoaded && current is CryptoWithMetricsLoaded,
      child: BlocBuilder<CryptoBloc, CryptoState>(
        builder: (context, state) {
          if (state is CryptoLoading || state is CryptoInitial) {
            return const LoadingWidget(message: 'Cargando datos del mercado...');
          } else if (state is CryptoError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<CryptoBloc>().add(
                const GetAllCryptosWithMetrics(),
              ),
            );
          } else if (state is CryptoWithMetricsLoaded) {
            final orderedCryptos = _getOrderedList(state.cryptos.cast<Crypto>());

            return ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: orderedCryptos.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = orderedCryptos.removeAt(oldIndex);
                  orderedCryptos.insert(newIndex, item);
                  _orderedSymbols = orderedCryptos.map((c) => c.symbol).toList();
                  _saveOrder(_orderedSymbols);
                });
              },
              itemBuilder: (context, index) {
                final crypto = orderedCryptos[index];
                final metrics = state.metrics[crypto.symbol];

                return Padding(
                  key: ValueKey('crypto_${crypto.symbol}'),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CryptoCardWidget(
                    crypto: crypto,
                    metrics: metrics,
                    onTap: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoricalViewPage(
                            symbol: crypto.symbol,
                            cryptoName: crypto.name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (state is CryptoLoaded || state is CryptoRefreshing) {
            // Fallback para estados más antiguos
            final cryptos = state is CryptoLoaded
                ? state.cryptos
                : (state as CryptoRefreshing).cryptos;

            final orderedCryptos = _getOrderedList(cryptos.cast<Crypto>());

            return ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: orderedCryptos.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = orderedCryptos.removeAt(oldIndex);
                  orderedCryptos.insert(newIndex, item);
                  _orderedSymbols = orderedCryptos.map((c) => c.symbol).toList();
                  _saveOrder(_orderedSymbols);
                });
              },
              itemBuilder: (context, index) {
                final crypto = orderedCryptos[index];

                return Padding(
                  key: ValueKey('crypto_${crypto.symbol}'),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CryptoCardWidget(
                    crypto: crypto,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => HistoricalViewPage(
                            symbol: crypto.symbol,
                            cryptoName: crypto.name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
}

/// Tab de alertas
class _AlertsTab extends StatelessWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context) => BlocBuilder<AlertsBloc, AlertsState>(
      builder: (context, state) {
        if (state is AlertsLoading || state is AlertsInitial) {
          return const LoadingWidget(message: 'Buscando alertas activas...');
        } else if (state is AlertsError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: () => context.read<AlertsBloc>().add(const GetAllAlerts()),
          );
        } else if (state is NoAlerts) {
          return const _NoAlertsWidget();
        } else if (state is AlertsLoaded || state is AlertsRefreshing) {
          final alerts = state is AlertsLoaded
              ? state.alerts
              : (state as AlertsRefreshing).alerts;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AlertsBloc>().add(const RefreshAlerts());
            },
            child: AlertsWidget(
              alerts: alerts,
              isRefreshing: state is AlertsRefreshing,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
}

/// Tab de oportunidades
class _OpportunitiesTab extends StatelessWidget {
  const _OpportunitiesTab();

  @override
  Widget build(BuildContext context) => BlocBuilder<AlertsBloc, AlertsState>(
      builder: (context, state) {
        if (state is AlertsLoading || state is AlertsInitial) {
          return const LoadingWidget(message: 'Analizando oportunidades...');
        } else if (state is AlertsError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: () =>
                context.read<AlertsBloc>().add(const GetTopOpportunities()),
          );
        } else if (state is NoAlerts) {
          return const _NoOpportunitiesWidget();
        } else if (state is AlertsLoaded || state is AlertsRefreshing) {
          final opportunities = state is AlertsLoaded
              ? state.topOpportunities
              : (state as AlertsRefreshing).topOpportunities;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AlertsBloc>().add(const GetTopOpportunities());
            },
            child: opportunities.isEmpty
                ? const _NoOpportunitiesWidget()
                : AlertsWidget(
                    alerts: opportunities,
                    isRefreshing: state is AlertsRefreshing,
                    showOpportunities: true,
                  ),
          );
        }
        return const SizedBox.shrink();
      },
    );
}

/// Widget para cuando no hay alertas
class _NoAlertsWidget extends StatelessWidget {
  const _NoAlertsWidget();

  @override
  Widget build(BuildContext context) => const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Sin alertas activas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'No hay caídas significativas en el mercado:\n• Esperando caída ≥ -3%',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
}

/// Widget para cuando no hay oportunidades
class _NoOpportunitiesWidget extends StatelessWidget {
  const _NoOpportunitiesWidget();

  @override
  Widget build(BuildContext context) => const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Sin oportunidades de alta calidad',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'No se encontraron oportunidades de compra\nque cumplan con los criterios estrictos',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
}
