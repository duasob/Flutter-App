import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';


void main() => runApp(AlarmApp());

class AlarmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm Clock',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AlarmHomePage(),
    );
  }
}

class AlarmHomePage extends StatefulWidget {
  @override
  _AlarmHomePageState createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<AlarmHomePage> {
  TimeOfDay _time = TimeOfDay.now();
  TimeOfDay? _pickedTime;
  Timer? _timer;
  Timer? _timeUpdateTimer;
  AudioPlayer audioPlayer = AudioPlayer();
  final player = AudioPlayer();
  bool isAlarmPlaying = false;
  
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _checkTime());
    _timeUpdateTimer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    setState(() {
      _time = TimeOfDay.now();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeUpdateTimer?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  void _checkTime() {
    final now = DateTime.now();
    if (_pickedTime != null &&
        now.hour == _pickedTime!.hour &&
        now.minute == _pickedTime!.minute &&
        now.second == 0 && !isAlarmPlaying) {
      _playSound();
    }
  }

  Future<void> _playSound() async {
    await player.stop();
    setState(() {
      isAlarmPlaying = true;
    });
    player.play(AssetSource("alarm_sound.mp3"));
  }

  Future<void> _stopSound() async {
    await player.stop();
    setState(() {
      isAlarmPlaying = false;
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _pickedTime = picked;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alarm set to: ${picked.format(context)}'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm Clock'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Current Time: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'Alarm Time: ${_pickedTime?.format(context) ?? 'Not Set'}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Icon(
              isAlarmPlaying ? Icons.alarm_on : Icons.alarm_off,
              color: isAlarmPlaying ? Colors.red : Colors.grey,
              size: 48,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text('Set Alarm'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _playSound,
              child: Text('Test Alarm Sound'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopSound,
              child: Text('Stop Alarm'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
