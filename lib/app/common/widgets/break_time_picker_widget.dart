import 'package:flutter/material.dart';
import 'package:mh/app/common/utils/exports.dart';

class BreakTimePickerWidget extends StatefulWidget {
  final Function(int) onBreakTimeChanged;

  const BreakTimePickerWidget({Key? key, required this.onBreakTimeChanged});

  @override
  BreakTimePickerWidgetState createState() => BreakTimePickerWidgetState();
}

class BreakTimePickerWidgetState extends State<BreakTimePickerWidget> {
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;

  final List<String> _hoursList = List.generate(6, (int index) => index.toString());
  final List<String> _minutesList = List.generate(12, (int index) => (index * 5).toString());

  int _selectedHour = 0;
  int _selectedMinute = 0;

  @override
  void initState() {
    super.initState();

    _hoursController = FixedExtentScrollController(initialItem: _selectedHour);
    _minutesController = FixedExtentScrollController(initialItem: _selectedMinute ~/ 5);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  int _calculateTotalMinutes() {
    return _selectedHour * 60 + _selectedMinute;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          height: 200,
          child: Column(
            children: [
              Text('Hours', style: MyColors.l111111_dwhite(context).semiBold16),
              const SizedBox(height: 10),
              Expanded(
                child: _buildPicker(
                  controller: _hoursController,
                  items: _hoursList,
                  selectedIndex: _selectedHour,
                  onChanged: _onHourChanged,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: Column(
            children: [
              Text('Minutes', style: MyColors.l111111_dwhite(context).semiBold16),
              SizedBox(height: 10),
              Expanded(
                child: _buildPicker(
                  controller: _minutesController,
                  items: _minutesList,
                  selectedIndex: _selectedMinute ~/ 5,
                  onChanged: _onMinuteChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildPicker({
    required FixedExtentScrollController controller,
    required List<String> items,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
    circularScrolling = true,
  }) {
    return SizedBox(
      width: 100, // Adjust width as needed
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
                      ? TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)
                      : TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
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

  void _onHourChanged(int index) {
    setState(() {
      _selectedHour = index % _hoursList.length;
      widget.onBreakTimeChanged(_calculateTotalMinutes());
    });
  }

  void _onMinuteChanged(int index) {
    setState(() {
      _selectedMinute = (index % _minutesList.length) * 5;
      widget.onBreakTimeChanged(_calculateTotalMinutes());
    });
  }
}
