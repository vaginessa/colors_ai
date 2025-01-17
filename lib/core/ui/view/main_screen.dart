import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:platform_info/platform_info.dart';

import '../../../color_generator/blocs/colors_generated/colors_bloc.dart';
import '../../../color_generator/blocs/colors_locked/lock_bloc.dart';
import '../../../color_generator/ui/view/gen_colors_tab.dart';
import '../../../color_picker/blocs/colorpicker_bloc.dart';
import '../../../common/blocs/snackbars/snackbar_bloc.dart';
import '../../../common/ui/widgets/app_bar_info_title.dart';
import '../../../favorites/blocs/add_favorites/fab_bloc.dart';
import '../../../favorites/ui/view/favorites_tab.dart';
import '../../../favorites/ui/widgets/buttons/save_colors_fab.dart';
import '../../../navigation/blocs/navigation_bloc.dart';
import '../../../navigation/ui/widgets/bottom_nav_bar.dart';
import '../../../navigation/ui/widgets/nav_rail.dart';
import '../../../share/blocs/share_bloc.dart';
import '../../../share/repository/share_repository.dart';
import '../../../share/ui/view/share_colors_tab.dart';
import '../../../sound/blocs/sound_bloc.dart';
import '../../../sound/repository/sounds_repository.dart';
import '../../repository/colors_repository.dart';
import '../constants.dart';
import '../widgets/overflow_menu.dart';

class MainScreen extends StatefulWidget {
  final List<Widget> navTabs;

  const MainScreen({this.navTabs = const <Widget>[ShareColorsTab(), GenColorsTab(), FavoritesTab()], Key? key})
      : super(key: key);

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<MainScreen> {
  bool showGenFab = false;
  final SoundBloc soundBloc = SoundBloc(SoundsRepository());
  final FocusNode keyboardListenerNode = FocusNode(debugLabel: 'keyboard');

  bool get isPortrait => MediaQuery.of(context).orientation == Orientation.portrait;
  SystemUiOverlayStyle get overlayStyle => Theme.of(context).brightness == Brightness.dark
      ? SystemUiOverlayStyle.light.copyWith(systemNavigationBarColor: Theme.of(context).cardColor)
      : SystemUiOverlayStyle.dark
          .copyWith(systemNavigationBarColor: Theme.of(context).navigationRailTheme.backgroundColor);

  @override
  void initState() {
    soundBloc.add(const SoundStarted());
    super.initState();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: <BlocProvider<BlocBase<Object>>>[
          BlocProvider<SoundBloc>(create: (_) => soundBloc),
          BlocProvider<LockBloc>(
            create: (_) => LockBloc(context.read<ColorsRepository>())..add(const LockStarted()),
          ),
          BlocProvider<ColorsBloc>(
            create: (_) => ColorsBloc(context.read<ColorsRepository>())..add(const ColorsStarted()),
          ),
        ],
        child: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (BuildContext navContext, NavigationState navState) {
            final bool isGenTab = navState.tabIndex == const NavigationGenerateTabInitial().tabIndex;
            if (!isGenTab) {
              BlocProvider.of<FabBloc>(context).add(const FabHided());
            }

            return Shortcuts(
              shortcuts: <ShortcutActivator, Intent>{
                ...WidgetsApp.defaultShortcuts,
                const SingleActivator(kSpacebar): isGenTab ? DoNothingIntent() : const ActivateIntent(),
              },
              child: KeyboardListener(
                focusNode: keyboardListenerNode,
                includeSemantics: false,
                autofocus: true,
                onKeyEvent: (KeyEvent event) {
                  if (event.logicalKey == LogicalKeyboardKey.tab && !showGenFab) {
                    setState(() => showGenFab = true);
                  }
                  if (event.logicalKey == kSpacebar && isGenTab) {
                    if (kIsWeb) {
                      BlocProvider.of<SoundBloc>(navContext).add(const SoundRefreshed());
                    }
                    BlocProvider.of<ColorsBloc>(navContext).add(const ColorsGenerated());
                  }
                },
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: overlayStyle,
                  child: Scaffold(
                    floatingActionButton: isPortrait ? const SaveColorsFAB() : null,
                    appBar: AppBar(
                      systemOverlayStyle: overlayStyle.copyWith(statusBarColor: Colors.transparent),
                      actions: <Widget>[kAppBarActions[navState.tabIndex], const OverflowMenu()],
                      toolbarHeight: kToolbarHeight + (platform.isMacOS ? 12 : 0),
                      title: Padding(
                        padding: EdgeInsets.only(top: platform.isMacOS ? 16 : 0),
                        child: AppBarInfoTitle(selectedTabIndex: navState.tabIndex),
                      ),
                    ),
                    body: MultiBlocProvider(
                      providers: <BlocProvider<BlocBase<Object>>>[
                        BlocProvider<ColorPickerBLoc>(create: (_) => ColorPickerBLoc()),
                        BlocProvider<ShareBloc>(
                          lazy: false,
                          create: (_) => ShareBloc(ShareRepository())..add(const ShareStarted()),
                        ),
                        BlocProvider<SnackbarBloc>(
                          create: (_) => SnackbarBloc()..add(const ServerStatusCheckedSuccess()),
                        ),
                      ],
                      child: BlocListener<SnackbarBloc, SnackbarState>(
                        listener: (BuildContext context, SnackbarState snackbarState) {
                          if (snackbarState is! SnackbarsInitial) {
                            BlocProvider.of<SoundBloc>(context).add(const SoundCopied());
                            late String message;
                            final bool isUrlCopied = snackbarState is UrlCopySuccess;
                            final bool isFileCopied = snackbarState is FileCopySuccess;
                            final bool isShareFailed = snackbarState is ShareAttemptFailure;
                            if (isUrlCopied) {
                              message = AppLocalizations.of(context).urlCopiedMessage;
                            } else if (snackbarState is ColorCopySuccess) {
                              message = AppLocalizations.of(context).colorCopiedMessage(snackbarState.clipboard);
                            } else if (isFileCopied) {
                              message = AppLocalizations.of(context).formatCopied(snackbarState.format);
                            } else if (snackbarState is ServerStatusCheckSuccess) {
                              message = AppLocalizations.of(context).serverMaintenanceMessage;
                            } else if (isShareFailed) {
                              message = AppLocalizations.of(context).shareFailedMessage;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 2),
                                content: Text(message),
                                behavior: (isUrlCopied || isShareFailed || isFileCopied)
                                    ? isPortrait
                                        ? SnackBarBehavior.fixed
                                        : SnackBarBehavior.floating
                                    : SnackBarBehavior.floating,
                                action: isUrlCopied
                                    ? SnackBarAction(
                                        textColor: Theme.of(context).scaffoldBackgroundColor,
                                        label: AppLocalizations.of(context).urlOpenButtonLabel,
                                        onPressed: () => BlocProvider.of<SnackbarBloc>(context).add(
                                          const UrlOpenedSuccess(),
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          }
                        },
                        child: SafeArea(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (!isPortrait) NavRail(navState, toShowGenFab: showGenFab),
                              Expanded(child: widget.navTabs.elementAt(navState.tabIndex)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    bottomNavigationBar: isPortrait ? BottomNavBar(navState) : null,
                  ),
                ),
              ),
            );
          },
        ),
      );
}
