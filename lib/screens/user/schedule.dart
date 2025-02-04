import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scheduled Appointments',
          style: TextStyle(color: Colors.white, fontFamily: 'GoogleSans'),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('userId', isEqualTo: currentUserId) // Filter by current user
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No appointments scheduled', style: TextStyle(fontSize: 16, color: Colors.grey)));
          }

          List<QueryDocumentSnapshot> appointments = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var data = appointments[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  leading: Icon(Icons.schedule, color: Colors.blue),
                  title: Text(
                    'Patient: ${data['patientName']}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'GoogleSans'),
                  ),
                  subtitle: Text(
                    'Doctor: Dr. ${data['doctorName']}\nTime: ${data['appointmentTime']}',
                    style: TextStyle(color: Colors.grey[700], fontFamily: 'GoogleSans',fontSize: 16),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
