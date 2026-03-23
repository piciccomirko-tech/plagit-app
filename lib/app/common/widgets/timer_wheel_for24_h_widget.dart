import 'package:mh/app/common/utils/exports.dart';

enum DateTimeType { hour, minute, second }

class TimerWheel24HWidget extends StatefulWidget {
  final DateTime initialTime;
  final double? height;
  final double? width;
  final TextStyle? normalTextStyle;
  final TextStyle? highlightedTextStyle;
  final double? spacing;
  final Color? centerHighlightColor;
  final Function(String time) onTimeChanged;

  const TimerWheel24HWidget({
    super.key,
    required this.onTimeChanged,
    required this.initialTime,
    this.spacing,
    this.normalTextStyle,
    this.highlightedTextStyle,
    this.width,
    this.height,
    this.centerHighlightColor,
  });

  @override
  TimerWheel24HWidgetState createState() => TimerWheel24HWidgetState();
}

class TimerWheel24HWidgetState extends State<TimerWheel24HWidget> {
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  late FixedExtentScrollController _secondsController;

  final List<String> _hoursList = List.generate(24, (int index) => index.toString().padLeft(2, '0'));
  final List<String> _minutesList = List.generate(60, (int index) => index.toString().padLeft(2, '0'));
  final List<String> _secondsList = List.generate(60, (int index) => index.toString().padLeft(2, '0'));

  int _selectedHour = 0;
  int _selectedMinute = 0;
  int _selectedSecond = 0;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    _selectedSecond = widget.initialTime.second;

    _hoursController = FixedExtentScrollController(initialItem: _selectedHour);
    _minutesController = FixedExtentScrollController(initialItem: _selectedMinute);
    _secondsController = FixedExtentScrollController(initialItem: _selectedSecond);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  String _getFormattedTime() {
    final hour = int.parse(_hoursList[_selectedHour]);
    final minute = int.parse(_minutesList[_selectedMinute]);
    final second = int.parse(_secondsList[_selectedSecond]);
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 250, // Adjust height as needed
      width: widget.width ?? double.infinity,
      child: Stack(
        children: [
          IgnorePointer(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.only(top: 30),
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
                child:  _buildPicker(
                  title: 'Hours',
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
                  title: 'Minutes',
                  controller: _minutesController,
                  items: _minutesList,
                  selectedIndex: _selectedMinute,
                  onChanged: _onMinuteChanged,
                  type: DateTimeType.minute,
                ),
              ),
              SizedBox(width: widget.spacing ?? 0),
              Expanded(
                child: _buildPicker(
                  title: 'Seconds',
                  controller: _secondsController,
                  items: _secondsList,
                  selectedIndex: _selectedSecond,
                  onChanged: _onSecondChanged,
                  type: DateTimeType.second,
                ),
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
    required String title,
    required ValueChanged<int> onChanged,
    required DateTimeType type,
    circularScrolling = true,
  }) {
    return Column(
      children: [
        Text(title, style: MyColors.l111111_dwhite(Get.context!).semiBold16),
        const SizedBox(height: 10),
        Expanded(
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 30,
            physics: const FixedExtentScrollPhysics(),
            perspective: 0.005,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (BuildContext context, int index) {
                var itemIndex = index % items.length;
                final isSelected = itemIndex == selectedIndex;
                final color = isSelected ? MyColors.l111111_dwhite(Get.context!) : Colors.grey;
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
        ),
      ],
    );
  }

  void _onHourChanged(int index) {
    setState(() {
      _selectedHour = index % _hoursList.length;
      widget.onTimeChanged(_getFormattedTime());
    });
  }

  void _onMinuteChanged(int index) {
    setState(() {
      _selectedMinute = index % _minutesList.length;
      widget.onTimeChanged(_getFormattedTime());
    });
  }

  void _onSecondChanged(int index) {
    setState(() {
      _selectedSecond = index % _secondsList.length;
      widget.onTimeChanged(_getFormattedTime());
    });
  }
}
