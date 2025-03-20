import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../utils/extensions/number_duration.dart';
import '../../../utils/helpers/globals.dart';
import '../../about/view_model/about_view_model.dart';
import '../../about/widgets/about_screen.dart';
import '../styling/icon.dart';
import '../styling/text.dart';
import 'action_dialog.dart';
import 'list_item_divider.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(
                  children: [
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      leading: FaIcon(Icons.logo_dev, color: iconColor(context)),
                      title: const Text('Log', style: titleTextStyle),
                      onTap: () async {
                        final logLines = File(Globals.logPath).readAsLinesSync();
                        final contentLines = <String>[];

                        for (final line in logLines) {
                          if (line.isEmpty || !line.contains(']')) continue;

                          final isError = line.contains('[E]'), isWarn = line.contains('[W]');
                          final time = line.substring(0, line.indexOf(']') + 1).trim();
                          final content = line.substring(line.indexOf(']') + 5).trim();
                          // final content = line;
                          contentLines.add('t$time\n');
                          contentLines.add('${isError ? 'e' : isWarn ? 'w' : 'i'} - $content\n');
                          contentLines.add(' \n');
                        }
                        contentLines.removeLast();
                        contentLines.last = contentLines.last.substring(0, contentLines.last.length - 1);

                        final textSpans = <TextSpan>[];
                        for (var line in contentLines) {
                          final lineColor = switch (line[0]) {
                            'e' => Theme.of(context).colorScheme.error,
                            'w' => Colors.amber[700],
                            't' => Theme.of(context).colorScheme.secondary,
                            _ => Theme.of(context).textTheme.bodyMedium?.color,
                          };
                          textSpans.add(TextSpan(
                            text: line.substring(1),
                            style: TextStyle(color: lineColor),
                          ));
                        }

                        await ActionDialog.static<void>(
                          context,
                          title: 'Application log',
                          titleFontSize: 28,
                          widgetContent: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                              children: textSpans,
                            ),
                          ),
                          contentFontSize: 16,
                          centerContent: false,
                          horizontalPadding: 12,
                          time: 300.ms,
                          allowScroll: true,
                          actions: [
                            TextButton(
                              onPressed: Navigator.of(context).pop,
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    ),
                    const ListItemDivider(),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      leading: FaIcon(FontAwesomeIcons.gear, color: iconColor(context)),
                      title: const Text(
                        'About',
                        style: titleTextStyle,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) {
                              return AboutScreen(viewModel: AboutViewModel());
                            },
                            transitionsBuilder: (context, anim1, _, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: const Offset(0, 0),
                                ).animate(anim1.drive(CurveTween(curve: Curves.decelerate))),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
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
