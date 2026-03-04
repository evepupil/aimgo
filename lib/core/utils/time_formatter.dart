String formatMinutes(num minutes) {
  if (minutes <= 0) {
    return '0m';
  }

  final roundedMinutes = minutes.round();
  if (roundedMinutes < 60) {
    return '${roundedMinutes}m';
  }

  final hours = roundedMinutes ~/ 60;
  final restMinutes = roundedMinutes % 60;
  if (restMinutes == 0) {
    return '${hours}h';
  }
  return '${hours}h ${restMinutes}m';
}
