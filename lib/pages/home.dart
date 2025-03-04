import 'package:cross_quick_share/storages/settings_prefs.dart';
import 'package:cross_quick_share/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final SettingsPrefs _settings = SettingsPrefs();

class HomeUI extends StatelessWidget {
  HomeUI({super.key});

  final _ctx = Get.put(_HomeCtx());

  @override
  Widget build(BuildContext context) {
    _ctx.load();
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
                          value: VisibilityEnum.visible.value,
                          label: VisibilityEnum.visible.text,
                        ),
                        DropdownMenuEntry(
                          value: VisibilityEnum.invisible.value,
                          label: VisibilityEnum.invisible.text,
                        ),
                      ],
                      onSelected: (val) async {
                        _ctx.visibility.value = val ?? '';
                        switch (val) {
                          case 'invisible':
                            _settings.setVisibility(0);
                          case 'visible':
                            _settings.setVisibility(1);
                        }
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Obx(
                          () => Visibility(
                            visible:
                                _ctx.visibility.value ==
                                VisibilityEnum.visible.value,
                            child: Text('附近的所有人都可以与您共享内容。'),
                          ),
                        ),
                        Obx(
                          () => Visibility(
                            visible:
                                _ctx.visibility.value ==
                                VisibilityEnum.invisible.value,
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

enum VisibilityEnum {
  visible("visible", "接受所有人分享的内容"),
  invisible("invisible", "设备已隐藏");

  const VisibilityEnum(this.value, this.text);

  final String value;
  final String text;
}

class _HomeCtx extends GetxController {
  TextEditingController visibilitySelector = TextEditingController(text: '');

  var visibility = ''.obs;

  void load() async {
    switch (await _settings.getVisibility()) {
      case 0:
        visibility.value = VisibilityEnum.invisible.value;
        visibilitySelector.text = VisibilityEnum.invisible.text;
      case 1:
        visibility.value = VisibilityEnum.visible.value;
        visibilitySelector.text = VisibilityEnum.visible.text;
    }
  }
}
