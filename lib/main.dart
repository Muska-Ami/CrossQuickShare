import 'package:core/utils/generator.dart';
import 'package:cross_quick_share/pages/home.dart';
import 'package:cross_quick_share/pages/settings.dart';
import 'package:cross_quick_share/run.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsd/nsd.dart';

final service = Run();
Registration? registration;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final r4str = Generator.generateRandomString(4);
  registration = await service.startCast(r4str);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
}
