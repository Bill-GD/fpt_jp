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

  @override
  void didUpdateWidget(covariant KanjiLessonScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.viewModel.toggleVisibility.removeListener(updateWidget);
    widget.viewModel.toggleVisibility.addListener(updateWidget);
    widget.viewModel.loadLesson.removeListener(updateWidget);
    widget.viewModel.loadLesson.addListener(updateWidget);
    widget.viewModel.loadLesson.execute();
  }

  void updateWidget() {
    if (mounted) setState(() {});
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
        body: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            if (widget.viewModel.loadLesson.running) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: widget.viewModel.words.length,
              itemBuilder: (context, index) {
                final word = widget.viewModel.words[index];
                return ListTile(
                  leading: Text('${index + 1}'),
                  title: Text(
                    widget.viewModel.wordsVisibility[index]
                        ? '${word.sinoViet} ${word.pronunciation} ${word.meaning}'
                        : word.word,
                    style: titleTextStyle.copyWith(fontSize: 24),
                  ),
                  onTap: () => widget.viewModel.toggleVisibility.execute(index),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
