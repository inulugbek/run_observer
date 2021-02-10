const _kIsFirstRun = '_IS_FIRST_RUN';
const _kTotalRuns = '_TOTAL_RUNS';
const _kRunsOnDate = '_RUNS_ON_';

class TrackingKey {
  final String key;

  const TrackingKey(this.key);

  String get keyIsFirstRun => _appendPrefix(_kIsFirstRun);

  String get keyTotalRuns => _appendPrefix(_kTotalRuns);

  String get keyToday => keyForDate(DateTime.now());

  String keyForDate(DateTime date) {
    final dateString = '${date.year}-${date.month}-${date.day}';
    final suffix = '$_kRunsOnDate$dateString';
    return _appendPrefix(suffix);
  }

  String _appendPrefix(String value) =>
      key.toLowerCase() == 'app' ? '${key.toUpperCase()}$value' : '$key$value';
}
