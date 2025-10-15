import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../domain/ports/streaming_data_port.dart';
import '../../core/utils/logger.dart';

/// Implementación del [StreamingDataPort] para el servicio de WebSockets de Binance.
class BinanceStreamingService implements StreamingDataPort {
  static const String _baseUrl = 'wss://stream.binance.com:9443/stream';

  WebSocketChannel? _channel;
  StreamController<RealtimePriceTick>? _streamController;

  @override
  Stream<RealtimePriceTick> connect(List<String> symbols) {
    // Si ya hay una conexión, la cerramos para empezar una nueva.
    disconnect();

    // Creamos un nuevo StreamController para controlar el flujo de datos.
    _streamController = StreamController<RealtimePriceTick>.broadcast();

    // Convertimos los símbolos de la app (ej: 'BTC') al formato de Binance (ej: 'btcusdt@trade').
    final streams = symbols
        .map((s) => '${s.toLowerCase()}usdt@trade')
        .join('/');
    final url = '$_baseUrl?streams=$streams';

    AppLogger.info('Connecting to Binance WebSocket: $url');

    try {
      // Creamos el canal de WebSocket.
      _channel = WebSocketChannel.connect(Uri.parse(url));

      // Escuchamos los mensajes que llegan del servidor.
      _channel!.stream.listen(
        (message) {
          final Map<String, dynamic> data = json.decode(message);

          // Verificamos que el mensaje tenga el formato esperado.
          if (data.containsKey('stream') && data.containsKey('data')) {
            final Map<String, dynamic> tradeData = data['data'];
            
            // Extraemos el símbolo y el precio.
            final String symbol = tradeData['s'].toString().replaceAll('USDT', '');
            final double price = double.parse(tradeData['p']);

            // Creamos el objeto RealtimePriceTick.
            final tick = RealtimePriceTick(
              symbol: symbol,
              price: price,
              timestamp: DateTime.fromMillisecondsSinceEpoch(tradeData['T'], isUtc: true),
            );

            // Añadimos el tick a nuestro stream para que el BLoC lo reciba.
            _streamController?.add(tick);
          }
        },
        onError: (error) {
          AppLogger.error('WebSocket Error', error);
          _streamController?.addError(error);
        },
        onDone: () {
          AppLogger.info('WebSocket connection closed.');
          _streamController?.close();
        },
      );
    } catch (e) {
      AppLogger.error('Failed to connect to WebSocket', e);
      _streamController?.addError(e);
      disconnect();
    }

    return _streamController!.stream;
  }

  @override
  void disconnect() {
    AppLogger.info('Disconnecting from WebSocket...');
    // Cerramos la conexión y el stream controller.
    _channel?.sink.close();
    _streamController?.close();
    _channel = null;
    _streamController = null;
  }
}
