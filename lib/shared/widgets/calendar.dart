import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/colors.dart';
import 'button.dart';

class CustomCalendar extends StatefulWidget {
  final Map<DateTime, List<String>> events;
  final bool disableHolidays;
  final DateTime? minSelectableDate;
  final DateTime? maxSelectableDate;
  final bool doesReturn;
  final ValueChanged<DateTime>? onDateSelected;

  const CustomCalendar({
    super.key,
    required this.events,
    this.disableHolidays = false,
    this.minSelectableDate,
    this.maxSelectableDate,
    this.doesReturn = false,
    this.onDateSelected,
  });

  @override
  _CustomCalendarState createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late Map<DateTime, List<String>> _normalizedEvents;
  late List<String> _selectedEvents;

  DateTime _selectedDay = _normalizeDate(DateTime.now());

  @override
  void initState() {
    super.initState();
    _normalizedEvents = _normalizeEventDates(widget.events);
    _selectedEvents = _normalizedEvents[_selectedDay] ?? [];
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day)
        .add(const Duration(hours: 3));
  }

  Map<DateTime, List<String>> _normalizeEventDates(
      Map<DateTime, List<String>> events) {
    final Map<DateTime, List<String>> normalized = {};
    events.forEach((date, eventList) {
      final normalizedDate = _normalizeDate(date);
      normalized[normalizedDate] = List.from(eventList);
    });
    return normalized;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = _normalizeDate(selectedDay);
      _selectedEvents = _normalizedEvents[_selectedDay] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = screenWidth < 800 ? screenWidth : screenWidth / 2.5;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: Container(
        width: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.lightSecondary,
              AppColors.highlight,
              AppColors.lightSecondary
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'التقويم',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.black),
              ),
              const Divider(),
              TableCalendar(
                firstDay: widget.minSelectableDate ?? DateTime(2025),
                lastDay: widget.maxSelectableDate ?? DateTime(2100),
                focusedDay: _selectedDay,
                selectedDayPredicate: (day) =>
                    isSameDay(_selectedDay, _normalizeDate(day)),
                eventLoader: (day) =>
                    _normalizedEvents[_normalizeDate(day)] ?? [],
                onDaySelected: _onDaySelected,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.highlight,
                        AppColors.highlight,
                        AppColors.lightSecondary,
                        AppColors.highlight
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.lightPrimary,
                        AppColors.primary
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: AppColors.darkPrimary,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: Colors.black),
                  holidayTextStyle: widget.disableHolidays
                      ? TextStyle(color: Colors.transparent)
                      : TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedEvents.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الأحداث:',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    ..._selectedEvents.map(
                      (event) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          '- $event',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_selectedEvents.isEmpty)
                Text(
                  'لا توجد أحداث لهذا اليوم.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black),
                ),
              if (widget.doesReturn)
                CustomButton(
                  text: 'إرجاع التاريخ',
                  onPressed: () {
                    if (widget.onDateSelected != null) {
                      widget.onDateSelected!(_selectedDay);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
