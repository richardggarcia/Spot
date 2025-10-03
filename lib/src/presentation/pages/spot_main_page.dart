import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/crypto/crypto_bloc.dart';
import '../bloc/crypto/crypto_event.dart';
import '../bloc/crypto/crypto_state.dart';
import '../bloc/alerts/alerts_bloc.dart';
import '../bloc/alerts/alerts_event.dart';
import '../bloc/alerts/alerts_state.dart';
import '../widgets/crypto_card_widget.dart';
import '../widgets/alerts_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'historical_view_page.dart';

/// Página principal de trading spot
class SpotMainPage extends StatelessWidget {
  const SpotMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Spot Trading'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Mercado', icon: Icon(Icons.trending_up)),
              Tab(text: 'Alertas', icon: Icon(Icons.notifications_active)),
              Tab(text: 'Oportunidades', icon: Icon(Icons.star)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _refreshAll(context),
            ),
          ],
        ),
        body: const TabBarView(
          children: [_MarketTab(), _AlertsTab(), _OpportunitiesTab()],
        ),
      ),
    );
  }

  void _refreshAll(BuildContext context) {
    context.read<CryptoBloc>().add(const RefreshCryptos());
    context.read<AlertsBloc>().add(const RefreshAlerts());
  }
}

/// Tab de mercado
class _MarketTab extends StatelessWidget {
  const _MarketTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CryptoBloc, CryptoState>(
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
          return RefreshIndicator(
            onRefresh: () async {
              context.read<CryptoBloc>().add(const GetAllCryptosWithMetrics());
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.cryptos.length,
              itemBuilder: (context, index) {
                final crypto = state.cryptos[index];
                final metrics = state.metrics[crypto.symbol];

                return CryptoCardWidget(
                  crypto: crypto,
                  metrics: metrics,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoricalViewPage(
                          symbol: crypto.symbol,
                          cryptoName: crypto.name,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        } else if (state is CryptoLoaded || state is CryptoRefreshing) {
          // Mantener compatibilidad con estado anterior
          final cryptos = state is CryptoLoaded
              ? state.cryptos
              : (state as CryptoRefreshing).cryptos;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CryptoBloc>().add(const GetAllCryptosWithMetrics());
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: cryptos.length,
              itemBuilder: (context, index) {
                final crypto = cryptos[index];

                return CryptoCardWidget(
                  crypto: crypto,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoricalViewPage(
                          symbol: crypto.symbol,
                          cryptoName: crypto.name,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Tab de alertas
class _AlertsTab extends StatelessWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertsBloc, AlertsState>(
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
}

/// Tab de oportunidades
class _OpportunitiesTab extends StatelessWidget {
  const _OpportunitiesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertsBloc, AlertsState>(
      builder: (context, state) {
        if (state is AlertsLoading || state is AlertsInitial) {
          return const LoadingWidget(message: 'Analizando oportunidades...');
        } else if (state is AlertsError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: () =>
                context.read<AlertsBloc>().add(GetTopOpportunities()),
          );
        } else if (state is NoAlerts) {
          return const _NoOpportunitiesWidget();
        } else if (state is AlertsLoaded || state is AlertsRefreshing) {
          final opportunities = state is AlertsLoaded
              ? state.topOpportunities
              : (state as AlertsRefreshing).topOpportunities;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AlertsBloc>().add(GetTopOpportunities());
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
}

/// Widget para cuando no hay alertas
class _NoAlertsWidget extends StatelessWidget {
  const _NoAlertsWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
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
            'No hay oportunidades que cumplan con los criterios actuales:\n• Caída ≤ -5%\n• Rebote ≥ +3%',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Widget para cuando no hay oportunidades
class _NoOpportunitiesWidget extends StatelessWidget {
  const _NoOpportunitiesWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
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
}
