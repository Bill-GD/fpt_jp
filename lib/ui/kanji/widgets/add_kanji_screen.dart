import 'package:flutter/material.dart';

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
        title: const Text('Add Kanji'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: () {},
          ),
          const EndDrawerButton(),
        ],
      ),
      endDrawer: const MainDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: textFieldDecoration(
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: const OutlineInputBorder(),
                    labelText: 'Lesson number',
                    hintText: '1',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextField(
                  keyboardType: TextInputType.text,
                  decoration: textFieldDecoration(
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: const OutlineInputBorder(),
                    labelText: 'Kanji word',
                    hintText: '起きる',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextField(
                  keyboardType: TextInputType.text,
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
                  keyboardType: TextInputType.text,
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
                  keyboardType: TextInputType.text,
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
      ),
    );
  }
}
