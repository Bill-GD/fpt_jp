import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../../utils/extensions/number_duration.dart';
import '../../../utils/handlers/log_handler.dart';
import '../../core/styling/text.dart';
import '../../core/ui/action_dialog.dart';
import '../../core/ui/drawer.dart';
import '../view_model/kanji_view_model.dart';
import 'kanji_lesson_screen.dart';

class KanjiLessonListScreen extends StatefulWidget {
  final KanjiViewModel viewModel;

  const KanjiLessonListScreen({super.key, required this.viewModel});

  @override
  State<KanjiLessonListScreen> createState() => _KanjiLessonListScreenState();
}

class _KanjiLessonListScreenState extends State<KanjiLessonListScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadList.addListener(onLoad);
    widget.viewModel.loadList.execute();
  }

  @override
  void dispose() {
    widget.viewModel.loadList.removeListener(onLoad);
    super.dispose();
  }

  void onLoad() {
    if (!widget.viewModel.loadList.running) {
      LogHandler.log('Got ${widget.viewModel.lessons.length} kanji lessons');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Tooltip(
            message: 'Refresh the list',
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: widget.viewModel.loadList.execute,
            ),
          ),
          const EndDrawerButton(),
        ],
        title: const Text('Kanji'),
        centerTitle: true,
      ),
      endDrawer: const MainDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OpenContainer(
                    closedElevation: 0,
                    closedColor: Theme.of(context).colorScheme.surface,
                    openColor: Colors.transparent,
                    transitionDuration: 400.ms,
                    openBuilder: (context, _) {
                      return KanjiLessonScreen(viewModel: widget.viewModel);
                    },
                    closedBuilder: (context, action) {
                      return Tooltip(
                        message: 'Review all Kanji',
                        child: OutlinedButton(
                          onPressed: () async {
                            await widget.viewModel.queueLesson.execute((0, 0));
                            action();
                          },
                          child: const Text('All lessons'),
                        ),
                      );
                    },
                  ),
                  OpenContainer(
                    closedElevation: 0,
                    closedColor: Theme.of(context).colorScheme.surface,
                    openColor: Colors.transparent,
                    transitionDuration: 400.ms,
                    openBuilder: (context, _) {
                      return KanjiLessonScreen(viewModel: widget.viewModel);
                    },
                    closedBuilder: (context, action) {
                      final lowerControl = TextEditingController(), upperControl = TextEditingController();

                      return Tooltip(
                        message: 'Select range of lesson to review',
                        child: OutlinedButton(
                          onPressed: () async {
                            await ActionDialog.static(
                              context,
                              title: 'Create new lesson',
                              titleFontSize: 18,
                              widgetContent: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: lowerControl,
                                    keyboardType: TextInputType.number,
                                    decoration: textFieldDecoration(
                                      fillColor: Theme.of(context).colorScheme.surface,
                                      border: const OutlineInputBorder(),
                                      labelText: 'From',
                                      hintText: '1',
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: TextField(
                                      controller: upperControl,
                                      keyboardType: TextInputType.number,
                                      decoration: textFieldDecoration(
                                        fillColor: Theme.of(context).colorScheme.surface,
                                        border: const OutlineInputBorder(),
                                        labelText: 'To',
                                        hintText: '3',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              contentFontSize: 14,
                              time: 200.ms,
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    final lower = int.tryParse(lowerControl.text),
                                        upper = int.tryParse(upperControl.text);
                                    if (lower != null && upper != null && lower <= upper) {
                                      Navigator.pop(context);
                                      await widget.viewModel.queueLesson.execute((lower, upper));
                                      action();
                                    }
                                  },
                                  child: const Text('Learn'),
                                ),
                              ],
                            );
                          },
                          child: const Text('Lesson range'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, _) {
                if (widget.viewModel.loadList.running) {
                  return const CircularProgressIndicator();
                }

                if (widget.viewModel.lessons.isEmpty) {
                  return const Column(
                    children: [
                      Icon(Icons.folder_off_rounded),
                      Text('No lesson found'),
                    ],
                  );
                }

                return Flexible(
                  child: ListView.builder(
                    itemCount: widget.viewModel.lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = widget.viewModel.lessons[index];

                      return OpenContainer(
                        closedElevation: 0,
                        closedColor: Theme.of(context).colorScheme.surface,
                        openColor: Colors.transparent,
                        transitionDuration: 400.ms,
                        openBuilder: (context, _) {
                          return KanjiLessonScreen(viewModel: widget.viewModel);
                        },
                        closedBuilder: (context, action) {
                          return ListTile(
                            leading: Text(
                              '${lesson.lessonNum}',
                              style: titleTextStyle,
                            ),
                            title: Text('Lesson ${lesson.lessonNum}'),
                            subtitle: Text('${lesson.wordCount} words'),
                            trailing: PopupMenuButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  onTap: () => widget.viewModel.openAddKanji.execute(lesson.lessonNum),
                                  child: const Text('Add new Kanji'),
                                ),
                              ],
                              position: PopupMenuPosition.under,
                              child: const Icon(Icons.more_vert_rounded),
                            ),
                            onTap: () async {
                              await widget.viewModel.queueLesson.execute((lesson.lessonNum, lesson.lessonNum));
                              action();
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // floatingActionButtonAnimator: FloatingActionButtonAnimator(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = TextEditingController();
          await ActionDialog.static(
            context,
            title: 'Create new lesson',
            titleFontSize: 18,
            widgetContent: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: textFieldDecoration(
                fillColor: Theme.of(context).colorScheme.surface,
                border: const OutlineInputBorder(),
                labelText: 'Lesson number',
                hintText: '1',
              ),
            ),
            contentFontSize: 14,
            time: 200.ms,
            actions: [
              TextButton(
                onPressed: () {
                  final lessonNum = int.tryParse(controller.text);
                  if (lessonNum != null) {
                    Navigator.pop(context);
                    widget.viewModel.openAddKanji.execute(lessonNum);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
