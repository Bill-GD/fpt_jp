import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:theme_provider/theme_provider.dart';

import 'data/repositories/about_repository.dart';
import 'ui/core/ui/action_dialog.dart';
import 'ui/core/ui/widget_error.dart';
import 'ui/home/view_model/home_view_model.dart';
import 'ui/home/widgets/home_screen.dart';
import 'utils/extensions/number_duration.dart';
import 'utils/handlers/database_handler.dart';
import 'utils/handlers/log_handler.dart';
import 'utils/helpers/globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Globals.storagePath = (await getExternalStorageDirectory())?.parent.path ?? '';
  Globals.logPath = '${Globals.storagePath}/files/log.txt';

  LogHandler.init();
  LogHandler.log('App version: ${Globals.appVersion}, isDev: ${Globals.isDev}');

  await DatabaseHandler.init();

  PlatformDispatcher.instance.onError = (e, s) {
    LogHandler.log(e.toString(), LogLevel.error);
    final curContext = Globals.navigatorKey.currentContext;
    if (curContext == null) return false;

    ActionDialog.static<void>(
      curContext,
      icon: Icon(
        Icons.error_rounded,
        color: Theme.of(curContext).colorScheme.error,
        size: 30,
      ),
      title: e.toString(),
      titleFontSize: 24,
      textContent: s.toString(),
      contentFontSize: 16,
      centerContent: false,
      time: 200.ms,
      actions: [
        TextButton(
          onPressed: Navigator.of(curContext).pop,
          child: const Text('OK'),
        ),
      ],
      horizontalPadding: 16,
      barrierDismissible: true,
      allowScroll: true,
    );
    return true;
  };

  runApp(FPTJapaneseApp(navKey: Globals.navigatorKey));
}

class FPTJapaneseApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navKey;

  const FPTJapaneseApp({super.key, required this.navKey});

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      saveThemesOnChange: true,
      loadThemeOnInit: true,
      defaultThemeId: '${SchedulerBinding.instance.platformDispatcher.platformBrightness.name}_theme',
      themes: [
        AppTheme(
          id: 'light_theme',
          description: 'Light theme',
          data: ThemeData(
            useMaterial3: true,
            fontFamily: 'Noto Sans Japanese',
            brightness: Brightness.light,
            sliderTheme: const SliderThemeData(
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.white,
              brightness: Brightness.light,
            ),
            //.copyWith(surface: Colors.white),
          ),
        ),
        AppTheme(
          id: 'dark_theme',
          description: 'Dark theme',
          data: ThemeData(
            useMaterial3: true,
            fontFamily: 'Noto Sans Japanese',
            brightness: Brightness.dark,
            sliderTheme: const SliderThemeData(
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.grey,
              brightness: Brightness.dark,
            ),
          ),
        ),
      ],
      child: ThemeConsumer(
        child: Builder(
          builder: (context) {
            return MaterialApp(
              navigatorKey: navKey,
              builder: (context, child) {
                ErrorWidget.builder = (errorDetails) => WidgetErrorScreen(e: errorDetails);
                return child!;
              },
              theme: ThemeProvider.themeOf(context).data,
              title: 'FPT JP',
              home: HomeScreen(viewModel: HomeViewModel(aboutRepo: AboutRepository())),
            );
          },
        ),
      ),
    );
  }
}
