import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'cliente_http.dart';

Future<http.Client> crearClienteHttp() async {
  final certificado = await rootBundle.load(certificadoDeLaAutoridad);
  return clienteQueSoloConfiaEn(certificado.buffer.asUint8List());
}

/// Un cliente HTTP que solo acepta servidores con un certificado firmado por
/// la autoridad de [certificadoPem]: sin las autoridades del sistema.
http.Client clienteQueSoloConfiaEn(List<int> certificadoPem) {
  final contexto = SecurityContext(withTrustedRoots: false)
    ..setTrustedCertificatesBytes(certificadoPem);
  return IOClient(HttpClient(context: contexto));
}
