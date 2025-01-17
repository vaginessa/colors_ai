import 'package:color_converter/color_converter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../core/extensions/color_extensions.dart';
import '../../../core/models/color_palette/color_palette.dart';
import '../../models/color_space.dart';

class FileLayout extends StatelessWidget {
  final TtfFont _font;
  final PdfPageFormat _format;
  final ColorPalette _palette;

  double get _height => _format.height - _format.marginTop - _format.marginBottom;
  double get _width =>
      (_format.width - _format.marginLeft - _format.marginRight - (_format.marginRight / 4)) / _palette.colors.length;

  FileLayout(this._palette, this._format, this._font);

  @override
  Widget build(Context context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List<Widget>.generate(
          _palette.colors.length,
          (int colorsIndex) {
            final String hex = _palette.colors.elementAt(colorsIndex).toHex();

            return Column(
              children: <Widget>[
                Container(width: _width, height: _height * (3 / 4), color: PdfColor.fromHex(hex)),
                Spacer(),
                SizedBox(
                  width: _width * 0.9,
                  child: Column(
                    children: List<Widget>.generate(
                      ColorSpace.values.length,
                      (int spacesIndex) {
                        final bool isEven = spacesIndex.isEven;
                        final ColorSpace colorSpace = ColorSpace.values.elementAt(spacesIndex);

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(
                              colorSpace.name.toUpperCase(),
                              style: TextStyle(
                                font: _font,
                                fontSize: 11,
                                color: isEven ? PdfColors.grey800 : PdfColors.grey600,
                              ),
                            ),
                            Spacer(),
                            Text(
                              _colorValue(colorSpace, hex),
                              style: TextStyle(
                                font: _font,
                                fontSize: 11,
                                color: isEven ? PdfColors.grey800 : PdfColors.grey600,
                              ),
                            ),
                          ],
                        );
                      },
                      growable: false,
                    ),
                  ),
                ),
              ],
            );
          },
          growable: false,
        ),
      );

  String _colorValue(ColorSpace space, String hex) {
    switch (space) {
      case ColorSpace.rgb:
        return hexToRgb(hex).toString();
      case ColorSpace.cmyk:
        final CMYK cmyk = hexToCmyk(hex);
        return '${cmyk.c}, ${cmyk.m}, ${cmyk.y}, ${cmyk.k}';
      case ColorSpace.hsb:
        final HSB hsb = hexToHsb(hex);
        return '${hsb.h}, ${hsb.s}, ${hsb.b}';
      case ColorSpace.hsl:
        final HSL hsl = hexToHsl(hex);
        return '${hsl.h}, ${hsl.s}, ${hsl.l}';
      case ColorSpace.lab:
        final LAB lab = hexToLab(hex);
        return '${lab.l}, ${lab.a}, ${lab.b}';
      case ColorSpace.xyz:
        final XYZ xyz = hexToXyz(hex);
        return '${xyz.x.toStringAsFixed(2)}, ${xyz.y.toStringAsFixed(2)}, ${xyz.z.toStringAsFixed(2)}';
      case ColorSpace.hex:
        return hex;
    }
  }
}
