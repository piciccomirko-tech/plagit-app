import 'package:flutter/material.dart';

enum DateTimeType { hour, minute }

class TimerWheelWidget extends StatefulWidget {
  final TimeOfDay? initialTime;
  final double? height;
  final double? width;
  final TextStyle? normalTextStyle;
  final TextStyle? highlightedTextStyle;
  final double? spacing;
  final Color? centerHighlightColor;
  final Function(String time) onTimeChanged;

  const TimerWheelWidget({
    super.key,
    required this.onTimeChanged,
    this.initialTime,
    this.spacing,
    this.normalTextStyle,
    this.highlightedTextStyle,
    this.width,
    this.height,
    this.centerHighlightColor,
  });

  @override
  TimerWheelWidgetState createState() => TimerWheelWidgetState();
}

class TimerWheelWidgetState extends State<TimerWheelWidget> {
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  late FixedExtentScrollController _amPmController;

  final List<String> _hoursList = List.generate(24, (int index) => ((index % 12) + 1).toString().padLeft(2, '0'));
  final List<String> _minutesList = List.generate(60, (int index) => index.toString().padLeft(2, '0'));
  final List<String> _amPmList = ['AM', 'PM'];

  int _selectedHour = 0;
  int _selectedMinute = 0;
  int _selectedAmPm = 0;

  @override
  void initState() {
    super.initState();

    if (widget.initialTime != null) {
      _selectedHour = widget.initialTime!.hour - 1;
      _selectedMinute = widget.initialTime!.minute;
      _selectedAmPm = widget.initialTime!.period == DayPeriod.am ? 0 : 1;
    } else {
      // Use the current time if initialTime is not provided
      final currentTime = TimeOfDay.now();
      _selectedHour = currentTime.hour - 1;
      _selectedMinute = currentTime.minute;
      _selectedAmPm = currentTime.period == DayPeriod.am ? 0 : 1;
    }

    _hoursController = FixedExtentScrollController(initialItem: _selectedHour);
    _minutesController = FixedExtentScrollController(initialItem: (_selectedHour * 60) + _selectedMinute);
    _amPmController = FixedExtentScrollController(initialItem: _selectedAmPm);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _amPmController.dispose();
    super.dispose();
  }

  String _getFormattedTime() {
    final hour = (_selectedHour % 12) + 1;
    final minute = int.parse(_minutesList[_selectedMinute]);
    final amPm = _amPmList[_selectedAmPm];
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 200,
      width: widget.width ?? double.infinity,
      child: Stack(
        children: [
          IgnorePointer(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: widget.centerHighlightColor,
                ),
                height: 30,
                width: widget.width ?? double.infinity,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildPicker(
                  controller: _hoursController,
                  items: _hoursList,
                  selectedIndex: _selectedHour,
                  onChanged: _onHourChanged,
                  type: DateTimeType.hour,
                ),
              ),
              SizedBox(width: widget.spacing ?? 0),
              Expanded(
                child: _buildPicker(
                  controller: _minutesController,
                  items: _minutesList,
                  selectedIndex: _selectedMinute,
                  onChanged: _onMinuteChanged,
                  type: DateTimeType.minute,
                ),
              ),
              SizedBox(width: widget.spacing ?? 0),
              Expanded(
                child: _buildPicker2(_amPmController, _amPmList, _selectedAmPm, _onAmPmChanged),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPicker({
    required FixedExtentScrollController controller,
    required List<String> items,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
    required DateTimeType type,
    circularScrolling = true,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 30,
        physics: const FixedExtentScrollPhysics(),
        perspective: 0.005,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (BuildContext context, int index) {
            var itemIndex = index % items.length;
            final isSelected = itemIndex == selectedIndex;
            final color = isSelected ? Colors.black : Colors.grey;
            final item = items[itemIndex];

            return Container(
              color: isSelected ? Colors.transparent : Colors.transparent,
              child: Center(
                child: Text(
                  item,
                  style: itemIndex == (selectedIndex % items.length)
                      ? widget.highlightedTextStyle ??
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)
                      : widget.normalTextStyle ?? TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            );
          },
        ),
        onSelectedItemChanged: onChanged,
        clipBehavior: circularScrolling ? Clip.hardEdge : Clip.none,
      ),
    );
  }

  Widget _buildPicker2(
    FixedExtentScrollController controller,
    List<String> items,
    int selectedIndex,
    ValueChanged<int> onChanged, {
    bool circularScrolling = true,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 30,
        physics: const FixedExtentScrollPhysics(),
        perspective: 0.008,
        useMagnifier: true,
        magnification: 1.2,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length,
          builder: (BuildContext context, int index) {
            int itemIndex = index;
            final isSelected = itemIndex == selectedIndex;
            final color = isSelected ? Colors.black : Colors.grey;
            final item = items[itemIndex];
            return Center(
              child: Text(
                item,
                style: index == selectedIndex
                    ? widget.highlightedTextStyle ?? TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)
                    : widget.normalTextStyle ?? TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
              ),
            );
          },
        ),
        onSelectedItemChanged: onChanged,
        clipBehavior: circularScrolling ? Clip.hardEdge : Clip.none,
      ),
    );
  }

  void _onHourChanged(int index) {
    setState(() {
      _selectedHour = index % _hoursList.length;
      if (index % 24 >= 12) {
        _amPmController.jumpToItem(1);
      } else {
        _amPmController.jumpToItem(0);
      }
      widget.onTimeChanged(_getFormattedTime());
    });
  }

  void _onMinuteChanged(int index) {
    _selectedMinute = index % _minutesList.length;
    setState(() {});
    widget.onTimeChanged(_getFormattedTime());
  }

  void _onAmPmChanged(int index) {
    setState(() {
      _selectedAmPm = index % _amPmList.length;
      widget.onTimeChanged(_getFormattedTime());
    });
  }
}
