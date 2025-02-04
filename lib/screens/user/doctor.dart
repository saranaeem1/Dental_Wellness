import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../footer.dart';
import 'package:intl/intl.dart';

class DoctorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Dentists',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'GoogleSans',
          fontSize: 20),),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,

      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('isDoctor', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            var doctors = snapshot.data!.docs;

            return ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                var doctor = doctors[index].data() as Map<String, dynamic>;

                String userName = doctor['userName'] ?? 'Unknown';
                String speciality = doctor['speciality'] ?? 'Not Specified';
                String location = doctor['location'] ?? 'Location not available';
                String formattedAppointmentTime = '';

                var appointmentTime = doctor['appointmentTime'];
                if (appointmentTime != null) {
                  if (appointmentTime is Timestamp) {
                    DateTime dateTime = appointmentTime.toDate();
                    formattedAppointmentTime = DateFormat('yyyy-MM-dd – HH:mm').format(dateTime);
                  } else if (appointmentTime is String) {
                    formattedAppointmentTime = appointmentTime;
                  } else {
                    print('Unexpected appointmentTime format: $appointmentTime');
                  }
                }
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/desc', arguments: {
                      'doctorId': doctors[index].id, 
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 0.5,
                          color: Colors.grey,
                          offset: Offset(0, 0.5),
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            'assets/Images/avatar.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Dr. $userName',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'GoogleSans',
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                speciality,
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontFamily: 'GoogleSans',
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      color: Colors.blue, size: 18),
                                  SizedBox(width: 5),
                                  Text(
                                    location,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontFamily: 'GoogleSans',
                                    ),
                                  ),
                                ],
                              ),
                              if (formattedAppointmentTime.isNotEmpty) ...[
                                SizedBox(height: 10),
                                Text(
                                  'Available at: $formattedAppointmentTime',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: FooterScreen(),
    );
  }
}
