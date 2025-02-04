import 'package:flutter/material.dart';
import 'alarm_start.dart';
import '../footer.dart';

void main() {
  runApp(MaterialApp(
    home: BrushingAlarmPage(),
    theme: ThemeData(
      primarySwatch: Colors.cyan,
    ),
  ));
}
// alarm
class BrushingAlarmPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        title: Text('Brushing Alarm', style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Images/CuteTooth.jpeg',
              // width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(
              height: 40,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BrushingAlarmScreen()),
                );
              },
              child: Text('Your Brushing Routine'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.cyan,
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                minimumSize: Size(250, 60),
                textStyle: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
                side: BorderSide(
                    color: Colors.cyan, width: 2), // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FooterScreen(),
    );
  }
}
