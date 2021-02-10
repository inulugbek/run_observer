import 'package:flutter_test/flutter_test.dart';
import 'package:run_observer/run_observer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RunObserver', () {
    test('shouldCreate', () {
      final runObserver = RunObserver();
      expect(runObserver is RunObserver, true);
    });

    test('identical', () {
      final runObserver1 = RunObserver();
      final runObserver2 = RunObserver('APP');
      expect(runObserver1 == runObserver2, true);
      expect(identical(runObserver1, runObserver2), true);
    });
  });
}
