import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

typedef OutageSimulationCheck = Future<bool> Function();

const simulatedOutageStatusCode = HttpStatus.serviceUnavailable;
const simulatedOutageMessage = 'Servicio no disponible (simulado)';

class SimulatedOutageHttpClient extends http.BaseClient {
  SimulatedOutageHttpClient({
    required this._isOutageSimulated,
    required this._network,
  });

  final OutageSimulationCheck _isOutageSimulated;
  final http.Client _network;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (await _isOutageSimulated()) {
      return _simulatedOutageAnswerTo(request);
    }
    return _network.send(request);
  }

  @override
  void close() => _network.close();

  static http.StreamedResponse _simulatedOutageAnswerTo(
    http.BaseRequest request,
  ) {
    final body = utf8.encode(simulatedOutageMessage);
    return http.StreamedResponse(
      Stream.value(body),
      simulatedOutageStatusCode,
      contentLength: body.length,
      request: request,
      headers: {'content-type': 'text/plain; charset=utf-8'},
      reasonPhrase: 'Service Unavailable',
    );
  }
}
