import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../app/theme/constants.dart';
import '../../../../color_generator/blocs/colors_generated/colors_bloc.dart';
import '../../../../color_generator/blocs/colors_locked/lock_bloc.dart';
import '../../../../color_picker/blocs/colorpicker_dialog/colorpicker_bloc.dart';
import '../../../../common/blocs/snackbars/snackbar_bloc.dart';
import '../../../../core/extensions/color_extensions.dart';
import '../../../../core/models/color_palette/color_palette.dart';
import '../../../../navigation/blocs/navigation/navigation_bloc.dart';
import '../../../blocs/list_favorites/favorites_bloc.dart';
import '../../../blocs/remove_favorites/remove_favorites_bloc.dart';

class FavoritesListAdaptive extends StatefulWidget {
  const FavoritesListAdaptive({Key? key}) : super(key: key);

  @override
  _FavoritesListState createState() => _FavoritesListState();
}

class _FavoritesListState extends State<FavoritesListAdaptive> {
  double? hoveringColor;
  int? hoveringPalette;
  static const Duration hoverDuration = kDefaultTransitionDuration;
  static const Curve hoverCurve = kDefaultTransitionCurve;
  static const double size = 88;
  static const double padding = 20;
  static const double cardHeight = size + (padding * 2);

  Color get removeColor => Theme.of(context).errorColor;

  @override
  Widget build(BuildContext context) => BlocBuilder<RemoveFavoritesBloc, RemoveFavoritesState>(
        builder: (_, RemoveFavoritesState removeState) => BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (_, FavoritesState state) {
            if (state is FavoritesLoadSuccess) {
              return LayoutBuilder(
                builder: (_, BoxConstraints windowSize) {
                  final List<ColorPalette> favorites = state.palettes;
                  final int colorsCount = favorites.isNotEmpty ? favorites.first.colors.length : 0;
                  final double maxHeighForTip = padding + (40 * MediaQuery.of(context).textScaleFactor);
                  final bool canShowTip = favorites.length * cardHeight <= windowSize.maxHeight - maxHeighForTip;

                  return Stack(
                    fit: StackFit.expand,
                    alignment: AlignmentDirectional.topCenter,
                    children: <Widget>[
                      Positioned(
                        bottom: padding,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 800),
                          opacity: canShowTip ? 1 : 0,
                          child: Text(
                            AppLocalizations.of(context).removeFavoritesTipLandscape,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(padding),
                        child: SizedBox(
                          width: windowSize.maxWidth,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Wrap(
                              children: List<Widget>.generate(
                                favorites.length,
                                (int paletteIndex) {
                                  final bool isHoveringPalette = hoveringPalette == paletteIndex;
                                  final bool isSelectedToRemove = removeState.selections.contains(paletteIndex);

                                  return Padding(
                                    padding: const EdgeInsets.all(padding),
                                    child: MouseRegion(
                                      onEnter: (_) => setState(() => hoveringPalette = paletteIndex),
                                      onExit: (_) => setState(() => hoveringPalette = null),
                                      child: Stack(
                                        children: <Widget>[
                                          AnimatedPositioned(
                                            right: isHoveringPalette ? 0 : size / 2,
                                            duration: hoverDuration,
                                            curve: hoverCurve,
                                            width: size / 2,
                                            height: size,
                                            child: ColoredBox(
                                              color: isHoveringPalette || isSelectedToRemove
                                                  ? isSelectedToRemove
                                                      ? removeColor.withOpacity(0.2)
                                                      : Colors.black.withOpacity(0.1)
                                                  : Colors.transparent,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: <Widget>[
                                                  Tooltip(
                                                    preferBelow: false,
                                                    message: AppLocalizations.of(context).removeFavoritesTooltip,
                                                    child: IconButton(
                                                      splashRadius: size / 4,
                                                      onPressed: () {
                                                        BlocProvider.of<RemoveFavoritesBloc>(context)
                                                            .add(const RemoveFavoritesRemoved());
                                                        BlocProvider.of<FavoritesBloc>(context)
                                                            .add(FavoritesOneRemoved(colorToRemoveIndex: paletteIndex));
                                                      },
                                                      icon: Icon(
                                                        Icons.delete_forever_outlined,
                                                        color: isSelectedToRemove
                                                            ? Theme.of(context).errorColor.withOpacity(0.8)
                                                            : Theme.of(context)
                                                                .bottomNavigationBarTheme
                                                                .unselectedItemColor,
                                                      ),
                                                    ),
                                                  ),
                                                  Tooltip(
                                                    message:
                                                        AppLocalizations.of(context).selectToRemoveFavoritesTooltip,
                                                    child: Checkbox(
                                                      value: isSelectedToRemove,
                                                      onChanged: (bool? i) => setState(
                                                        () => BlocProvider.of<RemoveFavoritesBloc>(context).add(
                                                          RemoveFavoritesSelected(paletteIndex),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              BlocProvider.of<LockBloc>(context).add(const LockAllUnlocked());
                                              BlocProvider.of<ColorsBloc>(context)
                                                  .add(ColorsRestored(palette: favorites.elementAt(paletteIndex)));
                                              BlocProvider.of<NavigationBloc>(context)
                                                  .add(const NavigationGeneratorTabStarted());
                                            },
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: List<Widget>.generate(
                                                  favorites.elementAt(paletteIndex).colors.length,
                                                  (int colorIndex) {
                                                    final Color color =
                                                        favorites.elementAt(paletteIndex).colors[colorIndex];
                                                    final Color textColor = favorites
                                                        .elementAt(paletteIndex)
                                                        .colors[colorIndex]
                                                        .contrastColor();
                                                    final double hoverKey = paletteIndex + (colorIndex / colorsCount);
                                                    final bool isHoveringColor = hoveringColor == hoverKey;

                                                    return MouseRegion(
                                                      onEnter: (_) => setState(() => hoveringColor = hoverKey),
                                                      onExit: (_) => setState(() => hoveringColor = null),
                                                      child: AnimatedPhysicalModel(
                                                        key: ValueKey<double>(hoverKey),
                                                        clipBehavior: Clip.hardEdge,
                                                        shape: BoxShape.rectangle,
                                                        elevation: isSelectedToRemove
                                                            ? (isHoveringColor ? 12 : 6)
                                                            : (isHoveringColor ? 6 : 2),
                                                        shadowColor: isSelectedToRemove
                                                            ? removeColor
                                                            : Theme.of(context).shadowColor,
                                                        color: color,
                                                        duration: hoverDuration,
                                                        curve: hoverCurve,
                                                        child: SizedBox(
                                                          height: size,
                                                          width: size,
                                                          child: Center(
                                                            child: AnimatedOpacity(
                                                              duration: hoverDuration,
                                                              curve: hoverCurve,
                                                              opacity: isHoveringColor || isSelectedToRemove ? 1 : 0,
                                                              child: TextButton(
                                                                onPressed: () {
                                                                  BlocProvider.of<ColorPickerBLoc>(context)
                                                                      .add(ColorPickerCopied(color));
                                                                  BlocProvider.of<SnackbarBloc>(context)
                                                                      .add(const ColorCopiedSuccess());
                                                                },
                                                                child: Text(
                                                                  color.toHex(),
                                                                  maxLines: 2,
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(color: textColor, fontSize: 11),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )..add(const SizedBox(width: size / 2)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                growable: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      );
}