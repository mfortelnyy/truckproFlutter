// stopwatch_view.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class StopwatchView extends StatefulWidget {
  const StopwatchView({super.key});

  @override
  _StopwatchViewState createState() => _StopwatchViewState();
}

class _StopwatchViewState extends State<StopwatchView> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(mode: StopWatchMode.countUp);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start the timer when the view is initialized
    _stopWatchTimer.onStartTimer();
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    super.dispose();
  }

  Widget _buildTimerDisplay() {
    return StreamBuilder<int>(
      stream: _stopWatchTimer.rawTime,
      initialData: 0,
      builder: (context, snapshot) {
        final value = snapshot.data ?? 0;
        final displayTime = StopWatchTimer.getDisplayTime(value);
        return Text(
          displayTime,
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  void _toggleTimer() {
    if (_stopWatchTimer.isRunning) {
      _stopWatchTimer.onStopTimer();
    } else {
      _stopWatchTimer.onStartTimer();
    }
    setState(() {});
  }

  void _resetTimer() {
    _stopWatchTimer.onResetTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
        backgroundColor: const Color.fromARGB(255, 241, 158, 89),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimerDisplay(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleTimer,
              child: Text(_stopWatchTimer.isRunning ? 'Stop' : 'Start'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _resetTimer,
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
