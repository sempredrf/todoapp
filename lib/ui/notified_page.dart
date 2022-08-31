import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:todoapp/ui/theme.dart';

class NotifiedPage extends StatelessWidget {
  final String payload;

  const NotifiedPage({Key? key, required this.payload}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var parsedPayload = json.decode(payload);
    final String title = parsedPayload['title'];
    final String note = parsedPayload['note'];

    return Scaffold(
      appBar: AppBar(
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
        title: Center(
          child: Text(
            title,
            style: subHeadingStyle,
          ),
        ),
      ),
      body: Center(
        child: Container(
          height: 400,
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Get.isDarkMode ? Colors.white : Colors.grey[400],
          ),
          child: Center(
            child: Text(
              note,
              style: titleStyle.copyWith(
                  color: Get.isDarkMode ? Colors.black : Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
