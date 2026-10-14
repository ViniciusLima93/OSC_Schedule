import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:osc_schedule/models/app_user.dart';
import 'package:osc_schedule/models/appointment.dart';
import 'package:osc_schedule/services/api_client.dart';

// Respostas reais do backend (GET /actions, /registrations, /users)
const _actionsJson = '''
[{"createdAt":"2026-09-26 14:42:25.264089+00","description":"Orientação para currículo.","docs":["RG","CPF"],"eventDate":"2026-10-15 17:00:00+00","id":2,"location":"Sede da OSC - Sala 2","organizerId":1,"title":"Oficina de currículo","updatedAt":"2026-09-26 14:42:25.264089+00","vacancies":3,"organizer":{"id":1,"name":"Ana Souza"},"registered":3,"availableVacancies":0}]
''';

const _registrationsJson = '''
[{"actionId":1,"createdAt":"2026-09-26 14:42:25.264089+00","id":3,"status":"cancelada","updatedAt":"2026-09-26 14:42:25.264089+00","userId":5,"user":{"id":5,"name":"Elisa Rocha","email":"elisa@mail.com"},"action":{"id":1,"title":"Mutirão de limpeza da praça","eventDate":"2026-10-10 11:00:00+00","location":"Praça Central"}}]
''';

const _usersJson = '''
[{"id":1,"name":"Ana Souza","email":"ana@osc.org","role":"Organizador","createdAt":"2026-09-26 14:42:25.264089+00","updatedAt":"2026-09-26 14:42:25.264089+00"}]
''';

void main() {
  late List<http.Request> requests;

  ApiClient clientReturning(int status, String body) {
    requests = [];
    return ApiClient(
      baseUrl: 'http://api',
      client: MockClient((request) async {
        requests.add(request);
        return http.Response.bytes(utf8.encode(body), status,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }),
    );
  }

  test('converte GET /actions em SocialAction', () async {
    final actions = await clientReturning(200, _actionsJson).fetchActions();

    final action = actions.single;
    expect(action.id, 2);
    expect(action.organizerName, 'Ana Souza');
    expect(action.requiredDocuments, ['RG', 'CPF']);
    expect(action.dateTime.toUtc(), DateTime.utc(2026, 10, 15, 17));
    expect(action.isFull, isTrue);
  });

  test('converte GET /registrations em Appointment', () async {
    final api = clientReturning(200, _registrationsJson);
    final appointments = await api.fetchRegistrations(userId: 5);

    expect(requests.single.url.toString(), 'http://api/registrations?userId=5');
    final appointment = appointments.single;
    expect(appointment.moradorName, 'Elisa Rocha');
    expect(appointment.actionTitle, 'Mutirão de limpeza da praça');
    expect(appointment.status, AppointmentStatus.cancelled);
  });

  test('converte GET /users em AppUser', () async {
    final users = await clientReturning(200, _usersJson).fetchUsers();
    expect(users.single.role, UserRole.organizador);
  });

  test('envia a nova ação no formato do CreateActionDto', () async {
    final api = clientReturning(201, '{}');
    await api.createAction(
      organizerId: 1,
      title: 'Teste',
      description: 'Desc',
      location: 'Local',
      dateTime: DateTime.utc(2026, 11, 1, 12),
      vacancies: 5,
      docs: ['RG'],
    );

    expect(requests.single.method, 'POST');
    expect(jsonDecode(requests.single.body), {
      'organizerId': 1,
      'title': 'Teste',
      'description': 'Desc',
      'location': 'Local',
      'eventDate': '2026-11-01T12:00:00.000Z',
      'vacancies': 5,
      'docs': ['RG'],
    });
  });

  test('repassa a mensagem de erro do NestJS', () async {
    final api = clientReturning(
      409,
      '{"statusCode":409,"message":"Não há vagas disponíveis nesta ação"}',
    );
    expect(
      () => api.createRegistration(userId: 3, actionId: 2),
      throwsA(isA<ApiException>()
          .having((e) => e.message, 'message', 'Não há vagas disponíveis nesta ação')),
    );
  });
}
