import 'package:flutter/material.dart';

class BirthdatePicker extends StatefulWidget {
  final Function(DateTime?) onDateSelected;
  
  const BirthdatePicker({
    super.key,
    required this.onDateSelected,
  });

  @override
  State<BirthdatePicker> createState() => _BirthdatePickerState();
}

class _BirthdatePickerState extends State<BirthdatePicker> {
  int? selectedMonth;
  int? selectedDay;
  int? selectedYear;
  
  final List<String> months = [
    'Month', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  
  List<int> getDaysInMonth() {
    if (selectedMonth == null) return List.generate(31, (i) => i + 1);
    
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    int days = daysInMonth[selectedMonth! - 1];
    
    // Leap year check
    if (selectedMonth == 2 && selectedYear != null) {
      bool isLeapYear = (selectedYear! % 4 == 0 && selectedYear! % 100 != 0) || (selectedYear! % 400 == 0);
      if (isLeapYear) days = 29;
    }
    
    return List.generate(days, (i) => i + 1);
  }
  
  List<int> getYears() {
    int currentYear = DateTime.now().year;
    return List.generate(120, (i) => currentYear - i);
  }
  
  void updateDate() {
    if (selectedMonth != null && selectedDay != null && selectedYear != null) {
      try {
        final date = DateTime(selectedYear!, selectedMonth!, selectedDay!);
        widget.onDateSelected(date);
      } catch (e) {
        widget.onDateSelected(null);
      }
    } else {
      widget.onDateSelected(null);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Birthdate',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  value: selectedMonth,
                  items: List.generate(months.length, (i) {
                    return DropdownMenuItem<int>(
                      value: i == 0 ? null : i,
                      child: Text(
                        months[i],
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }),
                  hint: 'Month',
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value;
                      // Reset day when month changes
                      if (selectedDay != null && selectedDay! > getDaysInMonth().length) {
                        selectedDay = null;
                      }
                      updateDate();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  value: selectedDay,
                  items: getDaysInMonth().map((day) {
                    return DropdownMenuItem<int>(
                      value: day,
                      child: Text(
                        day.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  hint: 'Day',
                  onChanged: (value) {
                    setState(() {
                      selectedDay = value;
                      updateDate();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  value: selectedYear,
                  items: getYears().map((year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(
                        year.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  hint: 'Year',
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value;
                      // Reset day if invalid for new year (leap year)
                      if (selectedDay != null && selectedDay! > getDaysInMonth().length) {
                        selectedDay = null;
                      }
                      updateDate();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required String hint,
    required void Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F2128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey[600]),
          ),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          style: const TextStyle(color: Colors.white),
          dropdownColor: const Color(0xFF1F2128),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}