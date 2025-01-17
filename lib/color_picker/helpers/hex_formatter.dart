import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class HexFormatter extends TextInputFormatter {
  final String regExpValidator;

  HexFormatter({this.regExpValidator = kValidHexPattern});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String hex = formatInput(newValue.text);
    final TextSelection selection = TextSelection(baseOffset: hex.length, extentOffset: hex.length);
    final TextEditingValue validatedValue = TextEditingValue(text: hex, selection: selection);

    return FilteringTextInputFormatter.allow(RegExp(regExpValidator)).formatEditUpdate(oldValue, validatedValue);
  }

  static String? formatCompleteInput(String? input) {
    if (input != null && RegExp(kCompleteValidHexPattern).hasMatch(input)) {
      return formatInput(input);
    }
  }

  static String formatInput(String input) => input.replaceFirst('#', '').toUpperCase();
}
