import 'package:flutter/material.dart';

import '../../../data/repositories/vocab_repository.dart';
import '../../../domain/models/vocab.dart';
import '../../../domain/models/vocab_extra.dart';
import '../../../utils/extensions/list.dart';
import '../../../utils/handlers/log_handler.dart';
import '../../core/styling/text.dart';
import '../../core/ui/drawer.dart';

class VocabScreen extends StatefulWidget {
  final VocabRepository vocabRepo;

  const VocabScreen({super.key, required this.vocabRepo});

  @override
  State<VocabScreen> createState() => _VocabScreenState();
}

class _VocabScreenState extends State<VocabScreen> {
  List<Vocab> words = [];
  List<VocabExtra> extras = [];
  List<bool> isOpen = [];
  int currentlyOpened = -1;
  bool isLoadingWords = true, isLoadingExtras = true;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    widget.vocabRepo.getAllWords().then((words) {
      this.words = words;
      isOpen = List<bool>.filled(words.length, false);
      LogHandler.log('Got ${words.length} vocab words');
      setState(() => isLoadingWords = false);
    });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        centerTitle: true,
        actions: [
          Tooltip(
            message: 'Filter words',
            child: IconButton(
              onPressed: () {},
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
                  setState(() => isLoadingExtras = true);
                  extras = await widget.vocabRepo.getExtrasOf(index + 1);
                  isOpen[index] = isExpanded;
                  currentlyOpened = index;
                  setState(() => isLoadingExtras = false);
                },
                expandedHeaderPadding: const EdgeInsets.all(0),
                children: words.mapIndexed((index, word) {
                  return ExpansionPanel(
                    canTapOnHeader: true,
                    isExpanded: isOpen[index],
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        leading: Text(
                          '${index + 1}',
                          style: bodyTextStyle,
                        ),
                        title: Text(
                          '${word.word} ${word.meaning}',
                          style: titleTextStyle,
                        ),
                      );
                    },
                    body: isLoadingExtras
                        ? const Center(child: CircularProgressIndicator())
                        : extras.isEmpty
                            ? const Text(
                                'No extra vocabulary',
                                style: bodyTextStyle,
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: extras.map((e) {
                                  return ListTile(
                                    title: Text(
                                      '${e.content} ${e.meaning}',
                                      style: titleTextStyle,
                                    ),
                                  );
                                }).toList(),
                              ),
                  );
                }),
              ),
            ),
    );
  }
}
