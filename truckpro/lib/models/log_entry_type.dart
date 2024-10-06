enum LogEntryType {
  Driving,
  OnDuty,
  Break,
  OffDuty
}

extension LogEntryTypeExtension on LogEntryType {
  String toShortString() {
    return toString().split('.').last;
  }
}