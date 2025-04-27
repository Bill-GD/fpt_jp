import 'package:flutter/material.dart';

import '../../data/repositories/kanji_repository.dart';
import '../../domain/models/kanji_word.dart';
import '../../utils/helpers/enums.dart';
import '../core/styling/text.dart';
import '../core/ui/drawer.dart';

class AddKanjiScreen extends StatefulWidget {
  final KanjiRepository kanjiRepo;
  final int lessonNum;

  const AddKanjiScreen({super.key, required this.kanjiRepo, required this.lessonNum});

  @override
  State<AddKanjiScreen> createState() => _AddKanjiScreenState();
}

class _AddKanjiScreenState extends State<AddKanjiScreen> {
  late List<TextEditingController> wordControllers, pronunciationControllers, sinoVietControllers, meaningControllers;
  bool isInserting = false;
  List<KanjiWord> words = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('It\'s recommended to use the editor instead.')),
        ));
    words.add(KanjiWord.empty(widget.lessonNum));
    updateControllers();
  }

  @override
  void dispose() {
    for (var controller in wordControllers) {
      controller.dispose();
    }
    for (var controller in pronunciationControllers) {
      controller.dispose();
    }
    for (var controller in sinoVietControllers) {
      controller.dispose();
    }
    for (var controller in meaningControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void updateControllers() {
    final wordList = words;
    wordControllers = wordList.map((word) => TextEditingController(text: word.word)).toList();
    pronunciationControllers = wordList.map((word) => TextEditingController(text: word.pronunciation)).toList();
    sinoVietControllers = wordList.map((word) => TextEditingController(text: word.sinoViet)).toList();
    meaningControllers = wordList.map((word) => TextEditingController(text: word.meaning)).toList();
  }

  Future<void> updateWord(int index, WordUpdateType type, String value) async {
    switch (type) {
      case WordUpdateType.word:
        words[index].word = value;
      case WordUpdateType.pronun:
        words[index].pronunciation = value;
      case WordUpdateType.meaning:
        words[index].meaning = value;
      case WordUpdateType.sino:
        words[index].sinoViet = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Kanji for lesson ${widget.lessonNum}'),
        centerTitle: true,
        actions: const [EndDrawerButton()],
      ),
      endDrawer: const MainDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: isInserting
                          ? null
                          : () {
                              words.add(KanjiWord.empty(widget.lessonNum));
                              updateControllers();
                            },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('New term'),
                    ),
                    OutlinedButton.icon(
                      onPressed: isInserting
                          ? null
                          : () async {
                              setState(() => isInserting = true);
                              await widget.kanjiRepo.insertKanji(words);
                              if (context.mounted) Navigator.pop(context);
                            },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  itemCount: words.length,
                  separatorBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Divider(height: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    );
                  },
                  itemBuilder: (context, index) {
                    final word = words[index], wordCount = words.length;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20, left: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${index + 1}',
                                style: titleTextStyle,
                              ),
                              Icon(word.isEmpty ? Icons.check_box_outline_blank_rounded : Icons.check_box_rounded),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextField(
                                controller: wordControllers[index],
                                readOnly: isInserting,
                                onChanged: (val) => updateWord(
                                  index,
                                  WordUpdateType.word,
                                  val,
                                ),
                                decoration: textFieldDecoration(
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  border: const OutlineInputBorder(),
                                  labelText: 'Kanji word',
                                  hintText: '起きる',
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: TextField(
                                  controller: pronunciationControllers[index],
                                  readOnly: isInserting,
                                  onChanged: (val) => updateWord(
                                    index,
                                    WordUpdateType.pronun,
                                    val,
                                  ),
                                  decoration: textFieldDecoration(
                                    fillColor: Theme.of(context).colorScheme.surface,
                                    border: const OutlineInputBorder(),
                                    labelText: 'Pronunciation',
                                    hintText: 'おきる',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: TextField(
                                  controller: sinoVietControllers[index],
                                  readOnly: isInserting,
                                  onChanged: (val) => updateWord(
                                    index,
                                    WordUpdateType.sino,
                                    val,
                                  ),
                                  decoration: textFieldDecoration(
                                    fillColor: Theme.of(context).colorScheme.surface,
                                    border: const OutlineInputBorder(),
                                    labelText: 'Sino Viet (Hán Việt)',
                                    hintText: 'KHỞI',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: TextField(
                                  controller: meaningControllers[index],
                                  readOnly: isInserting,
                                  onChanged: (val) => updateWord(
                                    index,
                                    WordUpdateType.meaning,
                                    val,
                                  ),
                                  decoration: textFieldDecoration(
                                    fillColor: Theme.of(context).colorScheme.surface,
                                    border: const OutlineInputBorder(),
                                    labelText: 'Meaning',
                                    hintText: 'Thức dậy',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: IconButton(
                            onPressed: wordCount <= 1 || isInserting
                                ? null
                                : () {
                                    words.removeAt(index);
                                    updateControllers();
                                  },
                            icon: const Icon(Icons.delete_forever_rounded),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
