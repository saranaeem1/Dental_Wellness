import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

class BrushingAlarmScreen extends StatefulWidget {
  @override
  _BrushingAlarmScreenState createState() => _BrushingAlarmScreenState();
}

class _BrushingAlarmScreenState extends State<BrushingAlarmScreen> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AudioPlayer audioPlayer;
  List<Map<String, dynamic>> shownNotifications = [];
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initializeNotifications();
    audioPlayer = AudioPlayer();
  }

  void _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void _initializeNotifications() {
    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(int id, String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'brushing_alarm_channel', // Channel ID
      'Brushing Alarm Notifications', // Channel Name
      channelDescription: 'Notifications for brushing routine steps', // Channel Description
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'), // Ensure the sound file is in `res/raw`
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id, title, body, platformChannelSpecifics,
    );
    _playSound(); // This will play the sound using `audioplayers`
    setState(() {
      shownNotifications.add({'title': title, 'body': body});
    });
  }


  Future<void> _playSound() async {
    await audioPlayer.play(AssetSource('assets/audios/alarm.mp3'));
  }

  void _scheduleBrushingNotifications() {
    if (isRunning) return;
    isRunning = true;
    final steps = [
      {
        'time': 0,
        'title': 'Start Brushing',
        'body': 'Wet your toothbrush and apply toothpaste.'
      },
      {
        'time': 10,
        'title': 'Brush Upper Teeth',
        'body': 'Brush the outer surfaces of the upper teeth.'
      },
      {
        'time': 40,
        'title': 'Brush Lower Teeth',
        'body': 'Brush the outer surfaces of the lower teeth.'
      },
      {
        'time': 70,
        'title': 'Brush Upper Teeth Inner',
        'body': 'Brush the inner surfaces of the upper teeth.'
      },
      {
        'time': 100,
        'title': 'Brush Lower Teeth Inner',
        'body': 'Brush the inner surfaces of the lower teeth.'
      },
      {
        'time': 130,
        'title': 'Brush Chewing Surfaces',
        'body': 'Brush the chewing surfaces of all teeth.'
      },
      {
        'time': 160,
        'title': 'Brush Tongue',
        'body': 'Brush your tongue to remove bacteria and freshen breath.'
      },
      {'time': 190, 'title': 'Rinse', 'body': 'Rinse your mouth with water.'},
    ];

    for (var step in steps) {
      _scheduleStepNotification(
          step['time'] as int, step['title'] as String, step['body'] as String);
    }
  }

  void _scheduleStepNotification(int time, String title, String body) {
    Future.delayed(Duration(seconds: time), () {
      if (!isRunning) return;
      _showNotification(time, title, body);
    });
  }

  void _stopBrushing() {
    setState(() {
      isRunning = false;
      shownNotifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        title: Text('Brushing Routine',
            style: TextStyle(
              fontFamily: 'Poppins',
            )),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 30,
          ),
          TextButton(
            onPressed: _scheduleBrushingNotifications,
            child: Text('Start Brushing'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.cyan,
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              minimumSize: Size(200, 60),
              textStyle: TextStyle(
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
              side: BorderSide(color: Colors.cyan, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          SizedBox(height: 20),
          if (isRunning)
            TextButton(
              onPressed: _stopBrushing,
              child: Text('Stop Brushing'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                minimumSize: Size(200, 60),
                textStyle: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Poppins',
                ),
                side: BorderSide(color: Colors.red, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          SizedBox(
            height: 30,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: shownNotifications.length,
              itemBuilder: (context, index) {
                final notification = shownNotifications[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(notification['title']!,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              color: Colors.cyan)),
                      subtitle: Text(notification['body']!,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.black)),
                    ),
                    Divider(
                      thickness: 3,
                      color: Colors.grey[300],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
