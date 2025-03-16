extension PadInt on int {
  String padIntLeft(int count, [String padding = ' ']) {
    return toString().padLeft(count, padding);
  }
}
