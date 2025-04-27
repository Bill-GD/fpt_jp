import 'package:flutter/material.dart';

import '../../data/repositories/about_repository.dart';
import '../../utils/extensions/number_duration.dart';
import '../../utils/handlers/log_handler.dart';
import '../../utils/helpers/globals.dart';
import 'version_dialog.dart';

class VersionList extends StatefulWidget {
  final AboutRepository aboutRepo;

  const VersionList({super.key, required this.aboutRepo});

  @override
  State<VersionList> createState() => _VersionListState();
}

class _VersionListState extends State<VersionList> {
  List<String> tags = [], shas = [];
  int versionCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getAllVersions();
  }

  Future<void> getAllVersions() async {
    setState(() => isLoading = true);
    final result = await widget.aboutRepo.getAllTags();
    final list = result.reversed.toList();
    tags = list.map((e) => e.$1).toList();
    shas = list.map((e) => e.$2).toList();
    versionCount = tags.length;
    LogHandler.log('Got $versionCount tags');
    setState(() => isLoading = false);
  }

  Future<void> getRelease(String tag, String sha, bool dev) async {
    final result = tag.contains('_dev_')
        ? await widget.aboutRepo.getRelease(tag, sha)
        : dev
            ? await widget.aboutRepo.getNote(tag, sha)
            : await widget.aboutRepo.getRelease(tag, sha);

    final body = result.$1, timeUploaded = result.$2;

    if (mounted) {
      Navigator.of(context).push(RawDialogRoute(
        transitionDuration: 300.ms,
        barrierDismissible: true,
        barrierLabel: '',
        transitionBuilder: (_, anim1, __, child) {
          return ScaleTransition(
            scale: anim1.drive(CurveTween(curve: Curves.easeOutQuart)),
            alignment: Alignment.center,
            child: child,
          );
        },
        pageBuilder: (context, __, ___) {
          return VersionDialog(
            tag: tag,
            body: body,
            timeUploaded: timeUploaded,
          );
        },
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Version list',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: getAllVersions,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : versionCount <= 0
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
                    itemCount: versionCount,
                    itemBuilder: (context, index) {
                      bool isDevBuild = tags[index].contains('_dev_');
                      return ListTile(
                        leading: tags[index] == 'v${Globals.appVersion}' //
                            ? const Icon(Icons.arrow_right_rounded)
                            : const Text(''),
                        title: Text(
                          tags[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text('${shas[index]} - ${isDevBuild ? 'dev' : 'stable'}'),
                        visualDensity: const VisualDensity(vertical: 3, horizontal: 4),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isDevBuild)
                              IconButton(
                                icon: const Icon(Icons.file_present_rounded),
                                onPressed: () {
                                  getRelease(tags[index], shas[index], false);
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.logo_dev_rounded),
                              onPressed: () {
                                getRelease(tags[index], shas[index], true);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
