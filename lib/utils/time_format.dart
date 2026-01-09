String formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final hours = minutes ~/ 60;
  final leftoverMinutes = minutes % 60;
  return '${hours}h ${leftoverMinutes}m';
}
