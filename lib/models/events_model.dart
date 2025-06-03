// No topo do seu arquivo PlannerDiarioPage.dart ou em um arquivo de modelo separado

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Para Color e TimeOfDay
import 'package:intl/intl.dart'; 

class EventModel {
  final String id;
  final String title; // Mudado de 'name' para 'title' para bater com Firestore
  final DateTime startTime; // Firestore tem 'startTime' como Timestamp
  final DateTime? endTime;  // Firestore tem 'endTime' como Timestamp
  final Color eventColor;   // Você precisará de uma lógica para definir isso a partir dos dados ou default
  final String? location;
  final String status;     // 'pending', 'completed', 'cancelled', etc.
  final String userId;

  EventModel({
    required this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.eventColor = kAccentPurple, // Cor padrão
    this.location,
    required this.status,
    required this.userId,
  });

  // Calcula a duração baseada em startTime e endTime
  Duration get duration {
    if (endTime == null) {
      return const Duration(hours: 1); // Duração padrão se não houver endTime
    }
    return endTime!.difference(startTime);
  }

  // Converte o startTime (DateTime) para TimeOfDay para a UI da timeline
  TimeOfDay get startTimeOfDay {
    return TimeOfDay(hour: startTime.hour, minute: startTime.minute);
  }

  bool get isCompleted { // Deriva isCompleted do status
    return status == 'completed'; // Ajuste conforme seus valores de status
  }

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    DateTime parsedStartTime = (data['startTime'] as Timestamp? ?? Timestamp.now()).toDate();
    DateTime? parsedEndTime = (data['endTime'] as Timestamp?)?.toDate();

    // Lógica para cor do evento - pode vir do Firestore ou ser definida de outra forma
    // Exemplo: se você tiver um campo 'colorHex' no Firestore para eventos:
    // Color color = data['colorHex'] != null 
    //              ? Color(int.parse("0xFF${data['colorHex'].replaceAll('#', '')}")) 
    //              : kAccentPurple;

    return EventModel(
      id: doc.id,
      title: data['title'] ?? 'Evento Sem Título',
      startTime: parsedStartTime,
      endTime: parsedEndTime,
      location: data['location'],
      status: data['status'] ?? 'pending',
      userId: data['userId'] ?? '',
      eventColor: kAccentPurple, // TODO: Defina a cor do evento (pode vir do Firestore ou lógica)
    );
  }
}