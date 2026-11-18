enum CallPriority {
  user(hourlyLimit: 80),
  restoration(hourlyLimit: 70),
  background(hourlyLimit: 60);

  const CallPriority({required this.hourlyLimit});

  final int hourlyLimit;
}

class CallBudget {
  CallBudget({this._now = DateTime.now});

  static const window = Duration(minutes: 60);

  final DateTime Function() _now;
  final _callTimes = <DateTime>[];
  DateTime? _blockedUntil;

  int get used {
    _forgetCallsOutsideWindow(_now());
    return _callTimes.length;
  }

  bool tryReserve(CallPriority priority) {
    final now = _now();
    if (_nextSlotAt(priority, now) != null) {
      return false;
    }
    _callTimes.add(now);
    return true;
  }

  DateTime? nextSlotAt(CallPriority priority) => _nextSlotAt(priority, _now());

  void blockUntil(DateTime until) {
    final blockedUntil = _blockedUntil;
    if (blockedUntil == null || until.isAfter(blockedUntil)) {
      _blockedUntil = until;
    }
  }

  DateTime? _nextSlotAt(CallPriority priority, DateTime now) {
    _forgetCallsOutsideWindow(now);

    final callsOverLimit = _callTimes.length - priority.hourlyLimit;
    final freedByWindow = callsOverLimit >= 0
        ? _callTimes[callsOverLimit].add(window)
        : null;

    final blockedUntil = _blockedUntil;
    if (blockedUntil == null || !blockedUntil.isAfter(now)) {
      return freedByWindow;
    }
    if (freedByWindow == null || blockedUntil.isAfter(freedByWindow)) {
      return blockedUntil;
    }
    return freedByWindow;
  }

  void _forgetCallsOutsideWindow(DateTime now) {
    _callTimes.removeWhere((callTime) => !callTime.add(window).isAfter(now));
  }
}
