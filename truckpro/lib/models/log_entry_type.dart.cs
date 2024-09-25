namespace lib.models
{
    public enum log_entry_type.dart
    {
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

        
    }
}