import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../../utils/extensions/number_duration.dart';
import '../../../utils/handlers/log_handler.dart';
import '../../core/styling/text.dart';
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
  void didUpdateWidget(covariant KanjiLessonListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.viewModel.loadList.removeListener(onLoad);
    widget.viewModel.loadList.addListener(onLoad);
    widget.viewModel.loadList.execute();
  }

  void onLoad() {
    if (!widget.viewModel.loadList.running) {
      LogHandler.log('Got ${widget.viewModel.lessons.length} kanji lessons');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () async {
                widget.viewModel.loadList.execute();
              },
            ),
            const EndDrawerButton(),
          ],
          title: const Text('Kanji'),
          centerTitle: true,
        ),
        endDrawer: const MainDrawer(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('All lessons'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Lesson range'),
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
                        openBuilder: (context, action) {
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
                            onTap: () async {
                              await widget.viewModel.queueLesson.execute(lesson.lessonNum);
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
    );
  }
}
