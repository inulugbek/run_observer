import 'dart:async';

import 'package:flutter/material.dart';

import 'observer.dart';

typedef RunObserverBuilder = Widget Function(BuildContext, RunObserver);

@immutable
class RunObserverScope extends StatefulWidget {
  final String trackingKey;
  final Function onFirstRun;
  final Function onRun;
  final RunObserverBuilder builder;
  final Widget splash;

  const RunObserverScope({
    @required this.builder,
    this.splash,
    this.trackingKey,
    this.onFirstRun,
    this.onRun,
    Key key,
  }) : super(key: key);

  /// For context lookup of [RunObserverScope]
  static RunObserver of(BuildContext context, {String trackingKey}) {
    if (trackingKey != null) return RunObserver(trackingKey);
    return context
        .findAncestorStateOfType<_RunObserverScopeState>()
        ._runObserver;
  }

  @override
  State<RunObserverScope> createState() => _RunObserverScopeState();
}

class _RunObserverScopeState extends State<RunObserverScope> {
  bool _isObserverLoading;
  StreamSubscription<bool> _sub;
  RunObserver _runObserver;

  @override
  void initState() {
    super.initState();
    _isObserverLoading = true;
    _runObserver = RunObserver(widget.trackingKey);

    if (widget.onRun != null) widget.onRun();

    if (widget.onFirstRun == null) {
      _isObserverLoading = false;
    } else {
      _sub = _runObserver.isLoading.listen((isLoading) {
        _isObserverLoading = isLoading ?? true;

        if (!_isObserverLoading) {
          if (_runObserver.isFirstRun) widget.onFirstRun();

          _sub.cancel();

          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _runObserver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _isObserverLoading
      ? MaterialApp(home: widget.splash ?? const SizedBox.shrink())
      : Builder(builder: (context) => widget.builder(context, _runObserver));
}
