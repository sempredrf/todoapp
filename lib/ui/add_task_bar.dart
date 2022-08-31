import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/controllers/task_controller.dart';
import 'package:todoapp/models/task.dart';
import 'package:todoapp/ui/theme.dart';
import 'package:todoapp/ui/widgets/button.dart';
import 'package:todoapp/ui/widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  String _startTime = DateFormat("hh:mm a").format(DateTime.now());
  String _endTime = DateFormat("hh:mm a")
      .format(DateTime.now().add(const Duration(hours: 1)));

  int _selectedRemind = 5;
  List<int> remindList = [
    5,
    10,
    15,
    20,
  ];

  String _selectedRepeat = "None";
  List<String> repeatList = [
    "None",
    "Daily",
    "Weekly",
    "Monthly",
  ];

  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(context),
      body: _taskForm(),
    );
  }

  _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Icon(
          Icons.chevron_left_outlined,
          size: 20,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: const [
        CircleAvatar(
          backgroundImage: AssetImage("assets/images/avatar.png"),
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }

  _taskForm() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Task",
              style: headingStyle,
            ),
            InputField(
              title: 'Title',
              hint: "Enter title here",
              controller: _titleController,
            ),
            InputField(
              title: 'Note',
              hint: "Enter your note",
              controller: _noteController,
            ),
            InputField(
              title: 'Date',
              hint: DateFormat.yMd().format(_selectedDate),
              widget: IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                color: Colors.grey,
                onPressed: () => _getDateFromUser(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    title: "Start Time",
                    hint: _startTime,
                    widget: IconButton(
                      icon: const Icon(
                        Icons.access_alarms_outlined,
                        color: Colors.grey,
                      ),
                      color: Colors.grey,
                      onPressed: () => _getTimeFromUser(isStartTime: true),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: InputField(
                    title: "End Time",
                    hint: _endTime,
                    widget: IconButton(
                      icon: const Icon(
                        Icons.access_alarms_outlined,
                        color: Colors.grey,
                      ),
                      color: Colors.grey,
                      onPressed: () => _getTimeFromUser(isStartTime: false),
                    ),
                  ),
                ),
              ],
            ),
            InputField(
              title: "Remind",
              hint: "$_selectedRemind minutes early",
              widget: DropdownButton(
                icon: const Icon(
                  Icons.keyboard_arrow_down_outlined,
                  color: Colors.grey,
                ),
                iconSize: 32,
                elevation: 4,
                style: subTitleStyle,
                underline: Container(height: 0),
                items: remindList
                    .map<DropdownMenuItem<String>>(
                        (int item) => DropdownMenuItem(
                              value: item.toString(),
                              child: Text(
                                "$item minutes early",
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ))
                    .toList(),
                onChanged: (String? item) {
                  setState(() {
                    _selectedRemind =
                        item != null ? int.parse(item) : _selectedRemind;
                  });
                },
              ),
            ),
            InputField(
              title: "Repeat",
              hint: _selectedRepeat,
              widget: DropdownButton(
                icon: const Icon(
                  Icons.keyboard_arrow_down_outlined,
                  color: Colors.grey,
                ),
                iconSize: 32,
                elevation: 4,
                style: subTitleStyle,
                underline: Container(height: 0),
                items: repeatList
                    .map<DropdownMenuItem<String>>(
                        (String item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ))
                    .toList(),
                onChanged: (String? item) {
                  setState(() {
                    _selectedRepeat = item ?? _selectedRepeat;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _colorSelection(),
                MyButton(label: "Create task", onTap: _validateDate),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _validateDate() {
    if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      Get.snackbar("Required", "All fields are required!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.red,
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
          ));
    } else {
      //add to database
      _addTaskToDb();

      Get.back();
    }
  }

  _colorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Color",
          style: titleStyle,
        ),
        const SizedBox(
          height: 8.0,
        ),
        Wrap(
          children: List<Widget>.generate(
            3,
            (int index) {
              return GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: index == 0
                        ? primaryClr
                        : index == 1
                            ? pinkClr
                            : yellowClr,
                    child: _selectedColor == index
                        ? const Icon(
                            Icons.done,
                            color: Colors.white,
                            size: 16,
                          )
                        : Container(),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedColor = index;
                  });
                },
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  _getDateFromUser() async {
    DateTime? pickerDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2099),
    );

    if (pickerDate != null) {
      setState(() {
        _selectedDate = pickerDate;
      });
    }
  }

  _getTimeFromUser({required bool isStartTime}) async {
    TimeOfDay? pickerTime = await _shoTimerPicker();

    if (pickerTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickerTime.format(context);
        } else {
          _endTime = pickerTime.format(context);
        }
      });
    }
  }

  _addTaskToDb() async {
    int? value = await _taskController.addTask(
      task: Task(
        title: _titleController.text,
        note: _noteController.text,
        date: DateFormat.yMd().format(_selectedDate),
        startTime: _startTime,
        endTime: _endTime,
        remind: _selectedRemind,
        repeat: _selectedRepeat,
        color: _selectedColor,
        isCompleted: 0,
      ),
    );

    debugPrint(value!.toString());
  }

  Future<TimeOfDay?> _shoTimerPicker() {
    return showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now(),
      ),
    );
  }
}
