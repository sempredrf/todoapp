import 'dart:convert';

import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/controllers/task_controller.dart';
import 'package:todoapp/models/task.dart';
import 'package:todoapp/services/notifications_services.dart';
import 'package:todoapp/services/theme_services.dart';
import 'package:todoapp/ui/add_task_bar.dart';
import 'package:todoapp/ui/theme.dart';
import 'package:todoapp/ui/widgets/button.dart';
import 'package:todoapp/ui/widgets/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _taskController = Get.put(TaskController());

  late AnimationController _controller;
  late NotifyHelper notifyHelper;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestPermissions();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: context.theme.backgroundColor,
      body: Column(children: [
        _addTaskBar(),
        _addDateBar(),
        const SizedBox(
          height: 16,
        ),
        _showTasks(),
      ]),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: _handleThemeOnTap,
        child: Icon(
          Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
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

  _addTaskBar() {
    return (Container(
      margin: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: subHeadingStyle,
              ),
              Text(
                "Today",
                style: headingStyle,
              ),
            ],
          ),
          MyButton(label: "+ Add Task", onTap: _handleAddTaskOnTap),
        ],
      ),
    ));
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,
        dateTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        onDateChange: ((selectedDate) {
          setState(() {
            _selectedDate = selectedDate;
          });
        }),
      ),
    );
  }

  _showTasks() {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
          itemCount: _taskController.taskList.length,
          itemBuilder: (
            _,
            index,
          ) {
            Task task = _taskController.taskList[index];

            if ((task.repeat == 'Daily') ||
                (task.date == DateFormat.yMd().format(_selectedDate))) {
              DateTime date = DateFormat.jm().parse(task.startTime.toString());

              final String jsonTask = json.encode(task);

              notifyHelper.scheduledNotification(
                id: task.id!,
                title: task.title.toString(),
                body: task.note.toString(),
                payload: jsonTask,
                hours: date.hour,
                minutes: date.minute,
                seconds: 0,
              );

              return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showTaskBottomSheet(context, task),
                          child: TaskTile(
                            task: task,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
        );
      }),
    );
  }

  void _handleThemeOnTap() {
    ThemeServices().switchTheme();

    notifyHelper.displayNotification(
        title: "Theme changed",
        body:
            Get.isDarkMode ? "Activated Light Theme" : "Activated Dark Theme");
  }

  void _handleAddTaskOnTap() async {
    await Get.to(const AddTaskPage());

    _taskController.getTasks();
  }

  _showTaskBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.only(top: 4),
      height: task.isCompleted == 1
          ? MediaQuery.of(context).size.height * 0.24
          : MediaQuery.of(context).size.height * 0.32,
      color: Get.isDarkMode ? darkGreyClr : white,
      child: Column(
        children: [
          Container(
            height: 6,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
            ),
          ),
          const Spacer(),
          task.isCompleted == 1
              ? Container()
              : _bottomSheetButton(
                  label: "Task completed",
                  onTap: () => _handleOnTapTaskCompleted(task),
                  color: primaryClr,
                  context: context,
                ),
          _bottomSheetButton(
            label: "Delete task",
            onTap: () => _handleOnTapDeleteTask(task),
            color: pinkClr,
            context: context,
          ),
          _bottomSheetButton(
            label: "Close",
            onTap: () => Get.back(),
            color: primaryClr,
            context: context,
            isClose: true,
          ),
          const SizedBox(height: 10),
        ],
      ),
    ));
  }

  _bottomSheetButton(
      {required BuildContext context,
      required String label,
      required Function() onTap,
      required Color color,
      bool isClose = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: isClose ? context.theme.backgroundColor : color,
          border: Border.all(
            width: 2,
            color: isClose ? Colors.grey : color,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: isClose ? titleStyle : titleStyle.copyWith(color: white),
          ),
        ),
      ),
    );
  }

  void _handleOnTapTaskCompleted(Task task) {
    _taskController.completeTask(task);
    // _taskController.taskList.refresh();
    Get.back();
  }

  void _handleOnTapDeleteTask(Task task) {
    _taskController.delete(task);
    // _taskController.taskList.remove(task);
    Get.back();
  }
}
