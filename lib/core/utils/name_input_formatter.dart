import 'package:flutter/services.dart';

/// A robust [TextInputFormatter] for names (First Name, Last Name).
///
/// Features:
/// 1. Real-time filtering of disallowed characters:
///    - First Name (allowSpaces = false): Allows only letters (A-Za-z).
///    - Last Name (allowSpaces = true): Allows letters (A-Za-z), spaces, hyphens (-), and apostrophes (').
/// 2. Capitalizes the first letter of every word (Title Case) across single words,
///    multiple words, and hyphenated/apostrophe names (e.g. John, Mary Jane, O'Connor, Smith-Jones).
/// 3. Prevents leading spaces cleanly without deleting text.
/// 4. Prevents consecutive spaces by collapsing them to a single space cleanly without
///    erasing letters or behaving like a backspace.
/// 5. Accurately calculates cursor position so the cursor never jumps or behaves erratically.
class NameInputFormatter extends TextInputFormatter {
  final bool allowSpaces;

  const NameInputFormatter({this.allowSpaces = true});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final rawText = newValue.text;
    final int rawCursor = newValue.selection.end;

    final StringBuffer filteredBuffer = StringBuffer();
    int newCursor = 0;
    bool lastWasSpace = false;

    for (int i = 0; i < rawText.length; i++) {
      final char = rawText[i];
      final isBeforeCursor = i < rawCursor;

      // Disallow leading space
      if (char == ' ' && filteredBuffer.isEmpty) {
        continue;
      }

      // Space handling
      if (char == ' ') {
        if (!allowSpaces || lastWasSpace) {
          continue;
        }
        filteredBuffer.write(' ');
        lastWasSpace = true;
        if (isBeforeCursor) newCursor++;
        continue;
      }

      lastWasSpace = false;

      // Allowed characters check
      final isAllowed = allowSpaces
          ? RegExp(r"[a-zA-Z'-]").hasMatch(char)
          : RegExp(r"[a-zA-Z]").hasMatch(char);

      if (!isAllowed) {
        continue;
      }

      filteredBuffer.write(char);
      if (isBeforeCursor) newCursor++;
    }

    final filtered = filteredBuffer.toString();

    // Auto-capitalize first letter of every word (Title Case)
    // Word boundaries: start of string, space, hyphen, or apostrophe
    final capitalizedBuffer = StringBuffer();
    bool capitalizeNext = true;

    for (int i = 0; i < filtered.length; i++) {
      final char = filtered[i];
      if (char == ' ' || char == '-' || char == "'") {
        capitalizedBuffer.write(char);
        capitalizeNext = true;
      } else if (capitalizeNext) {
        capitalizedBuffer.write(char.toUpperCase());
        capitalizeNext = false;
      } else {
        capitalizedBuffer.write(char);
      }
    }

    final result = capitalizedBuffer.toString();
    final safeCursor = newCursor.clamp(0, result.length);

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: safeCursor),
    );
  }
}
