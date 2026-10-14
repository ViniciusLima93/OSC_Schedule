import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/appointment.dart';
import '../models/social_action.dart';
import '../services/api_client.dart';

class AppState extends ChangeNotifier {
  AppState({ApiClient? api}) : api = api ?? ApiClient();

  final ApiClient api;

  List<AppUser> _users = [];
  AppUser? _currentUser;
  List<SocialAction> _actions = [];
  List<Appointment> _appointments = [];
  final List<AppNotification> _notifications = [];

  bool _loading = false;
  String? _error;

  int _idCounter = 0;
  String _nextId(String prefix) => '$prefix-${_idCounter++}';

  List<AppUser> get users => List.unmodifiable(_users);
  AppUser? get currentUser => _currentUser;
  bool get loading => _loading;
  String? get error => _error;

  List<SocialAction> get actions => List.unmodifiable(_actions);

  /// Ações criadas pelo organizador logado.
  List<SocialAction> get myActions => _actions
      .where((a) => a.organizerId == _currentUser?.id)
      .toList(growable: false);

  /// Organizador: inscrições nas suas ações. Morador: suas inscrições.
  List<Appointment> get appointments => List.unmodifiable(_appointments);

  List<AppNotification> get notifications => List.unmodifiable(
    _notifications.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  );

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.read).length;

  SocialAction? actionById(int id) {
    for (final action in _actions) {
      if (action.id == id) return action;
    }
    return null;
  }

  /// Inscrição confirmada do morador logado na ação, se houver.
  Appointment? myAppointmentFor(int actionId) {
    for (final appointment in _appointments) {
      if (appointment.actionId == actionId &&
          appointment.userId == _currentUser?.id &&
          appointment.status == AppointmentStatus.confirmed) {
        return appointment;
      }
    }
    return null;
  }

  // Sessão
  Future<void> loadUsers() => _run(() async {
        _users = await api.fetchUsers();
      });

  Future<void> login(AppUser user) async {
    _currentUser = user;
    _actions = [];
    _appointments = [];
    _notifications.clear();
    notifyListeners();
    await refresh();
  }

  void logout() {
    _currentUser = null;
    _actions = [];
    _appointments = [];
    _notifications.clear();
    notifyListeners();
  }

  /// Recarrega ações e inscrições do servidor.
  Future<void> refresh() => _run(() async {
        _actions = await api.fetchActions();
        await _loadAppointments();
      });

  Future<void> _loadAppointments() async {
    final user = _currentUser;
    if (user == null) {
      _appointments = [];
    } else if (user.role == UserRole.morador) {
      _appointments = await api.fetchRegistrations(userId: user.id);
    } else {
      final myActionIds = myActions.map((a) => a.id).toSet();
      final all = await api.fetchRegistrations();
      _appointments = all.where((r) => myActionIds.contains(r.actionId)).toList();
    }
  }

  // Organizador: Cadastrar ação social
  Future<void> registerAction({
    required String title,
    required String description,
    required String location,
    required DateTime dateTime,
    required int totalSlots,
    required List<String> requiredDocuments,
  }) async {
    await api.createAction(
      organizerId: _currentUser!.id,
      title: title,
      description: description,
      location: location,
      dateTime: dateTime,
      vacancies: totalSlots,
      docs: requiredDocuments,
    );
    await refresh();
  }

  // Organizador: Gerenciar vagas
  Future<void> updateSlots(int actionId, int newTotalSlots) async {
    await api.updateVacancies(actionId, newTotalSlots);
    await refresh();
  }

  // Morador: Verificar documentos (retorna quais faltam)
  List<String> missingDocuments(int actionId, List<String> providedDocuments) {
    final required = actionById(actionId)?.requiredDocuments ?? const [];
    return required.where((doc) => !providedDocuments.contains(doc)).toList();
  }

  /// Morador: Realizar agendamento (inclui verificação de documentos).
  /// Só envia a inscrição ao servidor quando todos os documentos foram
  /// confirmados. Retorna true se o agendamento foi confirmado.
  Future<bool> bookAppointment({
    required int actionId,
    required List<String> documentIds,
  }) async {
    final action = actionById(actionId)!;
    final missing = missingDocuments(actionId, documentIds);

    if (missing.isNotEmpty) {
      _pushNotification(
        title: 'Documentos pendentes',
        message:
            'Faltam documentos para confirmar "${action.title}": ${missing.join(', ')}.',
      );
      notifyListeners();
      return false;
    }

    await api.createRegistration(userId: _currentUser!.id, actionId: actionId);
    _pushNotification(
      title: 'Agendamento confirmado',
      message: 'Seu agendamento para "${action.title}" foi confirmado.',
    );
    await refresh();
    return true;
  }

  // Morador: Cancelar agendamento
  Future<void> cancelAppointment(int appointmentId) async {
    final appointment = _appointments.firstWhere((a) => a.id == appointmentId);
    await api.cancelRegistration(appointmentId);
    _pushNotification(
      title: 'Agendamento cancelado',
      message: 'Seu agendamento para "${appointment.actionTitle}" foi cancelado.',
    );
    await refresh();
  }

  void _pushNotification({required String title, required String message}) {
    _notifications.add(AppNotification(
      id: _nextId('notification'),
      title: title,
      message: message,
      createdAt: DateTime.now(),
    ));
  }

  void markNotificationRead(String id) {
    final notification = _notifications.firstWhere((n) => n.id == id);
    notification.read = true;
    notifyListeners();
  }

  void markAllNotificationsRead() {
    for (final n in _notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  // Executa uma carga do servidor guardando o estado de carregamento/erro
  Future<void> _run(Future<void> Function() task) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await task();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
