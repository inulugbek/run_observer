import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'key.dart';
import 'scope.dart';

class RunObserver with LoadingStateMixin {
  /// Returns [true] if this is the first run of after app install
  /// otherwise [false]
  bool get isFirstRun => _isFirstRun;

  /// Returns total runs since it was installed
  int get totalRuns => _totalRuns;

  /// Returns total runs for today
  int get todayRuns => _totalRuns;

  /// Returns total app runs on provided [DateTime]
  int getRunsOnDate(DateTime dateTime) {
    final key = _trackingKey.keyForDate(dateTime);

    try {
      return _prefs?.getInt(key) ?? 0;
    } on Exception {
      return 0;
    }
  }

  String get trackingKey => _trackingKey.key;

  /// returns the closest [RunObserver] from [BuildContext]
  static RunObserver of(BuildContext context) => RunObserverScope.of(context);

  factory RunObserver([String key]) {
    key ??= 'APP';

    if (_observers.containsKey(key)) {
      _observers[key]._getRunData();
      return _observers[key];
    }

    final _instance = RunObserver._(key).._init();
    _observers[key] = _instance;
    return _instance;
  }

  RunObserver._(String key) : _trackingKey = TrackingKey(key);

  /// dispose [RunObserver] from the memory
  void dispose() {
    _observers.remove(_trackingKey.key);
    _disposeLoading();
  }

  bool _isFirstRun;
  int _totalRuns;
  int _todayRuns;

  /// data storage
  static SharedPreferences _prefs;

  /// all instantiated [RunObserver]s cached
  static final Map<String, RunObserver> _observers = {};

  final TrackingKey _trackingKey;

  /// initiate [RunObserver] save current run and load run data
  Future<void> _init() async {
    _startLoading();
    await _saveCurrentRun();
    return _getRunData();
  }

  /// loads run data for current [RunObserver] instance
  Future<void> _getRunData() async {
    _startLoading();
    _prefs ??= await SharedPreferences.getInstance();
    _isFirstRun ??= await _checkIfFirstRun();
    _totalRuns ??= await _getDataForKey(_trackingKey.keyTotalRuns);
    _todayRuns ??= await _getDataForKey(_trackingKey.keyToday);
    _stopLoading();
  }

  /// Returns [int] run count for key provided
  Future<int> _getDataForKey(String key) async {
    try {
      return _prefs.getInt(key) ?? 0;
    } on Exception {
      return 0;
    }
  }

  /// Saves current run and current date
  Future<void> _saveCurrentRun() async {
    _prefs ??= await SharedPreferences.getInstance();
    _saveCurrentRunForKey(_trackingKey.keyToday);
    _saveCurrentRunForKey(_trackingKey.keyTotalRuns);
  }

  /// Saves current app run to the storage for provided key
  Future<bool> _saveCurrentRunForKey(String key) async {
    int runsForKey;
    try {
      runsForKey = _prefs.getInt(key) ?? 0;
    } on Exception {
      runsForKey = 0;
    }
    return _prefs.setInt(key, runsForKey + 1);
  }

  /// Returns [true] if this is the first time this function has been called
  /// since installing the app, otherwise [false].
  Future<bool> _checkIfFirstRun() async {
    bool isFirstRun;
    try {
      return isFirstRun = _prefs.getBool(_trackingKey.keyIsFirstRun) ?? true;
    } on Exception {
      return isFirstRun = true;
    } finally {
      if (isFirstRun) _prefs.setBool(_trackingKey.keyIsFirstRun, false);
    }
  }
}

/// Mixin to encapsulate the logic of loading state
mixin LoadingStateMixin {
  StreamController<bool> _isLoading = StreamController<bool>();

  /// Loading state stream where
  /// [true] is loading,
  /// [false] is finished loading
  Stream<bool> get isLoading => _isLoading.stream;

  void _startLoading() {
    if (_isLoading.isClosed) {
      _isLoading = StreamController<bool>()..add(true);
    } else {
      _isLoading.add(true);
    }
  }

  void _stopLoading() => _isLoading.add(false);

  void _disposeLoading() => _isLoading.close();
}
