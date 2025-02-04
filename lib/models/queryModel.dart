import 'package:cloud_firestore/cloud_firestore.dart';
class Question {
  final String id;
  final String patientId;
  final String questionText;
  final DateTime timestamp;
  final bool isAnswered;

  Question({
    required this.id,
    required this.patientId,
    required this.questionText,
    required this.timestamp,
    required this.isAnswered,
  });
}

class Answer {
  final String id;
  final String questionId;
  final String doctorId;
  final String answerText;
  final DateTime timestamp;

  Answer({
    required this.id,
    required this.questionId,
    required this.doctorId,
    required this.answerText,
    required this.timestamp,
  });
}
