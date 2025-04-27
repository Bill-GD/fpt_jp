import 'package:flutter/material.dart';
import 'package:fpt_jp/ui/core/styling/text.dart';
import 'package:fpt_jp/utils/extensions/list.dart';

import '../../data/repositories/kanji_repository.dart';
import '../../domain/models/kanji_word.dart';
import '../core/ui/drawer.dart';

class KanjiEditorScreen extends StatefulWidget {
  final KanjiRepository kanjiRepo;
  final int lessonNum;

  const KanjiEditorScreen({super.key, required this.kanjiRepo, required this.lessonNum});

  @override
  State<KanjiEditorScreen> createState() => _KanjiEditorScreenState();
}

class _KanjiEditorScreenState extends State<KanjiEditorScreen> {
  List<KanjiWord> words = [];
  bool isLoading = true, isEditingCell = false, isInserting = false;
  (int, int) editingCellCoord = (0, 0);
  final textEditController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadLesson();
  }

  Future<void> loadLesson() async {
    setState(() => isLoading = true);
    words = await widget.kanjiRepo.getKanjiOfLesson(widget.lessonNum, widget.lessonNum);
    setState(() => isLoading = false);
  }

  void updateWord() {
    final (wordIdx, cellIdx) = editingCellCoord;
    switch (cellIdx) {
      case 0:
        words[wordIdx].word = textEditController.text;
      case 1:
        words[wordIdx].pronunciation = textEditController.text;
      case 2:
        words[wordIdx].sinoViet = textEditController.text.toUpperCase();
      case 3:
        words[wordIdx].meaning = textEditController.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kanji Editor: Lesson ${widget.lessonNum}'),
        centerTitle: true,
        actions: [
          Tooltip(
            message: 'Submit',
            child: IconButton(
              onPressed: isInserting
                  ? null
                  : () async {
                      isEditingCell = false;
                      isInserting = true;
                      setState(() {});
                      // await widget.kanjiRepo.insertKanji(words);
                      // if (context.mounted) Navigator.pop(context);
                    },
              icon: const Icon(Icons.save_rounded),
            ),
          ),
          const EndDrawerButton(),
        ],
      ),
      endDrawer: const MainDrawer(),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Table(
                columnWidths: const {
                  0: FractionColumnWidth(0.15),
                  1: FractionColumnWidth(0.2),
                  2: FractionColumnWidth(0.25),
                  3: FlexColumnWidth(),
                },
                border: TableBorder.all(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                children: words.mapIndexed((wordIdx, w) {
                  return TableRow(
                    children: w.valuesList().mapIndexed((cellIdx, e) {
                      return TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: GestureDetector(
                          onTap: () {
                            if (isInserting) return;
                            textEditController.text = e;
                            editingCellCoord = (wordIdx, cellIdx);
                            setState(() => isEditingCell = true);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: isEditingCell && wordIdx == editingCellCoord.$1 && cellIdx == editingCellCoord.$2
                              ? TextField(
                                  onTap: () {},
                                  maxLines: null,
                                  autofocus: true,
                                  style: const TextStyle(fontSize: 20),
                                  decoration: textFieldDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                    border: InputBorder.none,
                                    suffixIcon: Tooltip(
                                      message: 'Confirm change',
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.check_rounded,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        onPressed: () {
                                          updateWord();
                                          setState(() => isEditingCell = false);
                                        },
                                      ),
                                    ),
                                  ),
                                  controller: textEditController,
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                  child: Text(
                                    e,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
