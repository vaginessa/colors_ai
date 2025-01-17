import 'package:clock/clock.dart';
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/ui/constants.dart';
import '../../blocs/about_bloc.dart';
import '../widgets/about_dialog_m3.dart';
import '../widgets/app_icon.dart';

class AboutAppDialog extends StatelessWidget {
  final Widget applicationIcon;
  final String applicationLegalese;
  final TextStyle? linkTextStyle;
  final double? topPadding;
  final double width;

  const AboutAppDialog({
    this.applicationLegalese = ' © Roman Cinis',
    this.applicationIcon = const AppIcon(),
    this.topPadding = 20,
    this.linkTextStyle,
    this.width = 320,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle? linkStyle =
        linkTextStyle ?? Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).indicatorColor);

    return AboutDialogM3(
      applicationVersion: BlocProvider.of<AboutBloc>(context).state.appVersion,
      applicationLegalese: clock.now().year.toString() + applicationLegalese,
      applicationIcon: applicationIcon,
      applicationName: kAppName,
      children: <Widget>[
        SizedBox(height: topPadding),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width),
          child: Text.rich(
            TextSpan(
              style: Theme.of(context).textTheme.bodyText2,
              children: <TextSpan>[
                TextSpan(text: AppLocalizations.of(context).aboutGenerator),
                TextSpan(
                  style: linkStyle,
                  text: ' Colormind.io',
                  recognizer: TapGestureRecognizer()..onTap = () => _onLinkTap(context, const AboutColormindApiTaped()),
                ),
                TextSpan(text: ' ${AppLocalizations.of(context).and} '),
                TextSpan(
                  style: linkStyle,
                  text: 'Huemint.com',
                  recognizer: TapGestureRecognizer()..onTap = () => _onLinkTap(context, const AboutHuemintApiTaped()),
                ),
                TextSpan(text: '. ${AppLocalizations.of(context).aboutSourceCode}'),
                TextSpan(
                  style: linkStyle,
                  text: ' ${AppLocalizations.of(context).aboutSourceRepository}',
                  recognizer: TapGestureRecognizer()..onTap = () => _onLinkTap(context, const AboutSourceCodeTaped()),
                ),
                const TextSpan(text: '.'),
                TextSpan(
                  text:
                      '\n\n${AppLocalizations.of(context).aboutAttribution.toUpperCase()}:\n\n${AppLocalizations.of(context).aboutSounds}',
                ),
                TextSpan(
                  style: linkStyle,
                  text: ' "Material Product Sounds"',
                  recognizer: TapGestureRecognizer()..onTap = () => _onLinkTap(context, const AboutSoundAssetsTaped()),
                ),
                TextSpan(text: ' ${AppLocalizations.of(context).aboutByGoogle}'),
                TextSpan(
                  style: linkStyle,
                  text: ' Google',
                  recognizer: TapGestureRecognizer()..onTap = () => _onLinkTap(context, const AboutGoogleTaped()),
                ),
                TextSpan(text: ' ${AppLocalizations.of(context).aboutSoundsLicense}'),
                TextSpan(
                  style: linkStyle,
                  text: ' CC BY 4.0',
                  recognizer: TapGestureRecognizer()..onTap = () => _onLinkTap(context, const AboutLicenseTaped()),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onLinkTap(BuildContext context, AboutEvent event) => BlocProvider.of<AboutBloc>(context).add(event);
}
