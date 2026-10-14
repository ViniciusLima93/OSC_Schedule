import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/app_user.dart';
import '../models/appointment.dart';
import '../models/social_action.dart';

/// Endereço da API (backend_projetoOSCSchedule). Pode ser trocado com
/// `flutter run --dart-define=API_URL=http://192.168.0.10:3000`.
/// No emulador Android, `localhost` do computador é `10.0.2.2`.
String get defaultApiUrl {
  const fromEnv = String.fromEnvironment('API_URL');
  if (fromEnv.isNotEmpty) return fromEnv;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? defaultApiUrl,
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  // Usuários
  Future<List<AppUser>> fetchUsers() async {
    final data = await _send('GET', '/users') as List;
    return data.map((u) => AppUser.fromJson(u)).toList();
  }

  // Ações
  Future<List<SocialAction>> fetchActions() async {
    final data = await _send('GET', '/actions') as List;
    return data.map((a) => SocialAction.fromJson(a)).toList();
  }

  Future<void> createAction({
    required int organizerId,
    required String title,
    required String description,
    required String location,
    required DateTime dateTime,
    required int vacancies,
    required List<String> docs,
  }) async {
    await _send('POST', '/actions', {
      'organizerId': organizerId,
      'title': title,
      'description': description,
      'location': location,
      'eventDate': dateTime.toUtc().toIso8601String(),
      'vacancies': vacancies,
      'docs': docs,
    });
  }

  Future<void> updateVacancies(int actionId, int vacancies) async {
    await _send('PATCH', '/actions/$actionId', {'vacancies': vacancies});
  }

  // Inscrições
  Future<List<Appointment>> fetchRegistrations({int? userId, int? actionId}) async {
    final query = {
      if (userId != null) 'userId': '$userId',
      if (actionId != null) 'actionId': '$actionId',
    };
    final data = await _send('GET', '/registrations', null, query) as List;
    return data.map((r) => Appointment.fromJson(r)).toList();
  }

  Future<void> createRegistration({required int userId, required int actionId}) async {
    await _send('POST', '/registrations', {'userId': userId, 'actionId': actionId});
  }

  Future<void> cancelRegistration(int id) async {
    await _send('PATCH', '/registrations/$id/cancel');
  }

  Future<dynamic> _send(
    String method,
    String path, [
    Map<String, dynamic>? body,
    Map<String, String>? query,
  ]) async {
    final uri = Uri.parse('$baseUrl$path')
        .replace(queryParameters: (query == null || query.isEmpty) ? null : query);
    final request = http.Request(method, uri)
      ..headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 15)),
      );
    } catch (_) {
      throw ApiException('Não foi possível conectar ao servidor ($baseUrl).');
    }

    final decoded = response.body.isEmpty
        ? null
        : jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode >= 400) {
      throw ApiException(
        _errorMessage(decoded) ?? 'Erro ${response.statusCode} ao acessar o servidor.',
        statusCode: response.statusCode,
      );
    }
    return decoded;
  }

  // O NestJS devolve { message: string | string[] } nos erros
  String? _errorMessage(dynamic decoded) {
    if (decoded is! Map) return null;
    final message = decoded['message'];
    if (message is List) return message.join('\n');
    return message?.toString();
  }
}
