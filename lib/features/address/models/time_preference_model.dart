// lib/features/address/models/time_preference_model.dart

enum DeliveryType {
  instant,
  scheduled,
}

class TimePreferenceModel {
  final DeliveryType type;
  final DateTime? scheduledDate;
  final String? timeSlot;
  final String? deliveryInstructions;

  const TimePreferenceModel({
    this.type = DeliveryType.instant,
    this.scheduledDate,
    this.timeSlot,
    this.deliveryInstructions,
  });

  bool get isInstant => type == DeliveryType.instant;
  bool get isScheduled => type == DeliveryType.scheduled;

  String get summary {
    if (isInstant) {
      return 'Instant Delivery (15–25 mins)';
    }
    final dateStr = scheduledDate != null
        ? '${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}'
        : 'Tomorrow';
    final slotStr = timeSlot ?? 'Morning (08:00 AM – 10:00 AM)';
    return 'Scheduled: $dateStr, $slotStr';
  }

  TimePreferenceModel copyWith({
    DeliveryType? type,
    DateTime? scheduledDate,
    String? timeSlot,
    String? deliveryInstructions,
  }) {
    return TimePreferenceModel(
      type: type ?? this.type,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
    );
  }
}
