import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cross_quick_share/widgets/custom_app_bar.dart';

class SettingsUI extends StatelessWidget {
  SettingsUI({super.key});

  final _ctx = Get.put(_SettingsCtx());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.widget(settings: false),
      body: Container(
        margin: EdgeInsets.only(left: 50, right: 50, top: 20, bottom: 20),
        child: ListView(
          children: [
            Card(
              child: Container(
                margin: EdgeInsets.all(15),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('设备名称', style: TextStyle(fontSize: 15)),
                        Obx(
                          () => Text(
                            _ctx.deviceName.value,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: SizedBox()),
                    TextButton(onPressed: () async {}, child: Text('重命名')),
                  ],
                ),
              ),
            ),
            Card(
              child: Container(
                margin: EdgeInsets.all(15),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('文件保存位置', style: TextStyle(fontSize: 15)),
                        Obx(
                          () => Text(
                            _ctx.fileSavePath.value,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: SizedBox()),
                    TextButton(onPressed: () async {}, child: Text('更改')),
                  ],
                ),
              ),
            ),
            Card(
              child: Container(
                margin: EdgeInsets.all(15),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('开机自动运行', style: TextStyle(fontSize: 15)),
                        Text(
                          '开机时自动运行 Cross Quick Share 服务',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    Expanded(child: SizedBox()),
                    Switch(
                      onChanged: (val) async {},
                      value: _ctx.autostart.value,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCtx extends GetxController {
  var deviceName = 'Test'.obs;
  var fileSavePath = 'C:/114514'.obs;

  var autostart = false.obs;
}
