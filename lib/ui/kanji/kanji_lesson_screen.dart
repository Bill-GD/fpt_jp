import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/kanji_repository.dart';
import '../../domain/models/kanji_word.dart';
import '../../utils/extensions/number_duration.dart';
import '../core/styling/text.dart';
import '../core/ui/drawer.dart';

class KanjiLessonScreen extends StatefulWidget {
  final KanjiRepository kanjiRepo;
  final (int, int) lessonRange;

  const KanjiLessonScreen({super.key, required this.kanjiRepo, required this.lessonRange});

  @override
  State<KanjiLessonScreen> createState() => _KanjiLessonScreenState();
}

class _KanjiLessonScreenState extends State<KanjiLessonScreen> {
  late AnimationController flipController;
  bool isLoading = true, asList = false, isWordVisible = false, isMultiLesson = false;
  List<KanjiWord> words = [];
  int currentLessonNum = -1, currentWordIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.lessonRange.$1 == widget.lessonRange.$2) {
      currentLessonNum = widget.lessonRange.$1;
      isMultiLesson = false;
    }
    isMultiLesson = true;
    loadLesson();
  }

  Future<void> loadLesson() async {
    setState(() => isLoading = true);
    words = await widget.kanjiRepo.getKanjiOfLesson(widget.lessonRange.$1, widget.lessonRange.$2);
    isWordVisible = false;
    setState(() => isLoading = false);
  }

  void toggleVisibility() {
    Future.delayed(150.ms, () => isWordVisible = !isWordVisible);
    flipController.reverse().then((_) => flipController.forward());
    setState(() {});
  }

  Future<void> nextWord() async {
    currentWordIndex++;
    isWordVisible = false;
  }

  Future<void> prevWord() async {
    currentWordIndex--;
    isWordVisible = false;
  }

  Future<void> toFirst() async {
    currentWordIndex = 0;
    isWordVisible = false;
  }

  Future<void> toLast() async {
    currentWordIndex = words.length - 1;
    isWordVisible = false;
  }

  Future<void> shuffleWords() async {
    currentWordIndex = 0;
    words.shuffle();
    isWordVisible = false;
  }

  Future<void> resetWordIndex() async {
    currentWordIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final index = currentWordIndex, wordCount = words.length;

        return Scaffold(
          appBar: AppBar(
            actions: [
              Tooltip(
                message: 'Show as ${asList ? 'card' : 'list'}',
                child: IconButton(
                  onPressed: () => setState(() => asList = !asList),
                  icon: Icon(asList ? Icons.file_copy : Icons.list),
                ),
              ),
              const EndDrawerButton(),
            ],
            title: Text(
              isMultiLesson
                  ? 'Lesson ${widget.lessonRange.$1} - ${widget.lessonRange.$2}'
                  : currentLessonNum > 0
                      ? 'Lesson $currentLessonNum'
                      : 'All Kanji',
            ),
            centerTitle: true,
            bottom: isLoading || asList || words.isEmpty
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(20),
                    child: Text(
                      '${index + 1} / $wordCount',
                      style: titleTextStyle,
                    ),
                  ),
          ),
          endDrawer: const MainDrawer(),
          body: Center(
            child: Builder(
              builder: (context) {
                if (isLoading || words.isEmpty) {
                  return const CircularProgressIndicator();
                }

                final word = words[index],
                    boxSize = min(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width) * 0.75;

                if (asList) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      itemCount: wordCount,
                      itemBuilder: (context, index) {
                        final word = words[index];
                        return ListTile(
                          leading: Text(
                            '${index + 1}',
                            style: titleTextStyle,
                          ),
                          title: Text(
                            word.word,
                            style: titleTextStyle.copyWith(fontSize: 32),
                          ),
                          subtitle: Text(
                            '${word.sinoViet} ${word.pronunciation} ${word.meaning}',
                            style: titleTextStyle.copyWith(fontSize: 24),
                          ),
                        );
                      },
                    ),
                  );
                }

                return GestureDetector(
                  onTap: toggleVisibility,
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
                      isWordVisible ? '${word.sinoViet}\n${word.pronunciation}\n${word.meaning}' : word.word,
                      style: titleTextStyle.copyWith(fontSize: isWordVisible ? 24 : 32),
                      textAlign: TextAlign.center,
                    ),
                  ).flipInX(
                    duration: 150.ms,
                    manualTrigger: true,
                    curve: Curves.bounceInOut,
                    controller: (p0) => flipController = p0..forward(),
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_double_arrow_left_rounded),
                  onPressed: index <= 0 ? null : toFirst,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: index <= 0 ? null : prevWord,
                ),
                IconButton(
                  icon: const Icon(Icons.shuffle),
                  onPressed: shuffleWords,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: index >= wordCount - 1 //
                      ? null
                      : nextWord,
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_double_arrow_right_rounded),
                  onPressed: index >= wordCount - 1 ? null : toLast,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
