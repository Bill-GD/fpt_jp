import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/repositories/kanji_repository.dart';
import '../../domain/models/kanji_word.dart';
import '../../utils/extensions/list.dart';
import '../../utils/extensions/number_duration.dart';
import '../../utils/helpers/dedent.dart';
import '../core/styling/text.dart';
import '../core/ui/action_dialog.dart';
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
  Set<int> editedWords = {};
  bool isLoading = true, isEditingCell = false, isInserting = false;
  (int, int) editingCellCoord = (0, 0);
  final textEditController = TextEditingController();
  late final int originalCount;

  @override
  void initState() {
    super.initState();
    loadLesson();
  }

  Future<void> loadLesson() async {
    setState(() => isLoading = true);
    words = await widget.kanjiRepo.getKanjiOfLesson(widget.lessonNum, widget.lessonNum);
    originalCount = words.length;
    setState(() => isLoading = false);
  }

  void updateWord() {
    final (wordIdx, cellIdx) = editingCellCoord;
    switch (cellIdx) {
      case 0:
        final newVal = textEditController.text.trim();
        if (newVal == words[wordIdx].word) return;
        words[wordIdx].word = newVal;
      case 1:
        final newVal = textEditController.text.trim();
        if (newVal == words[wordIdx].pronunciation) return;
        words[wordIdx].pronunciation = newVal;
      case 2:
        final newVal = textEditController.text.toUpperCase().trim();
        if (newVal == words[wordIdx].sinoViet) return;
        words[wordIdx].sinoViet = newVal;
      case 3:
        final newVal = textEditController.text.trim();
        if (newVal == words[wordIdx].meaning) return;
        words[wordIdx].meaning = newVal;
    }
    if (words[wordIdx].id >= 0) editedWords.add(words[wordIdx].id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kanji Editor: Lesson ${widget.lessonNum}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              ActionDialog.static(
                context,
                title: 'Help',
                titleFontSize: 20,
                textContent: dedent('''
                Press 'New row' to add new row, 'Submit' to save all changes.
                Click/Tap on table cell to edit, click/tap outside to save change. Use the 'X' button to cancel change.
                Row without enough data (empty) will be ignored (insert or update). No deletion available.
                A row must have the kanji, pronunciation, meaning. Else it's considered empty.
                '''),
                contentFontSize: 16,
                time: 300.ms,
              );
            },
          ),
          const EndDrawerButton(),
        ],
        forceMaterialTransparency: true,
      ),
      endDrawer: const MainDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: BorderDirectional(bottom: BorderSide(color: Theme.of(context).colorScheme.onSurface)),
              ),
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: isInserting
                        ? null
                        : () {
                            words.add(KanjiWord.empty(widget.lessonNum));
                            setState(() {});
                          },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('New row'),
                  ),
                  OutlinedButton.icon(
                    onPressed: isInserting
                        ? null
                        : () async {
                            isEditingCell = false;
                            isInserting = true;
                            setState(() {});
                            await widget.kanjiRepo.insertKanji(
                              words.sublist(originalCount).where((e) => !e.isEmpty).toList(),
                            );
                            await widget.kanjiRepo.updateKanji(
                              words.where((e) => editedWords.contains(e.id) && !e.isEmpty).toList(),
                            );
                            if (context.mounted) Navigator.pop(context);
                          },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Submit'),
                  ),
                ],
              ),
            ),
            Builder(
              builder: (context) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Flexible(
                  child: SingleChildScrollView(
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
                                        style: TextStyle(fontSize: Platform.isAndroid ? 16 : 20),
                                        onTapOutside: (event) {
                                          if (event.buttons == 1) {
                                            updateWord();
                                            setState(() => isEditingCell = false);
                                          }
                                        },
                                        decoration: textFieldDecoration(
                                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                          border: InputBorder.none,
                                          hintText: switch (cellIdx) {
                                            0 => '起きる',
                                            1 => 'おきる',
                                            2 => 'KHỞI',
                                            3 => 'Thức dậy',
                                            int() => throw UnimplementedError(),
                                          },
                                          suffixIcon: Tooltip(
                                            message: 'Cancel change',
                                            child: IconButton(
                                              iconSize: Platform.isAndroid ? 20 : null,
                                              icon: Icon(
                                                Icons.close_rounded,
                                                color: Theme.of(context).colorScheme.error,
                                              ),
                                              onPressed: () {
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
