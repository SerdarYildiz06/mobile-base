extension StringUtils on String {}

extension DoubleUtils on double {
  String formatSize() {
    if (this >= 1024 * 1024 * 1024) {
      return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (this >= 1024 * 1024) {
      return '${(this / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(this / 1024).toStringAsFixed(1)} KB';
    }
  }
}

extension IntUtils on int {
  String formatVideoDuration() {
    final hours = this ~/ 3600;
    final minutes = (this % 3600) ~/ 60;
    final secs = this % 60;

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${secs.toString().padLeft(2, '0')}';
    }
  }
}
