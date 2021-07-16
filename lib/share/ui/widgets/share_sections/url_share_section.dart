import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../general/blocs/snackbars/snackbars_bloc.dart';
import '../../../../general/models/color_palette/color_palette.dart';
import '../../../blocs/share/share_hydrated_bloc.dart';
import '../../../services/url_providers/url_providers.dart';
import 'share_section_interface.dart';

class UrlShareSection extends ShareSection {
  const UrlShareSection(
    ColorPalette palette, {
    required double width,
    required this.providersList,
    required this.firstProvider,
    required this.selectedProviderIndex,
    required this.exportFormats,
  }) : super(maxWidth: width, palette: palette);

  final int selectedProviderIndex, firstProvider;
  final String? exportFormats;
  final List<ColorsUrlProvider> providersList;

  @override
  Widget build(BuildContext context) {
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isPortrait ? maxWidth : maxWidth * 0.4),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 24),
            child: DropdownButtonFormField<int>(
              isExpanded: !isPortrait,
              isDense: isPortrait,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).splashColor,
                  labelText: AppLocalizations.of(context).shareLinksLabel,
                  helperStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black54),
                  helperMaxLines: 1,
                  helperText: (selectedProviderIndex == firstProvider)
                      ? AppLocalizations.of(context).googleArtsExport
                      : (exportFormats != null)
                          ? '* ${AppLocalizations.of(context).exportTo} $exportFormats'
                          : null),
              value: selectedProviderIndex,
              onChanged: (newProviderIndex) {
                if (newProviderIndex != null) {
                  BlocProvider.of<ShareBloc>(context).add(ShareUrlProviderSelected(providerIndex: newProviderIndex));
                }
              },
              items: List.generate(
                providersList.length,
                (int index) => DropdownMenuItem<int>(
                  value: index,
                  child: RichText(
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      text: TextSpan(
                          style: const TextStyle(color: Colors.black),
                          text: providersList[index].name,
                          children: (providersList[index].formats != null)
                              ? const [TextSpan(text: '*', style: TextStyle(color: Colors.grey))]
                              : null)),
                ),
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
                    label: Text(AppLocalizations.of(context).copyUrlButtonLabel.toUpperCase()),
                    onPressed: () {
                      BlocProvider.of<ShareBloc>(context).add(ShareUrlCopied(palette));
                      BlocProvider.of<SnackbarBloc>(context).add(const UrlCopiedSuccess());
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.link, size: 20),
                    label: Text(AppLocalizations.of(context).shareUrlButtonLabel.toUpperCase()),
                    autofocus: true,
                    onPressed: () => BlocProvider.of<ShareBloc>(context).add(ShareUrlShared(palette)),
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
