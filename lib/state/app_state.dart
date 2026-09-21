import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../models/appointment.dart';
import '../models/social_action.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _seedData();
  }

  final List<SocialAction> _actions = [];
  final List<Appointment> _appointments = [];
  final List<AppNotification> _notifications = [];

  int _idCounter = 0;
  String _nextId(String prefix) => '$prefix-${_idCounter++}';

  List<SocialAction> get actions => List.unmodifiable(_actions);
  List<Appointment> get appointments => List.unmodifiable(_appointments);
  List<AppNotification> get notifications => List.unmodifiable(
    _notifications.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  );

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.read).length;

  void _seedData() {
    _actions.addAll([
      SocialAction(
        id: _nextId('action'),
        title: 'Doação de Agasalhos',
        description: 'Distribuição de roupas de frio para famílias cadastradas.',
        location: 'Centro Comunitário - Bairro Esperança',
        dateTime: DateTime.now().add(const Duration(days: 3)),
        totalSlots: 20,
        requiredDocuments: ['RG', 'Comprovante de residência'],
      ),
      SocialAction(
        id: _nextId('action'),
        title: 'Mutirão de Saúde',
        description: 'Atendimento médico e odontológico gratuito.',
        location: 'Posto de Saúde Central',
        dateTime: DateTime.now().add(const Duration(days: 7)),
        totalSlots: 15,
        requiredDocuments: ['RG', 'Cartão SUS'],
      ),
      SocialAction(
        id: _nextId('action'),
        title: 'Cesta Básica Solidária',
        description: 'Entrega de cestas básicas para famílias em vulnerabilidade.',
        location: 'Igreja Nossa Senhora Aparecida',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        totalSlots: 30,
        requiredDocuments: ['RG', 'CPF', 'Comprovante de residência'],
      ),
    ]);
  }

  SocialAction actionById(String id) => _actions.firstWhere((a) => a.id == id);

  List<Appointment> appointmentsForAction(String actionId) =>
      _appointments.where((a) => a.actionId == actionId).toList();

  // Organizador: Cadastrar ação social
  void registerAction({
    required String title,
    required String description,
    required String location,
    required DateTime dateTime,
    required int totalSlots,
    required List<String> requiredDocuments,
  }) {
    _actions.add(SocialAction(
      id: _nextId('action'),
      title: title,
      description: description,
      location: location,
      dateTime: dateTime,
      totalSlots: totalSlots,
      requiredDocuments: requiredDocuments,
    ));
    notifyListeners();
  }

  // Organizador: Gerenciar vagas
  void updateSlots(String actionId, int newTotalSlots) {
    final action = actionById(actionId);
    if (newTotalSlots < action.bookedSlots) {
      newTotalSlots = action.bookedSlots;
    }
    final index = _actions.indexWhere((a) => a.id == actionId);
    _actions[index] = SocialAction(
      id: action.id,
      title: action.title,
      description: action.description,
      location: action.location,
      dateTime: action.dateTime,
      totalSlots: newTotalSlots,
      requiredDocuments: action.requiredDocuments,
      bookedSlots: action.bookedSlots,
    );
    notifyListeners();
  }

  // Morador: Verificar documentos (retorna quais faltam)
  List<String> missingDocuments(String actionId, List<String> providedDocuments) {
    final required = actionById(actionId).requiredDocuments;
    return required
        .where((doc) => !providedDocuments.contains(doc))
        .toList();
  }

  // Morador: Realizar agendamento (inclui verificação de documentos)
  Appointment bookAppointment({
    required String actionId,
    required String moradorName,
    required List<String> documentIds,
  }) {
    final action = actionById(actionId);
    final missing = missingDocuments(actionId, documentIds);
    final verified = missing.isEmpty;

    final appointment = Appointment(
      id: _nextId('appointment'),
      actionId: actionId,
      moradorName: moradorName,
      documentIds: documentIds,
      createdAt: DateTime.now(),
      documentsVerified: verified,
      status: verified ? AppointmentStatus.confirmed : AppointmentStatus.pending,
    );

    _appointments.add(appointment);

    if (verified) {
      final index = _actions.indexWhere((a) => a.id == actionId);
      _actions[index].bookedSlots += 1;
      _pushNotification(
        title: 'Agendamento confirmado',
        message: 'Seu agendamento para "${action.title}" foi confirmado.',
      );
    } else {
      _pushNotification(
        title: 'Documentos pendentes',
        message:
            'Faltam documentos para confirmar "${action.title}": ${missing.join(', ')}.',
      );
    }

    notifyListeners();
    return appointment;
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
}
