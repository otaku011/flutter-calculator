import '../data/enums.dart';
import '../data/settings.dart';

extension StringManipulation on String {
    int count(String char) {
        int count = 0;
        for (int i = 0; i < length; i++) {
            if (this[i] == char) count++;
        }
        return count;
    }

    String titleCase() {
        return toLowerCase().replaceAllMapped(
            RegExp(r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+'),
            (match) => "${match[0]![0].toUpperCase()}${match[0]!.substring(1).toLowerCase()}"
        );
    }

    String mathSimplify() {
        return
            replaceAllMapped(
                RegExp(r"(?<!\d)\.\d+"),
                (match) => "0${match[0]!}"
            )

            // remove trailing zeroes
            .replaceAllMapped(
                RegExp(r'(?<=\d)\.\d*'),
                (match) => match[0]!.replaceAll(RegExp(r'0+$'), "").replaceFirst(RegExp(r'\.$'), "")
            )

            // remove leading zeros
            .replaceAllMapped(
                RegExp(r'(\d*\.)?(\d+)'),
                (match) => (match[1] ?? match[2]!).replaceAll(RegExp(r'^0+(?!\.|$)'), "") + (match[1] == null? "" : match[2]!)
            )
        ;
    }

    String reverse(){
        return split("").reversed.join("");
    }

    /// Formats a number as a string with custom settings.
    ///
    /// The format of the input number should be the same as the `double` format.
    /// For example, `"13.34534"` or `"39423923"`.
    ///
    /// If [settings] is specified, the [decimalFormat] and [groupingFormat]
    /// arguments will be ignored.
    ///
    /// If [scientificNotation] is specified, the [settings.scientificNotation]
    /// will be ignored.
    String mathFormat({
        NumberFormatDecimals decimalFormat = NumberFormatDecimals.point,
        NumberFormatGrouping groupingFormat = NumberFormatGrouping.comma,
        bool? scientificNotation,
        bool isHexNumber = false,
        int minimumChar = 3,
        Settings? settings,
    }) {
        String text = this;
        String decimalChar = Settings.numberFormatDecimalChar(decimalFormat);
        String groupingChar = Settings.numberFormatGroupingChar(groupingFormat);

        if (settings != null){
            decimalChar = Settings.numberFormatDecimalChar(settings.numberFormatDecimal);
            groupingChar = Settings.numberFormatGroupingChar(settings.numberFormatGrouping);
        }

        if (
            scientificNotation == true ||
            (scientificNotation == null && settings != null && settings.scientificNotation)
        ){
            text = text.toScientificDigit();
        }

        String numbers = isHexNumber? "[A-F\\d]" : "\\d";

        return text
            .reverse()
            .replaceAllMapped(
                RegExp('($numbers+\\.)?($numbers+)'),
                (match) => (match.group(1) ?? "") + match.group(2)!.replaceAllMapped(
                    RegExp('$numbers{$minimumChar}(?=$numbers)'),
                    (match) => "${match.group(0)!}<g>",
                ),
            )
            .replaceAll(".", decimalChar)
            .replaceAll("<g>", groupingChar)
            .reverse()
        ;
    }

    bool isMinus(){
        return RegExp(r'^-').hasMatch(this);
    }

    bool isNumber(){
        return RegExp(r'^[-+]?(?:\d*.)?\d+$').hasMatch(this);
    }

    bool isInteger(){
        return RegExp(r"^[-+]?\d+$").hasMatch(this);
    }

    /// Add scientific notation to number (reverse of `toRealDigit` method).
    /// For example:
    ///
    /// - `1200` => `"12E+2"`
    /// - `350` => `"32E+1"`
    /// - `0.012` => `"1.2E-2"`
    String toScientificDigit(){
        String input = toRealDigit();

        if (input.length < 280 || input.contains('.')){
            input = input.replaceAllMapped(
                RegExp(r'(\d*\.)?(\d+)'),
                (match) => double.parse(match[0]!).toStringAsPrecision(10).toUpperCase()
            );
        } else {
            final int exponent = input.length - 1;
            bool isMinus = input[0] == '-';
            input = '${input.substring(0, isMinus? 2 : 1)}.${input.substring(isMinus? 2 : 1, 10)}E+$exponent';
        }

        return input.mathSimplify();
    }

    /// Convert `E`/`e` notation in number. For example:
    ///
    /// - `12E+2` => `"1200"`
    /// - `3.5E2` => `"350"`
    /// - `1.2E-2` => `"0.012"`
    String toRealDigit() {
        return mathSimplify().replaceAllMapped(
            RegExp(r'((?:\d*\.)?\d+)[eE]([-+]?\d+)'),
            (match) {
                int exponent = int.parse(match[2]!).abs();
                String base = match[1]!;
                if (int.parse(match[2]!) < 0){
                    if (RegExp(r'\.').hasMatch(base)){
                        base = "0.${"0" * (exponent - base.indexOf('.'))}${base.replaceFirst('.', '')}";
                    } else {
                        base = '0.${'0' * (exponent - 1)}$base';
                    }
                } else {
                    if (RegExp(r'\.').hasMatch(base)){
                        base = base.replaceFirst('.', '') + ('0' * (exponent - (base.length - (base.indexOf(".") + 1))));
                    } else {
                        base += ('0' * exponent);
                    }
                }
                return base;
            },
        );
    }
}