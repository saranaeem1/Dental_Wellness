import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  String id;
  String doctorId;
  String doctorName;
  String patientName;
  String patientAge;
  String patientIssue;
  String appointmentTime;
  Timestamp timestamp;
  String userId;

  Appointment({
    this.id = '', // Default value
    required this.doctorId,
    required this.doctorName,
    required this.patientName,
    required this.patientAge,
    required this.patientIssue,
    required this.appointmentTime,
    required this.timestamp,
    required this.userId,
  });

  factory Appointment.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      patientName: data['patientName'] ?? '',
      patientAge: data['patientAge'] ?? '',
      patientIssue: data['patientIssue'] ?? '',
      appointmentTime: data['appointmentTime'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientName': patientName,
      'patientAge': patientAge,
      'patientIssue': patientIssue,
      'appointmentTime': appointmentTime,
      'timestamp': timestamp,
      'userId': userId,
    };
  }
}
