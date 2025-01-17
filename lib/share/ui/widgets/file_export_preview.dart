import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/constants.dart';
import '../../../common/blocs/snackbars/snackbar_bloc.dart';
import '../../../core/models/color_palette/color_palette.dart';
import '../../blocs/share_bloc.dart';
import '../../mixins/text_based_file_creator.dart';
import '../../models/color_space.dart';
import '../../models/file_format.dart';

class FileExportPreview extends StatefulWidget {
  final Curve curve;
  final Duration duration;

  final ColorPalette _palette;

  const FileExportPreview(
    this._palette, {
    this.duration = const Duration(milliseconds: 600),
    this.curve = kDefaultTransitionCurve,
    Key? key,
  }) : super(key: key);

  @override
  State<FileExportPreview> createState() => _FileExportPreviewState();
}

class _FileExportPreviewState extends State<FileExportPreview> with TextBasedFileCreator {
  bool isHovering = false;

  List<Color> get colors => widget._palette.colors;

  double aspectRatio(FileFormat selectedFormat) {
    switch (selectedFormat) {
      case FileFormat.pdfLetter:
      case FileFormat.pngLetter:
        return 110 / 85;
      case FileFormat.pdfA4:
      case FileFormat.pngA4:
        return 297 / 210;
      case FileFormat.scss:
      case FileFormat.json:
        return 1;
      case FileFormat.svg:
        return colors.length.toDouble();
    }
  }

  Color fileBackgroundColor({required bool isPrintable}) {
    if (isPrintable) {
      return isHovering ? Colors.white : Colors.grey[200]!;
    } else {
      final bool isDark = Theme.of(context).brightness == Brightness.dark;

      return isHovering
          ? (isDark ? Colors.grey[800]! : Colors.grey[100]!)
          : (isDark ? Colors.grey[900]! : Colors.grey[300]!);
    }
  }

  Text codeText({required bool isJson}) => Text(
        isJson ? toJson(widget._palette) : toScss(widget._palette),
        key: ValueKey<bool>(isJson),
        style: GoogleFonts.robotoMono(),
      );

  @override
  Widget build(BuildContext context) => BlocBuilder<ShareBloc, ShareState>(
        builder: (_, ShareState state) {
          final FileFormat file = state.selectedFormat ?? FileFormat.values.first;

          return GestureDetector(
            onTap: () {
              setState(() => isHovering = !isHovering);
              if (!file.isPrintable) {
                BlocProvider.of<ShareBloc>(context).add(ShareFileCopied(widget._palette));
                BlocProvider.of<SnackbarBloc>(context).add(FileCopiedSuccess(file.format));
              }
            },
            child: MouseRegion(
              onEnter: (_) => setState(() => isHovering = true),
              onExit: (_) => setState(() => isHovering = false),
              cursor: file.isPrintable ? MouseCursor.defer : SystemMouseCursors.click,
              child: AnimatedPhysicalModel(
                duration: kDefaultLongTransitionDuration,
                curve: Curves.decelerate,
                color: fileBackgroundColor(isPrintable: file.isPrintable),
                borderRadius: BorderRadius.circular(isHovering ? 2 : 8),
                clipBehavior: Clip.hardEdge,
                elevation: isHovering ? 10 : 2,
                shadowColor: Colors.black26,
                shape: BoxShape.rectangle,
                child: AnimatedSize(
                  duration: widget.duration,
                  curve: widget.curve,
                  child: AspectRatio(
                    aspectRatio: aspectRatio(file),
                    child: FractionallySizedBox(
                      widthFactor: 0.9,
                      heightFactor: 0.9,
                      child: AnimatedSize(
                        duration: widget.duration,
                        curve: widget.curve,
                        child: (file == FileFormat.scss || file == FileFormat.json)
                            ? FractionallySizedBox(
                                widthFactor: 0.6,
                                heightFactor: 0.6,
                                child: FittedBox(
                                  child: Center(
                                    child: AnimatedSwitcher(
                                      duration: kDefaultReverseTransitionDuration,
                                      switchInCurve: widget.curve,
                                      switchOutCurve: widget.curve,
                                      transitionBuilder: (Widget child, Animation<double> animation) => SizeTransition(
                                        sizeFactor: animation,
                                        axis: Axis.horizontal,
                                        axisAlignment: -1,
                                        child: child,
                                      ),
                                      child: codeText(isJson: file == FileFormat.json),
                                    ),
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List<Widget>.generate(
                                  colors.length,
                                  (int colorsIndex) => Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 12,
                                          child: AnimatedSize(
                                            duration: widget.duration,
                                            curve: widget.curve,
                                            child: Padding(
                                              padding: EdgeInsets.all(file.isPrintable ? 2 : 0),
                                              child: AnimatedContainer(
                                                duration: widget.duration,
                                                curve: widget.curve,
                                                color: colors.elementAt(colorsIndex),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (file.isPrintable) ...<Widget>[
                                          const Expanded(child: SizedBox()),
                                          Flexible(
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: ListView.separated(
                                                itemCount: ColorSpace.values.length,
                                                separatorBuilder: (_, __) => AnimatedContainer(
                                                  duration: widget.duration,
                                                  curve: widget.curve,
                                                  height: 2,
                                                  color: Colors.transparent,
                                                ),
                                                itemBuilder: (_, __) => AnimatedContainer(
                                                  duration: widget.duration,
                                                  curve: widget.curve,
                                                  height: 6,
                                                  color: Colors.black12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  growable: false,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
}
