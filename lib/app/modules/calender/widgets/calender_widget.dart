import 'package:intl/intl.dart';
import 'package:mh/app/common/utils/exports.dart';

class CalenderWidget extends StatefulWidget {
  const CalenderWidget({super.key});

  @override
  CalendarViewState createState() => CalendarViewState();
}

class CalendarViewState extends State<CalenderWidget> {
  final List<String> _dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  late PageController _pageController;
  int _currentPageIndex = 0;
  DateTime _selectedDate = DateTime.now();

  final Set<DateTime> _selectedDates = <DateTime>{};
  DateTime? _rangeStartDate;
  DateTime? _rangeEndDate;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildMonth(DateTime month) {
    final DateTime today = DateTime.now();
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final int firstDayWeekday = (DateTime(month.year, month.month, 1).weekday + 5) % 7 + 1;
    final int weeks = (daysInMonth + firstDayWeekday - 1) ~/ 7 + 1;

    return GridView.builder(
      itemCount: weeks * 7,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemBuilder: (context, index) {
        final int day = index + 1 - firstDayWeekday;
        if (day <= 0 || day > daysInMonth) {
          return Container();
        }
        final DateTime currentDate = DateTime(month.year, month.month, day);
        final bool isSelected = _selectedDates.contains(currentDate);
        final bool isInRange = _rangeStartDate != null &&
            _rangeEndDate != null &&
            currentDate.isAfter(_rangeStartDate!) &&
            currentDate.isBefore(_rangeEndDate!.add(const Duration(days: 1)));

        final bool isToday =
            currentDate.year == today.year && currentDate.month == today.month && currentDate.day == today.day;

        return GestureDetector(
          onTap: () {
            setState(() {
              if (_rangeStartDate == null || _rangeEndDate != null) {
                _rangeStartDate = currentDate;
                _rangeEndDate = null;
              } else if (_rangeStartDate != null && currentDate.isBefore(_rangeStartDate!)) {
                _rangeStartDate = currentDate;
              } else {
                _rangeEndDate = currentDate;
              }

              if (_selectedDates.contains(currentDate)) {
                _selectedDates.remove(currentDate);
              } else {
                _selectedDates.add(currentDate);
              }
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isSelected || isInRange || isToday ? MyColors.c_C6A34F : Colors.transparent),
              color: isToday ? Colors.transparent : (isSelected ? MyColors.c_C6A34F : null),
            ),
            child: Text(
              day.toString(),
              style: isSelected ? const TextStyle(color: Colors.white) : const TextStyle(color: Colors.black),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            DateFormat.yMMMM().format(_selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.grey.withOpacity(0.3),
                border: Border.all(color: Colors.grey.shade300)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                7,
                (index) => Text(
                  _dayNames[index],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                  _selectedDate = DateTime.now().add(Duration(days: index * 30));
                });
              },
              itemCount: 2,
              itemBuilder: (context, index) {
                final month = DateTime.now().add(Duration(days: index * 30));
                return _buildMonth(month);
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  decoration: BoxDecoration(
                      color: _selectedDate.month == DateTime.now().month ? Colors.blue : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(5.0)),
                  width: 30,
                  height: 5),
              const SizedBox(width: 10),
              Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                      color: _selectedDate.month != DateTime.now().month ? Colors.blue : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(5.0))),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: Get.width*0.6,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10.0),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: MyColors.c_C6A34F),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month, color: MyColors.white),
                  Text(' ${_selectedDates.length}', style: MyColors.white.semiBold24),
                  Text(' Days have been selected', style: MyColors.white.semiBold12),
                ],
              )),
        ],
      ),
    );
  }
}
