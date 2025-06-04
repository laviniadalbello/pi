// lib/models/events_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Importe para usar Color

class Event {
  final String id;
  final String title;
  final DateTime startTime; // Firestore tem 'startTime' como Timestamp
  final DateTime? endTime; // Firestore tem 'endTime' como Timestamp
  final Color eventColor; // Você precisará de uma lógica para definir isso a partir dos dados ou default
  final String? location;
  final String status; // 'pending', 'completed', 'cancelled', etc.
  final String userId;
  final bool isCompleted; // Adicionado para consistência com `updateEventCompletion`

  Event({
    required this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.eventColor = const Color(0xFF7F5AF0), // <-- Cor padrão: um roxo/azul
    this.location,
    required this.status,
    required this.userId,
    this.isCompleted = false, // Padrão para não concluído
  });

  // Método auxiliar para converter String Hex para Color
  static Color _colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor; // Adiciona opacidade total se ausente
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  // Método auxiliar para converter Color para String Hex
  static String _colorToHex(Color color) {
    // Retorna o valor ARGB completo (ex: FF7F5AF0)
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
    // Se preferir apenas o RGB (ex: 7F5AF0), remova o substring(2):
    // return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }


  // Factory constructor para criar um Evento a partir de um documento do Firestore
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Converte Timestamp para DateTime
    final Timestamp? startTimeStamp = data['startTime'] as Timestamp?;
    final Timestamp? endTimeStamp = data['endTime'] as Timestamp?;

    // Obtém a cor como String Hex e converte para Color
    final String colorHex = data['eventColor'] ?? '#7F5AF0'; // Valor padrão se a cor não for encontrada
    final Color convertedColor = _colorFromHex(colorHex);

    return Event(
      id: doc.id, // O ID do documento do Firestore
      title: data['title'] ?? 'Sem Título',
      startTime: startTimeStamp?.toDate() ?? DateTime.now(), // Converte para DateTime
      endTime: endTimeStamp?.toDate(), // Converte para DateTime
      eventColor: convertedColor,
      location: data['location'],
      status: data['status'] ?? 'pending',
      userId: data['userId'] ?? '',
      isCompleted: data['isCompleted'] ?? false, // Padrão se não estiver no Firestore
    );
  }

  // MÉTODO toFirestore QUE ESTÁ FALTANDO OU COM PROBLEMAS
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'startTime': Timestamp.fromDate(startTime), // Converte DateTime para Timestamp
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null, // Converte DateTime para Timestamp
      'eventColor': _colorToHex(eventColor), // Converte Color para String Hex
      'location': location,
      'status': status,
      'userId': userId,
      'isCompleted': isCompleted,
    };
  }
}