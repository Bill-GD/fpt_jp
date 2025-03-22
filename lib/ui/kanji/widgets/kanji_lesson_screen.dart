import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../utils/extensions/number_duration.dart';
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
  late AnimationController flipController;

  @override
  void initState() {
    super.initState();
    widget.viewModel.toggleVisibility.addListener(onVisibilityToggled);
    widget.viewModel.loadLesson.addListener(updateWidget);
    widget.viewModel.loadLesson.execute();
  }

  void onVisibilityToggled() {
    flipController.reverse().then((_) => flipController.forward());
    updateWidget();
  }

  void updateWidget() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.viewModel.toggleVisibility.removeListener(onVisibilityToggled);
    widget.viewModel.loadLesson.removeListener(updateWidget);
    widget.viewModel.resetWordIndex.execute();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [EndDrawerButton()],
        title: Text(
          widget.viewModel.isMultiLesson
              ? 'Lesson ${widget.viewModel.lessonRange.$1} - ${widget.viewModel.lessonRange.$2}'
              : widget.viewModel.currentLessonNum > 0
                  ? 'Lesson ${widget.viewModel.currentLessonNum}'
                  : 'All Kanji',
        ),
        centerTitle: true,
      ),
      endDrawer: const MainDrawer(),
      body: SafeArea(
        child: Center(
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              if (widget.viewModel.loadLesson.running || widget.viewModel.words.isEmpty) {
                return const CircularProgressIndicator();
              }

              final index = widget.viewModel.currentWordIndex,
                  wordCount = widget.viewModel.words.length,
                  word = widget.viewModel.words[index],
                  boxSize = max(MediaQuery.of(context).size.height * 0.75, 400.0);

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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints.loose(Size.square(boxSize)),
                      child: Text(
                        widget.viewModel.isWordVisible
                            ? '${word.sinoViet}\n${word.pronunciation}\n${word.meaning}'
                            : word.word,
                        style: titleTextStyle.copyWith(fontSize: widget.viewModel.isWordVisible ? 24 : 32),
                        textAlign: TextAlign.center,
                      ),
                    ).flipInX(
                      duration: 150.ms,
                      manualTrigger: true,
                      curve: Curves.bounceInOut,
                      controller: (p0) => flipController = p0..forward(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_double_arrow_left_rounded),
                        onPressed: index <= 0 ? null : widget.viewModel.toFirst.execute,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: index <= 0 ? null : widget.viewModel.prevWord.execute,
                      ),
                      IconButton(
                        icon: const Icon(Icons.shuffle),
                        onPressed: widget.viewModel.shuffleWords.execute,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        onPressed: index >= wordCount - 1 //
                            ? null
                            : widget.viewModel.nextWord.execute,
                      ),
                      IconButton(
                        icon: const Icon(Icons.keyboard_double_arrow_right_rounded),
                        onPressed: index >= wordCount - 1 ? null : widget.viewModel.toLast.execute,
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
