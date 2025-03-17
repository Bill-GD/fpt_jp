import 'pad_int.dart';

const _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

extension DateString on DateTime {
  String toDateString() {
    final local = toLocal();
    // return '$_formatDay ${_monthNames[month - 1]} $year, ${hour.padIntLeft(2, '0')}:${minute.padIntLeft(2, '0')}:${second.padIntLeft(2, '0')}';
    return '${_formatDay(local.day)} ${_monthNames[month - 1]} $year, ${local.hour.padIntLeft(2, '0')}:${local.minute.padIntLeft(2, '0')}:${local.second.padIntLeft(2, '0')}';
  }

  String _formatDay(int day) {
    switch (day) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }
}
