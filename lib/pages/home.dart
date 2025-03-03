import 'package:cross_quick_share/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeUI extends StatelessWidget {
  HomeUI({super.key});

  final _ctx = Get.put(_HomeCtx());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.widget(),
      body: Container(
        margin: EdgeInsets.only(bottom: 20, right: 20),
        child: Row(
          children: [
            SizedBox(
              width:
                  MediaQuery.of(context).size.width > 900
                      ? MediaQuery.of(context).size.width * 0.3
                      : 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 15, top: 5),
                    child: DropdownMenu(
                      controller: _ctx.visibilitySelector,
                      width:
                          MediaQuery.of(context).size.width > 900
                              ? (MediaQuery.of(context).size.width * 0.3) - 30
                              : 270,
                      dropdownMenuEntries: [
                        DropdownMenuEntry(
                          value: 'visible',
                          label: '接受所有人分享的内容',
                        ),
                        DropdownMenuEntry(value: 'invisible', label: '设备已隐藏'),
                      ],
                      onSelected:
                          (val) async => _ctx.visibility.value = val ?? '',
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Obx(
                          () => Visibility(
                            visible: _ctx.visibility.value == 'visible',
                            child: Text('附近的所有人都可以与您共享内容。'),
                          ),
                        ),
                        Obx(
                          () => Visibility(
                            visible: _ctx.visibility.value == 'invisible',
                            child: Text('共享已关闭，所有人都无法向您发送内容。'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: Card(child: Column())),
          ],
        ),
      ),
    );
  }
}

class _HomeCtx extends GetxController {
  TextEditingController visibilitySelector = TextEditingController(text: '');

  var visibility = ''.obs;
}
