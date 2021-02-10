import 'package:flutter/material.dart';

import 'package:run_observer/run_observer.dart';

// ignore_for_file: avoid_print

void main() => runApp(const App());

@immutable
class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => RunObserverScope(
        onFirstRun: () {
          print('first run');
        },
        onRun: () {
          print('im running');
        },
        splash: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        builder: (conetxt, runObserver) => const MaterialApp(
          title: 'Flutter Run Observer Demo',
          home: HomePage(),
        ),
      );
}

@immutable
class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Run Observer Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('is first run ${RunObserver.of(context).isFirstRun}'),
              Text('total app runs ${RunObserver.of(context).totalRuns}'),
              Text(
                  'app runs today ${RunObserver().getRunsOnDate(DateTime.now())}'),
              Text(
                  'app runs yesterday ${RunObserver('APP').getRunsOnDate(DateTime(2021, 1, 21))}'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print(
              RunObserver().getRunsOnDate(
                DateTime.now().subtract(const Duration(days: 1)),
              ),
            );
            print(RunObserver().totalRuns);

            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (context) => const SecondPage()),
            );
          },
          child: const Icon(Icons.check),
        ),
      );
}

@immutable
class SecondPage extends StatelessWidget {
  const SecondPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => RunObserverScope(
        trackingKey: '2PAGE',
        splash: const Center(child: CircularProgressIndicator()),
        builder: (context, observer) => Scaffold(
          appBar: AppBar(
            title: const Text('Other Page'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(observer.trackingKey),
                Text('is first run ${RunObserver.of(context).isFirstRun}'),
                Text('total page runs ${RunObserver.of(context).totalRuns}'),
                Text(
                    'page runs today ${RunObserver('2PAGE').getRunsOnDate(DateTime.now())}'),
                Text(
                    'page runs yesterday ${RunObserver('2PAGE').getRunsOnDate(DateTime(2021, 1, 21))}'),
              ],
            ),
          ),
        ),
      );
}
