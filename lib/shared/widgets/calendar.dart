import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:universal_exam/shared/theme/colors.dart';
import 'package:universal_exam/shared/widgets/button.dart';

typedef void DateSelectedCallback(DateTime date);

class CustomCalendar extends StatefulWidget {
  final bool disableHolidays;
  final DateTime? minSelectableDate;
  final DateTime? maxSelectableDate;
  final bool doesReturn;
  final DateSelectedCallback? onDateSelected;
  final Map<DateTime, List<String>> initialEvents;

  const CustomCalendar({
    super.key,
    this.disableHolidays = false,
    this.minSelectableDate,
    this.maxSelectableDate,
    this.doesReturn = false,
    this.onDateSelected,
    this.initialEvents = const {},
  });

  @override
  _CustomCalendarState createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late CalendarFormat _calendarFormat;
  late Map<DateTime, List<String>> _examEvents;
  late List<String> _selectedEvents;
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _examEvents = widget.initialEvents;
    _selectedEvents = _examEvents[_normalizeDate(_selectedDay)] ?? [];
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _selectedEvents = _examEvents[_normalizeDate(selectedDay)] ?? [];
    });
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(_normalizeDate(selectedDay));
    }
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
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) =>
                    isSameDay(_selectedDay, _normalizeDate(day)),
                eventLoader: (day) => _examEvents[_normalizeDate(day)] ?? [],
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
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
                      'الامتحانات:',
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
                  'لا توجد امتحانات لهذا اليوم.',
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
                      widget.onDateSelected!(_normalizeDate(_selectedDay));
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
