import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar {
  static AppBar widget({bool settings = true}) {
    return AppBar(
      title: Text('Cross Quick Share'),
      actions: [
        settings
            ? IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Get.toNamed('/settings');
              },
            )
            : Container(),
      ],
    );
  }
}
