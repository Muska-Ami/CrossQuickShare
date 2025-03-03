import 'package:cross_quick_share/pages/home.dart';
import 'package:cross_quick_share/pages/settings.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ThemeData lightThemeData = ThemeData.light();
        ThemeData darkThemeData = ThemeData.dark();

        // Monet 取色
        if (lightDynamic != null && darkDynamic != null) {
          // 亮色模式 Monet 取色
          lightThemeData = ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: lightDynamic.harmonized(),
          );
          // 暗色模式 Monet 取色
          darkThemeData = ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: darkDynamic.harmonized(),
          );
        }

        return GetMaterialApp(
          title: 'Cross Quick Share',
          theme: lightThemeData,
          darkTheme: darkThemeData,
          routes: {
            '/': (context) => HomeUI(),
            '/settings': (context) => SettingsUI(),
          },
        );
      },
    );
  }

  // doCast() async {
  //   final Discover discover = Discover();
  //   final Register register = Register();
  //
  //   await register.register(
  //       Generator.generateServiceID('abcd'),
  //       Generator.generateServiceTXTData('Ami\'s PC Test', 3),
  //       11451,
  //   );
  //   await discover.start();
  //   await discover.addListener((Discovery discovery) {
  //     print(discovery);
  //   });
  // }
}
