extension DurationUtils on Duration {
  toDisplayableString() {
    final days = inDays > 0 ? inDays.toString().padLeft(2, '0') + ':' : '';
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$days$hours:$minutes:$seconds';
  }
}
