import 'package:flutter/material.dart';
import 'package:fpt_jp/utils/extensions/number_duration.dart';

import '../../../data/repositories/vocab_repository.dart';
import '../../../domain/models/vocab.dart';
import '../../../utils/extensions/list.dart';
import '../../../utils/handlers/log_handler.dart';
import '../../core/styling/text.dart';
import '../../core/ui/action_dialog.dart';
import '../../core/ui/drawer.dart';

class VocabScreen extends StatefulWidget {
  final VocabRepository vocabRepo;

  const VocabScreen({super.key, required this.vocabRepo});

  @override
  State<VocabScreen> createState() => _VocabScreenState();
}

class _VocabScreenState extends State<VocabScreen> {
  List<Vocab> words = [];
  List<bool> isOpen = [];
  int currentlyOpened = -1, currentPage = 1, pageCount = 0, lowerBound = -1, upperBound = -1;
  bool isLoadingWords = true;

  @override
  void initState() {
    super.initState();
    updateWords();
  }

  Future<void> updateWords() async {
    setState(() => isLoadingWords = true);
    currentlyOpened = -1;
    pageCount = await widget.vocabRepo.getPageCount(lowerBound, upperBound);
    words = await widget.vocabRepo.getWords(lowerBound, upperBound, currentPage);
    isOpen = List<bool>.filled(words.length, false);
    LogHandler.log('Got ${words.length} vocab words');
    setState(() => isLoadingWords = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        centerTitle: true,
        actions: [
          Tooltip(
            message: 'Clear filter',
            child: IconButton(
              onPressed: () async {
                lowerBound = upperBound = -1;
                currentPage = 1;
                await updateWords();
              },
              icon: const Icon(Icons.filter_alt_off_rounded),
            ),
          ),
          Tooltip(
            message: 'Filter words',
            child: IconButton(
              onPressed: () async {
                final lowerControl = TextEditingController(), upperControl = TextEditingController();

                await ActionDialog.static(
                  context,
                  title: 'Filter vocabulary',
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
                          hintText: '100',
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
                            hintText: '300',
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
                        final lower = int.tryParse(lowerControl.text), upper = int.tryParse(upperControl.text);
                        if (lower != null && upper != null && lower <= upper) {
                          lowerBound = lower;
                          upperBound = upper;
                          currentPage = 1;
                          await updateWords();
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      child: const Text('Learn'),
                    ),
                  ],
                );
              },
              icon: const Icon(Icons.filter_alt_rounded),
            ),
          ),
          const EndDrawerButton(),
        ],
      ),
      endDrawer: const MainDrawer(),
      body: isLoadingWords
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ExpansionPanelList(
                expansionCallback: (index, isExpanded) async {
                  if (currentlyOpened >= 0) isOpen[currentlyOpened] = false;
                  words[index].extras = await widget.vocabRepo.getExtrasOf(words[index].id);
                  isOpen[index] = isExpanded;
                  currentlyOpened = index;
                  setState(() {});
                },
                expandedHeaderPadding: const EdgeInsets.all(0),
                children: words.mapIndexed((index, word) {
                  return ExpansionPanel(
                    canTapOnHeader: true,
                    isExpanded: isOpen[index],
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        leading: Text(
                          '${word.id}',
                          style: bodyTextStyle,
                        ),
                        title: Text(
                          '${word.word} ${word.meaning}',
                          style: titleTextStyle,
                        ),
                      );
                    },
                    body: word.extras.isEmpty
                        ? const Text(
                            'No extra vocabulary',
                            style: bodyTextStyle,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ...word.extras.map((e) {
                                return ListTile(
                                  leading: const Icon(Icons.arrow_right_alt_rounded),
                                  title: Text(
                                    '${e.content} ${e.meaning}',
                                    style: titleTextStyle,
                                  ),
                                );
                              })
                            ],
                          ),
                  );
                }),
              ),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: BorderDirectional(top: BorderSide(color: Theme.of(context).colorScheme.onSurface)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.keyboard_double_arrow_left_rounded),
              onPressed: currentPage <= 1
                  ? null
                  : () async {
                      currentPage = 1;
                      await updateWords();
                    },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: currentPage <= 1
                  ? null
                  : () async {
                      currentPage--;
                      await updateWords();
                    },
            ),
            if (isLoadingWords) const CircularProgressIndicator() else Text('Page $currentPage / $pageCount'),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: currentPage >= pageCount
                  ? null
                  : () async {
                      currentPage++;
                      await updateWords();
                    },
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_double_arrow_right_rounded),
              onPressed: currentPage >= pageCount
                  ? null
                  : () async {
                      currentPage = 1;
                      await updateWords();
                    },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add word',
        onPressed: () async {
          final numberControl = TextEditingController(),
              wordControl = TextEditingController(),
              meaningControl = TextEditingController();

          await ActionDialog.static(
            context,
            title: 'Add new word',
            titleFontSize: 18,
            widgetContent: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: numberControl,
                  keyboardType: TextInputType.number,
                  decoration: textFieldDecoration(
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: const OutlineInputBorder(),
                    labelText: 'Word number',
                    hintText: '100',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextField(
                    controller: wordControl,
                    keyboardType: TextInputType.text,
                    decoration: textFieldDecoration(
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: const OutlineInputBorder(),
                      labelText: 'Word',
                      hintText: 'としうえ',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextField(
                    controller: meaningControl,
                    keyboardType: TextInputType.text,
                    decoration: textFieldDecoration(
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: const OutlineInputBorder(),
                      labelText: 'Meaning',
                      hintText: 'người hơn tuổi',
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
                  final newId = int.tryParse(numberControl.text);
                  if (newId == null) {
                    return;
                  }

                  final newWord = Vocab(
                    id: newId,
                    word: wordControl.text,
                    meaning: meaningControl.text,
                  );
                  await widget.vocabRepo.insertVocab([newWord]);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
          await updateWords();
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
