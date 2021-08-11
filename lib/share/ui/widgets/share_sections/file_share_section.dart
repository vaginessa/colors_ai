import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../common/blocs/snackbars/snackbars_bloc.dart';
import '../../../../core/models/color_palette/color_palette.dart';
import '../../../blocs/share/share_hydrated_bloc.dart';
import '../../../models/file_format_enum.dart';
import 'share_section_interface.dart';

class FileShareSection extends ShareSection {
  const FileShareSection(
    ColorPalette palette, {
    required double width,
    required this.firstFormat,
    required this.selectedFormatIndex,
    required this.canSharePdf,
    required this.canSharePng,
    this.additionalInfo,
  }) : super(maxWidth: width, palette: palette);

  final int selectedFormatIndex, firstFormat;
  final bool canSharePdf, canSharePng;
  final String? additionalInfo;

  FileFormat get file => FileFormat.values.elementAt(selectedFormatIndex);

  bool get cannotCopy => selectedFormatIndex <= 3;

  @override
  Widget build(BuildContext context) {
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isPortrait ? maxWidth : maxWidth * 0.32),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 24),
            child: DropdownButtonFormField<int>(
              isExpanded: !isPortrait,
              isDense: isPortrait,
              dropdownColor: Theme.of(context).dialogBackgroundColor,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).splashColor,
                  labelText: 'Share file as:', //TODO L10N
                  helperStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  helperMaxLines: 1,
                  helperText:
                      (additionalInfo != null) ? '* ${AppLocalizations.of(context).exportTo} $additionalInfo' : null),
              value: selectedFormatIndex,
              onChanged: (newFormatIndex) {
                if (newFormatIndex != null) {
                  BlocProvider.of<ShareBloc>(context).add(ShareFormatSelected(formatIndex: newFormatIndex));
                }
              },
              items: List.generate(
                FileFormat.values.length,
                (int index) => DropdownMenuItem<int>(
                  value: index,
                  child: Text(FileFormat.values.elementAt(index).name),
                ),
                growable: false,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ButtonBar(
              mainAxisSize: MainAxisSize.max,
              alignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.content_copy_outlined, size: 20),
                    label: Text('Copy ${file.format}'.toUpperCase()), //TODO L10N
                    onPressed: cannotCopy
                        ? null
                        : () {
                            BlocProvider.of<ShareBloc>(context).add(ShareUrlCopied(palette));
                            BlocProvider.of<SnackbarBloc>(context).add(const UrlCopiedSuccess());
                          },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.link, size: 20),
                    label: Text('Share ${file.format}'.toUpperCase()), //TODO L10N
                    autofocus: true,
                    onPressed: () => BlocProvider.of<ShareBloc>(context).add(ShareFileShared(palette)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
