import 'dart:async';
import 'package:flutter/foundation.dart';

/// Helper to debounce user keystrokes (e.g. 400ms for search queries).
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 400)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
