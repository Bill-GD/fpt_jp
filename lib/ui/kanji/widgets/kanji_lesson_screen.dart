import 'package:flutter/material.dart';

import '../../core/styling/text.dart';
import '../../core/ui/drawer.dart';
import '../view_model/kanji_view_model.dart';

class KanjiLessonScreen extends StatefulWidget {
  final KanjiViewModel viewModel;

  const KanjiLessonScreen({super.key, required this.viewModel});

  @override
  State<KanjiLessonScreen> createState() => _KanjiLessonScreenState();
}

class _KanjiLessonScreenState extends State<KanjiLessonScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.toggleVisibility.addListener(updateWidget);
    widget.viewModel.loadLesson.addListener(updateWidget);
    widget.viewModel.loadLesson.execute();
  }

  void updateWidget() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.viewModel.toggleVisibility.removeListener(updateWidget);
    widget.viewModel.loadLesson.removeListener(updateWidget);
    widget.viewModel.resetWordIndex.execute();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: const [EndDrawerButton()],
          title: Text('Lesson ${widget.viewModel.currentLessonNum}'),
          centerTitle: true,
        ),
        endDrawer: const MainDrawer(),
        body: Center(
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              if (widget.viewModel.loadLesson.running) {
                return const CircularProgressIndicator();
              }

              final index = widget.viewModel.currentWordIndex,
                  wordCount = widget.viewModel.words.length,
                  word = widget.viewModel.words[index];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${index + 1} / $wordCount',
                    style: titleTextStyle,
                  ),
                  GestureDetector(
                    onTap: widget.viewModel.toggleVisibility.execute,
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHigh,
                        border: Border.fromBorderSide(BorderSide(
                          width: 2,
                          color: Theme.of(context).colorScheme.onSurface,
                        )),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                      constraints: BoxConstraints.loose(const Size(400, 400)),
                      child: Text(
                        widget.viewModel.isWordVisible
                            ? '${word.sinoViet}\n${word.pronunciation}\n${word.meaning}'
                            : word.word,
                        style: titleTextStyle.copyWith(fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: index == 0 ? null : widget.viewModel.prevWord.execute,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        onPressed: index >= wordCount - 1 //
                            ? null
                            : widget.viewModel.nextWord.execute,
                      ),
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
