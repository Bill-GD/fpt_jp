import 'package:flutter/material.dart';

import '../../../utils/handlers/log_handler.dart';
import '../../../utils/helpers/globals.dart';
import '../view_model/version_view_model.dart';

class VersionList extends StatefulWidget {
  final VersionViewModel viewModel;

  const VersionList({super.key, required this.viewModel});

  @override
  State<VersionList> createState() => _VersionListState();
}

class _VersionListState extends State<VersionList> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.getAllVersion.addListener(() {
      LogHandler.log('Got ${widget.viewModel.versionCount} tags');
      setState(() {});
    });
    widget.viewModel.getAllVersion.execute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Version list',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: widget.viewModel.getAllVersion.execute,
            child: widget.viewModel.getAllVersion.running
                ? const Center(child: CircularProgressIndicator())
                : widget.viewModel.versionCount <= 0
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_off_rounded),
                            Text('No version found'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: widget.viewModel.versionCount,
                        itemBuilder: (context, index) {
                          bool isDevBuild = widget.viewModel.tags[index].contains('_dev_');
                          return ListTile(
                            leading: widget.viewModel.tags[index] == 'v${Globals.appVersion}' //
                                ? const Icon(Icons.arrow_right_rounded)
                                : const Text(''),
                            title: Text(
                              widget.viewModel.tags[index],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text('${widget.viewModel.shas[index]} - ${isDevBuild ? 'dev' : 'stable'}'),
                            visualDensity: const VisualDensity(vertical: 3, horizontal: 4),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isDevBuild)
                                  IconButton(
                                    icon: const Icon(Icons.file_present_rounded),
                                    onPressed: () {
                                      widget.viewModel.getRelease.execute((
                                        context,
                                        widget.viewModel.tags[index],
                                        widget.viewModel.shas[index],
                                        false,
                                      ));
                                      // Navigator.of(context).push(RawDialogRoute(
                                      //   transitionDuration: 300.ms,
                                      //   barrierDismissible: true,
                                      //   barrierLabel: '',
                                      //   transitionBuilder: (_, anim1, __, child) {
                                      //     return ScaleTransition(
                                      //       scale: anim1.drive(CurveTween(curve: Curves.easeOutQuart)),
                                      //       alignment: Alignment.center,
                                      //       child: child,
                                      //     );
                                      //   },
                                      //   pageBuilder: (context, __, ___) {
                                      //     return VersionDialog(
                                      //       viewModel: VersionViewModel(aboutRepo: AboutRepository()),
                                      //       tag: widget.viewModel.tags[index],
                                      //       sha: widget.viewModel.shas[index],
                                      //     );
                                      //   },
                                      // ));
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.logo_dev_rounded),
                                  onPressed: () {
                                    widget.viewModel.getRelease.execute((
                                      context,
                                      widget.viewModel.tags[index],
                                      widget.viewModel.shas[index],
                                      true,
                                    ));
                                    // Navigator.of(context).push(RawDialogRoute(
                                    //   transitionDuration: 300.ms,
                                    //   barrierDismissible: true,
                                    //   barrierLabel: '',
                                    //   transitionBuilder: (_, anim1, __, child) {
                                    //     return ScaleTransition(
                                    //       scale: anim1.drive(CurveTween(curve: Curves.easeOutQuart)),
                                    //       alignment: Alignment.center,
                                    //       child: child,
                                    //     );
                                    //   },
                                    //   pageBuilder: (context, __, ___) {
                                    //     return VersionDialog(
                                    //       viewModel: VersionViewModel(aboutRepo: AboutRepository()),
                                    //       tag: widget.viewModel.tags[index],
                                    //       sha: widget.viewModel.shas[index],
                                    //       dev: true,
                                    //     );
                                    //   },
                                    // ));
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          );
        },
      ),
    );
  }
}
