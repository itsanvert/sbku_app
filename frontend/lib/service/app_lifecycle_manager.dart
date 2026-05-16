import 'package:flutter/material.dart';

/// App lifecycle event types
enum AppLifecycleEvent {
  resumed,
  paused,
  detached,
  hidden,
  inactive,
}

/// Manages application lifecycle events and state
class AppLifecycleManager with WidgetsBindingObserver {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();
  
  factory AppLifecycleManager() => _instance;
  AppLifecycleManager._internal();

  // Callbacks for lifecycle events
  Function(AppLifecycleEvent)? onLifecycleChange;

  bool _isInitialized = false;
  bool _isAppInBackground = false;

  bool get isAppInBackground => _isAppInBackground;

  /// Initialize the lifecycle manager
  void initialize() {
    if (_isInitialized) return;
    
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
    print('AppLifecycleManager initialized');
  }

  /// Cleanup resources
  void dispose() {
    if (_isInitialized) {
      WidgetsBinding.instance.removeObserver(this);
      _isInitialized = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppLifecycleEvent? event;
    
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInBackground = false;
        event = AppLifecycleEvent.resumed;
        print('App resumed');
        break;
      case AppLifecycleState.paused:
        event = AppLifecycleEvent.paused;
        print('App paused');
        break;
      case AppLifecycleState.detached:
        event = AppLifecycleEvent.detached;
        print('App detached');
        break;
      case AppLifecycleState.inactive:
        event = AppLifecycleEvent.inactive;
        print('App inactive');
        break;
      default:
        // Handle newer states like 'hidden' if available, otherwise ignore
        if (state.toString() == 'AppLifecycleState.hidden') {
          _isAppInBackground = true;
          event = AppLifecycleEvent.hidden;
          print('App hidden');
        }
    }

    if (event != null) {
      onLifecycleChange?.call(event);
    }
  }

  @override
  void didHaveMemoryPressure() {
    print('Memory pressure detected');
  }
}

