import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../footer.dart';
import 'package:intl/intl.dart';

class DescriptionScreen extends StatefulWidget {
  final String doctorId;
  DescriptionScreen({required this.doctorId});

  @override
  _DescriptionScreenState createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  late Map<String, List<String>> availability = {};
  late Set<String> bookedSlots = Set<String>(); // To store booked slots
  Map<String, dynamic>? doctor; // To store doctor details

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
    _fetchBookedSlots();
  }

  Future<void> _fetchDoctorData() async {
    try {
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.doctorId)
          .get();
      if (doctorDoc.exists) {
        setState(() {
          doctor = doctorDoc.data() as Map<String, dynamic>;

          // Check if 'availability' exists and is a Map
          if (doctor!.containsKey('availability') &&
              doctor!['availability'] is Map) {
            Map<String, dynamic> availabilityMap =
            doctor!['availability'] as Map<String, dynamic>;

            availability = availabilityMap.map((key, value) {
              if (value is List) {
                // Convert each timestamp to a formatted string
                List<String> slots = value.map((slot) {
                  if (slot is Timestamp) {
                    DateTime dateTime = slot.toDate();
                    return _formatDateTime(dateTime);
                  }
                  else {
                    print('Unexpected slot type: ${slot.runtimeType}');
                    return '';
                  }
                }).toList();
                return MapEntry(key, slots);
              } else {
                return MapEntry(key, []);
              }
            });
          } else {
            availability = {};
          }
        });
      } else {
        print('Doctor not found');
      }
    } catch (e) {
      print('Error fetching doctor data: $e');
    }
  }
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }
  Future<void> _fetchBookedSlots() async {
    try {
      QuerySnapshot appointmentSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: widget.doctorId)
          .get();

      Set<String> booked = Set<String>();

      for (var doc in appointmentSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        booked.add(data['appointmentTime']);
      }

      setState(() {
        bookedSlots = booked;
      });
    } catch (e) {
      print('Error fetching booked slots: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Dentists Details',
          style: TextStyle(fontFamily: 'GoogleSans', color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor's image in a card
              if (doctor != null && doctor!['imageUrl'] != null)
                Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  elevation: 4,
                  child: Image.network(
                    doctor!['imageUrl'],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              SizedBox(height: 10),

              // Doctor's details in a card
              if (doctor != null)
                Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. ${doctor!['userName'] ?? ''}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GoogleSans',
                          ),
                        ),
                        SizedBox(height: 10),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Specialization',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'GoogleSans',
                            ),
                          ),
                          subtitle: Text(
                            doctor!['speciality'] ?? '',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.location_on, color: Colors.blue, size: 24),
                          title: Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'GoogleSans',
                            ),
                          ),
                          subtitle: GestureDetector(
                            onTap: () async {
                              final url = 'https://www.google.com/maps/search/?api=1&query=${doctor!['location']}';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Text(
                              doctor!['location'] ?? '',
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ),
                        Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'About',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'GoogleSans',
                            ),
                          ),
                          subtitle: Text(
                            doctor!['description'] ?? '',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 20),

              // Available slots in a card
              Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Slots',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'GoogleSans',
                        ),
                      ),
                      SizedBox(height: 10),
                      // Display availability slots by day
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: availability.entries
                            .where((entry) => entry.value.any((slot) => !bookedSlots.contains(slot)))
                            .map((entry) {
                          String day = entry.key;
                          List<String> slots = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(day,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                              SizedBox(height: 5),
                              Wrap(
                                spacing: 10,
                                children: slots.map((slot) {
                                  bool isDisabled = bookedSlots.contains(slot);

                                  return GestureDetector(
                                    onTap: isDisabled
                                        ? null
                                        : () {
                                      _navigateToAppointment(context, slot);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: isDisabled
                                            ? Colors.grey[300]
                                            : Colors.blueGrey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        slot,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isDisabled
                                              ? Colors.grey
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 20),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FooterScreen(),
    );
  }

  void _navigateToAppointment(BuildContext context, String selectedSlot) {
    Navigator.pushNamed(
      context,
      '/appointment',
      arguments: {
        'doctorId': widget.doctorId,
        'selectedSlot': selectedSlot,
      },
    );
  }
}
