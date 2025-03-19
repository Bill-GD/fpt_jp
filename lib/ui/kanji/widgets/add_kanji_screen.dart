import 'package:flutter/material.dart';

import '../../../utils/helpers/enums.dart';
import '../../core/styling/text.dart';
import '../../core/ui/drawer.dart';
import '../view_model/add_kanji_view_model.dart';

class AddKanjiScreen extends StatefulWidget {
  final AddKanjiViewModel viewModel;

  const AddKanjiScreen({super.key, required this.viewModel});

  @override
  State<AddKanjiScreen> createState() => _AddKanjiScreenState();
}

class _AddKanjiScreenState extends State<AddKanjiScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Kanji for lesson ${widget.viewModel.lessonNum}'),
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
                      onPressed: widget.viewModel.addNewWord.execute,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('New term'),
                    ),
                    OutlinedButton.icon(
                      onPressed: widget.viewModel.insertWords.execute,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListenableBuilder(
                  listenable: widget.viewModel,
                  builder: (context, _) {
                    return ListView.separated(
                      itemCount: widget.viewModel.words.length,
                      separatorBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Divider(height: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        );
                      },
                      itemBuilder: (context, index) {
                        final word = widget.viewModel.words[index], wordCount = widget.viewModel.words.length;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 20, left: 8),
                              child: Text(
                                '${index + 1}',
                                style: titleTextStyle,
                              ),
                            ),
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: TextEditingController(text: word.word),
                                    onChanged: (val) => widget.viewModel.updateWord.execute((
                                      index,
                                      WordUpdateType.word,
                                      val,
                                    )),
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
                                      controller: TextEditingController(text: word.pronunciation),
                                      onChanged: (val) => widget.viewModel.updateWord.execute((
                                        index,
                                        WordUpdateType.pronun,
                                        val,
                                      )),
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
                                      controller: TextEditingController(text: word.sinoViet),
                                      onChanged: (val) => widget.viewModel.updateWord.execute((
                                        index,
                                        WordUpdateType.sino,
                                        val,
                                      )),
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
                                      controller: TextEditingController(text: word.meaning),
                                      onChanged: (val) => widget.viewModel.updateWord.execute((
                                        index,
                                        WordUpdateType.meaning,
                                        val,
                                      )),
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
                                onPressed: wordCount <= 1 ? null : () => widget.viewModel.removeWord.execute(index),
                                icon: const Icon(Icons.delete_forever_rounded),
                              ),
                            ),
                          ],
                        );
                      },
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
