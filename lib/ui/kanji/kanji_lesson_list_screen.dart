import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:fpt_jp/ui/kanji/kanji_editor_screen.dart';

import '../../data/repositories/kanji_repository.dart';
import '../../domain/models/kanji_lesson.dart';
import '../../utils/extensions/number_duration.dart';
import '../../utils/handlers/log_handler.dart';
import '../core/styling/text.dart';
import '../core/ui/action_dialog.dart';
import '../core/ui/drawer.dart';
import 'add_kanji_screen.dart';
import 'kanji_lesson_screen.dart';

class KanjiLessonListScreen extends StatefulWidget {
  final KanjiRepository kanjiRepo;

  const KanjiLessonListScreen({super.key, required this.kanjiRepo});

  @override
  State<KanjiLessonListScreen> createState() => _KanjiLessonListScreenState();
}

class _KanjiLessonListScreenState extends State<KanjiLessonListScreen> {
  List<KanjiLesson> lessons = [];
  bool isLoading = true;
  (int, int) lessonRange = (0, 0);

  @override
  void initState() {
    super.initState();
    loadList();
  }

  void loadList() async {
    setState(() => isLoading = true);
    lessons = await widget.kanjiRepo.getLessonList();
    setState(() => isLoading = false);
  }

  void queueLesson(int lower, int upper) {
    if (lower > upper) throw Exception('Starting lesson is higher than ending lesson');

    lessonRange = (lower, upper);
    if (lower == upper) {
      LogHandler.log(lower == 0 ? 'Queued all lessons' : 'Queued lesson: $lower');
    }

    LogHandler.log('Queued lessons: $lower - $upper');
  }

  void openAddKanji(int num) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) {
          return AddKanjiScreen(
            kanjiRepo: widget.kanjiRepo,
            lessonNum: num,
          );
        },
        transitionsBuilder: (context, anim1, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: const Offset(0, 0),
            ).animate(anim1.drive(CurveTween(curve: Curves.decelerate))),
            child: child,
          );
        },
      ),
    );
  }

  void openKanjiEditor(int num) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) {
          return KanjiEditorScreen(
            kanjiRepo: widget.kanjiRepo,
            lessonNum: num,
          );
        },
        transitionsBuilder: (context, anim1, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: const Offset(0, 0),
            ).animate(anim1.drive(CurveTween(curve: Curves.decelerate))),
            child: child,
          );
        },
      ),
    );
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
              onPressed: loadList,
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
                      return KanjiLessonScreen(
                        kanjiRepo: widget.kanjiRepo,
                        lessonRange: lessonRange,
                      );
                    },
                    closedBuilder: (context, action) {
                      return Tooltip(
                        message: 'Review all Kanji',
                        child: OutlinedButton(
                          onPressed: () {
                            queueLesson(0, 0);
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
                      return KanjiLessonScreen(
                        kanjiRepo: widget.kanjiRepo,
                        lessonRange: lessonRange,
                      );
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
                                    if (lower != null && upper != null) {
                                      Navigator.pop(context);
                                      queueLesson(lower, upper);
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
            Builder(
              builder: (context) {
                if (isLoading) return const CircularProgressIndicator();

                if (lessons.isEmpty) {
                  return const Column(
                    children: [
                      Icon(Icons.folder_off_rounded),
                      Text('No lesson found'),
                    ],
                  );
                }

                return Flexible(
                  child: ListView.builder(
                    itemCount: lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = lessons[index];

                      return OpenContainer(
                        closedElevation: 0,
                        closedColor: Theme.of(context).colorScheme.surface,
                        openColor: Colors.transparent,
                        transitionDuration: 400.ms,
                        openBuilder: (context, _) {
                          return KanjiLessonScreen(
                            kanjiRepo: widget.kanjiRepo,
                            lessonRange: lessonRange,
                          );
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
                                  onTap: () => openAddKanji(lesson.lessonNum),
                                  child: const Text('Add new Kanji'),
                                ),
                                PopupMenuItem(
                                  onTap: () => openKanjiEditor(lesson.lessonNum),
                                  child: const Text('Edit Kanji'),
                                ),
                              ],
                              position: PopupMenuPosition.under,
                              child: const Icon(Icons.more_vert_rounded),
                            ),
                            onTap: () async {
                              queueLesson(lesson.lessonNum, lesson.lessonNum);
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
                    openAddKanji(lessonNum);
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
