String calculateDuration(DateTime startTime, DateTime? endTime) {
  final end = endTime ?? DateTime.now();
  final duration = end.difference(startTime);

  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (hours > 0) {
    return "$hours hours and $minutes minutes";
  } else {
    return "$minutes minutes";
  }
}
