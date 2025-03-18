import 'package:flutter/material.dart';

import '../../../utils/extensions/number_duration.dart';
import '../../../utils/helpers/globals.dart';
import '../../core/styling/text.dart';
import '../../core/ui/action_dialog.dart';
import '../../core/ui/drawer.dart';
import '../view_model/home_view_model.dart';

class HomeScreen extends StatefulWidget {
  final HomeViewModel viewModel;

  const HomeScreen({super.key, required this.viewModel});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load.addListener(() {
      if (widget.viewModel.shouldShowNewVersion) {
        ActionDialog.static<void>(
          context,
          title: 'New version available',
          titleFontSize: titleTextStyle.fontSize!,
          textContent: 'Current version: v${Globals.appVersion}\n'
              'New version: v${widget.viewModel.newestVersion}\n\n'
              'Check the about page for more details.',
          contentFontSize: bodyTextStyle.fontSize!,
          time: 200.ms,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const DrawerButton(),
          title: const Text('Review FPT Japanese'),
          centerTitle: true,
        ),
        drawer: const MainDrawer(),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => widget.viewModel.openKanji.execute(context),
                child: const Text('Kanji'),
              ),
              OutlinedButton(
                onPressed: () => widget.viewModel.openVocab.execute(context),
                child: const Text('Vocabulary'),
              ),
              OutlinedButton(
                onPressed: () => widget.viewModel.openGrammar.execute(context),
                child: const Text('Grammar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
