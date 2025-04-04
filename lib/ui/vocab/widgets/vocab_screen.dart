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
  int currentlyOpened = -1;
  bool isLoadingWords = true;

  @override
  void initState() {
    super.initState();
    updateWords();
  }

  Future<void> updateWords([int from = -1, int to = -1]) async {
    setState(() => isLoadingWords = true);
    currentlyOpened = -1;
    words = from < 0 || to < 0 ? await widget.vocabRepo.getAllWords() : await widget.vocabRepo.getWordRange(from, to);
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
                          await updateWords(lower, upper);
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
    );
  }
}
