// lib/features/address/screens/sections/time_preference_section.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/time_preference_model.dart';

class TimePreferenceSection extends StatefulWidget {
  final TimePreferenceModel preference;
  final ValueChanged<TimePreferenceModel> onPreferenceChanged;

  const TimePreferenceSection({
    super.key,
    required this.preference,
    required this.onPreferenceChanged,
  });

  @override
  State<TimePreferenceSection> createState() => _TimePreferenceSectionState();
}

class _TimePreferenceSectionState extends State<TimePreferenceSection> {
  late DeliveryType _selectedType;
  late DateTime _selectedDate;
  late String _selectedTimeSlot;
  late final TextEditingController _instructionsController;

  static const List<String> _availableSlots = [
    '08:00 AM – 10:00 AM',
    '11:00 AM – 01:00 PM',
    '02:00 PM – 04:00 PM',
    '05:00 PM – 07:00 PM',
    '07:00 PM – 09:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.preference.type;
    _selectedDate = widget.preference.scheduledDate ?? DateTime.now().add(const Duration(days: 1));
    _selectedTimeSlot = widget.preference.timeSlot ?? _availableSlots.first;
    _instructionsController = TextEditingController(text: widget.preference.deliveryInstructions ?? '');
  }

  @override
  void didUpdateWidget(covariant TimePreferenceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preference != widget.preference) {
      _selectedType = widget.preference.type;
      if (widget.preference.scheduledDate != null) {
        _selectedDate = widget.preference.scheduledDate!;
      }
      if (widget.preference.timeSlot != null) {
        _selectedTimeSlot = widget.preference.timeSlot!;
      }
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onPreferenceChanged(
      TimePreferenceModel(
        type: _selectedType,
        scheduledDate: _selectedType == DeliveryType.scheduled ? _selectedDate : null,
        timeSlot: _selectedType == DeliveryType.scheduled ? _selectedTimeSlot : null,
        deliveryInstructions: _instructionsController.text.trim().isNotEmpty
            ? _instructionsController.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.schedule_rounded, color: AppColors.primaryDark, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Time Preference',
                      style: AppTextStyles.h2.copyWith(fontSize: 16),
                    ),
                    Text(
                      'Select instant dispatch or schedule for later',
                      style: AppTextStyles.caption.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Two Main Option Buttons: Instant vs Scheduled
          Row(
            children: [
              // 1. Instant Delivery Button
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedType = DeliveryType.instant;
                    });
                    _notifyChange();
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    decoration: BoxDecoration(
                      color: _selectedType == DeliveryType.instant
                          ? AppColors.primaryLight
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedType == DeliveryType.instant
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: _selectedType == DeliveryType.instant ? 1.8 : 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          color: _selectedType == DeliveryType.instant
                              ? AppColors.primaryDark
                              : AppColors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Instant Delivery',
                          style: AppTextStyles.bodySemiBold.copyWith(
                            fontSize: 13,
                            color: _selectedType == DeliveryType.instant
                                ? AppColors.primaryDark
                                : AppColors.slateDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '15–25 mins',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            color: _selectedType == DeliveryType.instant
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 2. Scheduled Delivery Button
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedType = DeliveryType.scheduled;
                    });
                    _notifyChange();
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    decoration: BoxDecoration(
                      color: _selectedType == DeliveryType.scheduled
                          ? AppColors.primaryLight
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedType == DeliveryType.scheduled
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: _selectedType == DeliveryType.scheduled ? 1.8 : 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: _selectedType == DeliveryType.scheduled
                              ? AppColors.primaryDark
                              : AppColors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Scheduled Delivery',
                          style: AppTextStyles.bodySemiBold.copyWith(
                            fontSize: 13,
                            color: _selectedType == DeliveryType.scheduled
                                ? AppColors.primaryDark
                                : AppColors.slateDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pick slot',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            color: _selectedType == DeliveryType.scheduled
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Scheduled Date & Slot Picker Details (expanded if Scheduled is chosen)
          if (_selectedType == DeliveryType.scheduled) ...[
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 10),

            // Date Selection
            Text(
              'Select Delivery Date',
              style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(3, (index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final isSelected = _selectedDate.day == date.day &&
                      _selectedDate.month == date.month &&
                      _selectedDate.year == date.year;
                  final dayLabel = index == 0
                      ? 'Today'
                      : index == 1
                          ? 'Tomorrow'
                          : 'In 2 Days';

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$dayLabel (${date.day}/${date.month})'),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.slateDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedDate = date;
                          });
                          _notifyChange();
                        }
                      },
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 12),

            // Time Slot Selection
            Text(
              'Select Time Slot',
              style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSlots.map((slot) {
                final isSelected = _selectedTimeSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  selectedColor: AppColors.primaryDark,
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.slateDark,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _selectedTimeSlot = slot;
                      });
                      _notifyChange();
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            // Delivery instructions field
            TextField(
              controller: _instructionsController,
              decoration: InputDecoration(
                hintText: 'Rider instructions (e.g. Gate 3 code 1234, ring bell)',
                hintStyle: AppTextStyles.caption.copyWith(fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                prefixIcon: const Icon(Icons.note_alt_outlined, size: 20, color: AppColors.textSecondary),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onChanged: (_) => _notifyChange(),
            ),
          ],
        ],
      ),
    );
  }
}
