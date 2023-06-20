// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';

import 'package:calculator/utils/build_context.dart';
import 'package:flutter/material.dart';

import '../data/enums.dart';
import '../utils/functions.dart';
import '../widgets/drawer.dart';
import '../utils/operations.dart';
import '../utils/converter.dart';
import '../utils/string.dart';
import '../data/settings.dart';
import '../data/converter.dart';
import '../data/keyboard.dart';
import '../data/history.dart';
import 'history.dart';

class ProgrammerPage extends StatefulWidget {
    const ProgrammerPage({super.key});

    @override
    State<ProgrammerPage> createState() => _ProgrammerPageState();
}

class _ProgrammerPageState extends State<ProgrammerPage> {

    final TextEditingController _input = TextEditingController();
    final ScrollController _inputScroll = ScrollController();
    final ValueNotifier<String> _output = ValueNotifier("");
    String _realInput = "";
    bool _showBinaries = false;
    Timer? _timer;

    void _saveToHistory(){
        final Settings settings = context.settings();

        String input = _realInput;
        ConverterUnit outputUnit = ConverterUnit.numberInteger;
        switch (settings.programmerPage.numberType){
            case NumberType.integer: break;
            case NumberType.float32: outputUnit = ConverterUnit.numberFloat32; break;
            case NumberType.float64: outputUnit = ConverterUnit.numberFloat64; break;
        }
        switch (settings.programmerPage.inputRadix){
            case Radix.dec: break;
            case Radix.hex: input = input.replaceAllMapped(RegExp(r'[A-F\d]+'), (match) => ConverterOperation.number(match[0]!, ConverterUnit.numberHexadecimal, outputUnit)); break;
            case Radix.oct: input = input.replaceAllMapped(RegExp(r'\d+'), (match) => ConverterOperation.number(match[0]!, ConverterUnit.numberOctal, outputUnit)); break;
            case Radix.bin: input = input.replaceAllMapped(RegExp(r'\d+'), (match) => ConverterOperation.number(match[0]!, ConverterUnit.numberBinary, outputUnit)); break;
        }
        if (_output.value.isEmpty || _output.value == input || input.isEmpty) return;
        ProgrammerHistory history = ProgrammerHistory(
            input: _realInput,
            output: _output.value,
            inputRadix: settings.programmerPage.inputRadix,
            numberType: settings.programmerPage.numberType,
            date: DateTime.now()
        );
        history.insertDB();
    }

    int _countFormatNumberChar(String input, int maxIndex, String groupingFormatChar){
        int length = 0;
        int index = 0;
        for (int i = 0; i < input.length; i++){
            if (input[i] == groupingFormatChar) {
                ++length;
            } else {
                if (i > 0) ++index;
            }
            if (index == maxIndex) break;
        }
        return length;
    }

    String _repairInput(String input){
        String number = "(?:\\d*\\.)?\\d+";
        int openBracketsCount = input.count(Keyboard.openBracket);
        int closeBracketsCount = input.count(Keyboard.closeBracket);

        if (openBracketsCount < closeBracketsCount) {
            throw Exception("Open brackets < Close brackets [open-brackets: $openBracketsCount, close-brackets: $closeBracketsCount, text: $input]");
        }
        else if (openBracketsCount > closeBracketsCount) {
            input += (")" * (openBracketsCount - closeBracketsCount));
        }

        return input
            .replaceAllMapped(
                RegExp("($number|\\))(\\(|${Keyboard.functionsRegex()})"),
                (match) => match[1]! + Keyboard.multiply + match[2]!
            )
            .replaceAllMapped(
                RegExp("(\\))($number|\\(|${Keyboard.functionsRegex()})"),
                (match) => match[1]! + Keyboard.multiply + match[2]!
            )
        ;
    }

    void _showMemoryValue(){
        final Settings settings = context.settings();
        final TextTheme textTheme = context.textTheme;

        showDialog(
            context: context,
            builder: (context) => StatefulBuilder(builder: (context, setState) {

                Widget content = Text(
                    settings.memoryValue.mathFormat(settings: settings),
                    style: textTheme.headlineMedium,
                );

                List<Widget> actions = [
                    TextButton(
                        onPressed: (){ _operate(Keyboard.memoryClear); setState((){}); },
                        child: const Text("MC")
                    ),
                    TextButton(
                        onPressed: () => context.navigateBack(),
                        child: const Text("Close")
                    )
                ];

                return AlertDialog(
                    title: const Text("Memory value"),
                    content: content,
                    actions: actions,
                );
            })
        );
    }

    void _operate(String key, [bool saveToHistory = true]){
        final Settings settings = context.settings();

        int cursorPosition = _input.selection.start;
        if (cursorPosition <= 0) cursorPosition = 0;

        cursorPosition -= _countFormatNumberChar(
            _input.text,
            _input.text.substring(0, cursorPosition).length-1,
            Settings.numberFormatGroupingChar(
                settings.programmerPage.inputRadix == Radix.dec
                ? settings.numberFormatGrouping
                : NumberFormatGrouping.space
            )
        );

        if (cursorPosition <= 0) cursorPosition = 0;
        if (cursorPosition > _realInput.length) cursorPosition = _realInput.length;
        String prefix = _realInput.substring(0, cursorPosition);
        String suffix = _realInput.substring(cursorPosition);

        switch (key){
            case Keyboard.equal:
                if (_output.value.isNotEmpty){
                    _saveToHistory();
                    ConverterUnit inputUnit = ConverterUnit.numberInteger;
                    switch (settings.programmerPage.numberType){
                        case NumberType.integer: break;
                        case NumberType.float32: inputUnit = ConverterUnit.numberFloat32;
                        case NumberType.float64: inputUnit = ConverterUnit.numberFloat64;
                    }

                    switch (settings.programmerPage.inputRadix){
                        case Radix.dec:
                            _realInput = _output.value;
                            _input.text = _realInput.mathFormat(settings: settings, scientificNotation: false);
                        case Radix.hex:
                            _realInput = _output.value.isEmpty? "" : ConverterOperation.number(_output.value, inputUnit, ConverterUnit.numberHexadecimal);
                            _input.text = _realInput.mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space);
                        case Radix.oct:
                            _realInput = _output.value.isEmpty? "" : ConverterOperation.number(_output.value, inputUnit, ConverterUnit.numberOctal);
                            _input.text = _realInput.mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space);
                        case Radix.bin:
                            _realInput = _output.value.isEmpty? "" : ConverterOperation.number(_output.value, inputUnit, ConverterUnit.numberBinary);
                            _input.text = _realInput.mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space);
                    }
                } else {
                    _realInput = _input.text = "";
                }
                _input.selection = TextSelection.fromPosition(TextPosition(offset: _input.text.length));
                return;
            case Keyboard.clear:
                _realInput = "";
                cursorPosition = 0;
            case Keyboard.delete:
                if (cursorPosition > 0){
                    var re = RegExp("(?:(?:${Keyboard.functionsRegex()})\\(?|${Keyboard.modulus}|${Keyboard.leftShift}|${Keyboard.rightShift}|${Keyboard.or}|${Keyboard.and}|${Keyboard.xor})\$");
                    if (re.hasMatch(prefix)){
                        _realInput = prefix.replaceFirstMapped(re, (match) {
                            cursorPosition -= match[0]!.length;
                            return "";
                        }) + suffix;
                    } else {
                        _realInput = prefix.substring(0, cursorPosition-1) + suffix;
                        --cursorPosition;
                    }
                }
            case Keyboard.memory:
                _showMemoryValue();
                return;
            case Keyboard.memoryClear:
                settings.memoryValue = "0";
                return;
            case Keyboard.memoryPlus:
                if (_output.value.isNotEmpty){
                    settings.memoryValue = Operation.add(settings.memoryValue, _output.value);
                }
                return;
            case Keyboard.memoryMin:
                if (_output.value.isNotEmpty){
                    settings.memoryValue = Operation.subtract(settings.memoryValue, _output.value);
                }
                return;
            case Keyboard.memoryRecall:
                String minusChar = settings.memoryValue.isMinus()? "-" : "";
                String addition = settings.memoryValue.replaceFirst(RegExp(r'^-'), "");
                ConverterUnit inputUnit = ConverterUnit.numberInteger;
                if (settings.memoryValue.contains('.')){
                    inputUnit = settings.programmerPage.numberType == NumberType.float32
                        ? ConverterUnit.numberFloat32
                        : ConverterUnit.numberFloat64
                    ;
                }
                switch (settings.programmerPage.inputRadix){
                    case Radix.dec: break;
                    case Radix.hex: addition = ConverterOperation.number(addition, inputUnit, ConverterUnit.numberHexadecimal);
                    case Radix.oct: addition = ConverterOperation.number(addition, inputUnit, ConverterUnit.numberOctal);
                    case Radix.bin: addition = ConverterOperation.number(addition, inputUnit, ConverterUnit.numberBinary);
                }
                _realInput = prefix + minusChar + addition + suffix;
                cursorPosition += (minusChar + addition).length;
            case Keyboard.inputRadix:
                _changeInputRadix();
                return;
            default:
                if (Keyboard.isFunction(key)){
                    _realInput = "$prefix$key($suffix";
                    cursorPosition += (key.length + 1);
                } else {
                    _realInput = prefix + key + suffix;
                    cursorPosition += key.length;
                }
        }

        _timer?.cancel();

        try {
            _output.value = _calculate((){
                ConverterUnit outputUnit = ConverterUnit.numberInteger;
                switch (settings.programmerPage.numberType){
                    case NumberType.integer: break;
                    case NumberType.float32: outputUnit = ConverterUnit.numberFloat32;
                    case NumberType.float64: outputUnit = ConverterUnit.numberFloat64;
                }
                switch (settings.programmerPage.inputRadix){
                    case Radix.dec: return _realInput;
                    case Radix.hex: return _realInput.replaceAllMapped(RegExp(r'[A-F\d]+'), (match) => ConverterOperation.number(match[0]!, ConverterUnit.numberHexadecimal, outputUnit));
                    case Radix.oct: return _realInput.replaceAllMapped(RegExp(r'\d+'), (match) => ConverterOperation.number(match[0]!, ConverterUnit.numberOctal, outputUnit));
                    case Radix.bin: return _realInput.replaceAllMapped(RegExp(r'\d+'), (match) => ConverterOperation.number(match[0]!, ConverterUnit.numberBinary, outputUnit));
                }
            }());
            if (saveToHistory) _timer = Timer(const Duration(seconds: 3), () => _saveToHistory());
        } catch (e){
            _timer?.cancel();
            debugPrint(e.toString());
            _output.value = "";
        }
        String formattedInput = "";
        switch (settings.programmerPage.inputRadix){
            case Radix.dec: formattedInput = _realInput.mathFormat(settings: settings, scientificNotation: false);
            case Radix.hex: formattedInput = _realInput.mathFormat(groupingFormat: NumberFormatGrouping.space, isHexNumber: true, minimumChar: 4);
            case Radix.oct: formattedInput = _realInput.mathFormat(groupingFormat: NumberFormatGrouping.space, minimumChar: 4);
            case Radix.bin: formattedInput = _realInput.mathFormat(groupingFormat: NumberFormatGrouping.space, minimumChar: 4);
        }
        cursorPosition += _countFormatNumberChar(
            formattedInput,
            cursorPosition,
            Settings.numberFormatGroupingChar(settings.programmerPage.inputRadix == Radix.dec
                ? settings.numberFormatGrouping
                : NumberFormatGrouping.space
            )
        );
        _input.text = formattedInput;
        _input.selection = TextSelection.fromPosition(TextPosition(offset: cursorPosition));
        settings.programmerPage.input = _realInput;

        _scrollToCursorPosition();
    }

    /// [bit] value only 1 or 0
    void _operateBinaries(String input, int index, String bit){
        final Settings settings = context.settings();

        if (bit == "-") bit = "1";
        if (bit != "0" && bit != "1") throw Exception("Bit value is 0 or 1 [bit: $bit]");

        input = input.padLeft(settings.programmerPage.numberType == NumberType.float32? 32 : 64, "0");
        input = input.replaceRange(index, index+1, bit == "0"? "1" : "0");

        ConverterUnit outputUnit = ConverterUnit.numberInteger;
        switch (settings.programmerPage.numberType){
            case NumberType.integer: break;
            case NumberType.float32: outputUnit = ConverterUnit.numberFloat32;
            case NumberType.float64: outputUnit = ConverterUnit.numberFloat64;
        }

        _output.value = ConverterOperation.number(input, ConverterUnit.numberBinary, outputUnit);

        switch (settings.programmerPage.inputRadix){
            case Radix.dec:
                _realInput = _output.value;
                _input.text = _realInput.mathFormat(settings: settings, scientificNotation: false);
            case Radix.hex:
                _realInput = _output.value.isEmpty? "" : ConverterOperation.number(_output.value, outputUnit, ConverterUnit.numberHexadecimal);
                _input.text = _realInput.mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space);
            case Radix.oct:
                _realInput = _output.value.isEmpty? "" : ConverterOperation.number(_output.value, outputUnit, ConverterUnit.numberOctal);
                _input.text = _realInput.mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space);
            case Radix.bin:
                _realInput = _output.value.isEmpty? "" : ConverterOperation.number(_output.value, outputUnit, ConverterUnit.numberBinary);
                _input.text = _realInput.mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space);
        }
        _input.selection = TextSelection.fromPosition(TextPosition(offset: _input.text.length));
    }

    void _operateBinariesShift(String key){
        final Settings settings = context.settings();
        String input = _output.value;

        if (_output.value.isEmpty || RegExp(r'^0+$').hasMatch(_output.value)){
            switch (settings.programmerPage.numberType){
                case NumberType.integer: input = "1"; break;
                case NumberType.float32: input = ConverterOperation.number("1", ConverterUnit.numberBinary, ConverterUnit.numberFloat32);
                case NumberType.float64: input = ConverterOperation.number("1", ConverterUnit.numberBinary, ConverterUnit.numberFloat64);
            }
        }

        switch (key){
            case Keyboard.leftShift:
                input = "$input${Keyboard.leftShift}1";
            case Keyboard.rightShift:
                input = "$input${Keyboard.rightShift}1";
        }
        try {
            ConverterUnit inputUnit = ConverterUnit.numberInteger;
            switch (settings.programmerPage.numberType){
                case NumberType.integer: break;
                case NumberType.float32: inputUnit = ConverterUnit.numberFloat32;
                case NumberType.float64: inputUnit = ConverterUnit.numberFloat64;
            }
            String binary = ConverterOperation.number(_calculate(input), inputUnit, ConverterUnit.numberBinary);
            int maxLength = settings.programmerPage.numberType == NumberType.float32? 32 : 64;
            if (binary.length > maxLength){
                binary = binary.substring(binary.length - maxLength);
            }
            _output.value = ConverterOperation.number(binary, ConverterUnit.numberBinary, inputUnit);
        } catch (e){
            debugPrint(e.toString());
            _output.value = "";
        }

        ConverterUnit outputUnit = ConverterUnit.numberInteger;
        switch (settings.programmerPage.numberType){
            case NumberType.integer: break;
            case NumberType.float32: outputUnit = ConverterUnit.numberFloat32;
            case NumberType.float64: outputUnit = ConverterUnit.numberFloat64;
        }

        switch (settings.programmerPage.inputRadix){
            case Radix.dec:
                _realInput  = _output.value;
                _input.text = _realInput.mathFormat(settings: settings, scientificNotation: false);
            case Radix.hex:
                _realInput  = _output.value.isEmpty? "" : ConverterOperation.number(_output.value, outputUnit, ConverterUnit.numberHexadecimal);
                _input.text = _realInput.mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space);
            case Radix.oct:
                _realInput  = _output.value.isEmpty? "" : ConverterOperation.number(_output.value, outputUnit, ConverterUnit.numberOctal);
                _input.text = _realInput.mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space);
            case Radix.bin:
                _realInput  = _output.value.isEmpty? "" : ConverterOperation.number(_output.value, outputUnit, ConverterUnit.numberBinary);
                _input.text = _realInput.mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space);
        }
        _input.selection = TextSelection.fromPosition(TextPosition(offset: _input.text.length));
    }

    String _calculate(String input){
        const String numbers = '(?<!\\d|\\))[-+]?(?:\\d*\\.)?\\d+';
        final Settings settings = context.settings();
        final String functions = Keyboard.functionsRegex();
        final RegExp regex = RegExp(
            "\\($numbers\\)|"
            "(?:$numbers)(?:[-+${Keyboard.multiply}${Keyboard.division}\\${Keyboard.power}]|${Keyboard.modulus}|${Keyboard.leftShift}|${Keyboard.rightShift}|${Keyboard.and}|${Keyboard.or}|${Keyboard.xor})(?:$numbers)"
        );
        final ConverterUnit inputUnit = settings.programmerPage.numberType == NumberType.float64
            ? ConverterUnit.numberFloat64
            : ConverterUnit.numberFloat32
        ;

        int cache = 0;
        input = _repairInput(input).replaceAll(RegExp(r"[ \n]"), "").mathSimplify();
        while (regex.hasMatch(input)){

            // Exponential operation
            input = input
                .reverse()
                .replaceAllMapped(
                    RegExp("(\\d+\\.?\\d*[-+]?(?!\\d))(\\${Keyboard.power})\\)(\\d+\\.?\\d*[-]?(?!\\d))\\("),
                    (match) => Operation.power(match[3]!.reverse(), match[1]!.reverse()).reverse()
                )
                .replaceAllMapped(
                    RegExp("(\\d+\\.?\\d*[-+]?(?!\\d))(\\${Keyboard.power})(\\d+\\.?\\d*[+]?(?!\\d))"),
                    (match) => Operation.power(match[3]!.reverse(), match[1]!.reverse()).reverse()
                )
                .reverse()
            ;

            // Division & multiplication & modulus operation
            input = input.replaceAllMapped(
                RegExp("($numbers)([${Keyboard.multiply}${Keyboard.division}]|${Keyboard.modulus})($numbers)"),
                (match) => switch (match[2]){
                    Keyboard.multiply => Operation.multiply(match[1]!, match[3]!),
                    Keyboard.division => Operation.division(match[1]!, match[3]!),
                    Keyboard.modulus => Operation.modulus(match[1]!, match[3]!),
                    _ => ''
                }
            );

            // Addition & subtraction operation
            input = input.replaceAllMapped(
                RegExp("($numbers)([-+])($numbers)"),
                (match) => switch (match[2]){
                        Keyboard.add => Operation.add(match[1]!, match[3]!),
                        Keyboard.min => Operation.subtract(match[1]!, match[3]!),
                        _ => ''
                    }
            );

            // Shift operation
            input = input.replaceAllMapped(
                RegExp("($numbers)(${Keyboard.leftShift}|${Keyboard.rightShift})($numbers)"),
                (match) {
                    String num1 = settings.programmerPage.numberType == NumberType.integer
                        ? match[1]!
                        : ConverterOperation.number(ConverterOperation.number(match[1]!, inputUnit, ConverterUnit.numberBinary), ConverterUnit.numberBinary, ConverterUnit.numberInteger);
                    String num2 = settings.programmerPage.numberType == NumberType.integer
                        ? match[3]!
                        : ConverterOperation.number(ConverterOperation.number(match[3]!, inputUnit, ConverterUnit.numberBinary), ConverterUnit.numberBinary, ConverterUnit.numberInteger);
                    switch (match[2]!){
                        case Keyboard.leftShift:
                            if (settings.programmerPage.numberType != NumberType.integer){
                                return ConverterOperation.number(
                                    Operation.leftShift(num1, num2),
                                    ConverterUnit.numberInteger,
                                    inputUnit,
                                );
                            }
                            return Operation.leftShift(num1, num2);
                        case Keyboard.rightShift:
                            if (settings.programmerPage.numberType != NumberType.integer){
                                return ConverterOperation.number(
                                    Operation.rightShift(num1, num2),
                                    ConverterUnit.numberInteger,
                                    inputUnit,
                                );
                            }
                            return Operation.rightShift(num1, num2);
                    }

                    return "";
                }
            );

            // And operation
            input = input.replaceAllMapped(
                RegExp("($numbers)(${Keyboard.and})($numbers)"),
                (match) {
                    String num1 = match[1]!;
                    String num2 = match[3]!;
                    if (settings.programmerPage.numberType != NumberType.integer){
                        num1 = ConverterOperation.number(ConverterOperation.number(num1, inputUnit, ConverterUnit.numberBinary), ConverterUnit.numberBinary, ConverterUnit.numberInteger);
                        num2 = ConverterOperation.number(ConverterOperation.number(num2, inputUnit, ConverterUnit.numberBinary), ConverterUnit.numberBinary, ConverterUnit.numberInteger);
                        return ConverterOperation.number(
                            Operation.and(num1, num2),
                            ConverterUnit.numberInteger,
                            inputUnit,
                        );
                    }
                    return Operation.and(num1, num2);
                }
            );

            // Xor operation
            input = input.replaceAllMapped(
                RegExp("($numbers)(${Keyboard.xor})($numbers)"),
                (match) {
                    String num1 = match[1]!;
                    String num2 = match[3]!;
                    if (settings.programmerPage.numberType != NumberType.integer){
                        num1 = ConverterOperation.number(ConverterOperation.number(num1, inputUnit, ConverterUnit.numberBinary), ConverterUnit.numberBinary, ConverterUnit.numberInteger);
                        num2 = ConverterOperation.number(ConverterOperation.number(num2, inputUnit, ConverterUnit.numberBinary), ConverterUnit.numberBinary, ConverterUnit.numberInteger);
                        return ConverterOperation.number(
                            Operation.xor(num1, num2),
                            ConverterUnit.numberInteger,
                            inputUnit,
                        );
                    }
                    return Operation.xor(num1, num2);
                }
            );

            // Or operation
            input = input.replaceAllMapped(
                RegExp("($numbers)(${Keyboard.or})($numbers)"),
                (match) {
                    String num1 = match[1]!;
                    String num2 = match[3]!;
                    if (settings.programmerPage.numberType != NumberType.integer){
                        num1 = ConverterOperation.number(ConverterOperation.number(num1, inputUnit, ConverterUnit.numberBinary), ConverterUnit.numberBinary, ConverterUnit.numberInteger);
                        num2 = ConverterOperation.number(ConverterOperation.number(num2, inputUnit, ConverterUnit.numberBinary), ConverterUnit.numberBinary, ConverterUnit.numberInteger);
                        return ConverterOperation.number(
                            Operation.or(num1, num2),
                            ConverterUnit.numberInteger,
                            inputUnit,
                        );
                    }
                    return Operation.or(num1, num2);
                }
            );

            // Functions operation
            input = input.replaceAllMapped(
                RegExp('($functions)\\(($numbers)\\)'),
                (match) {
                    String num1 = match[2]!;
                    switch (match[1]!){
                        case Keyboard.fNot:
                            if (settings.programmerPage.numberType != NumberType.integer){
                                return ConverterOperation.number(
                                    Functions.not(ConverterOperation.number(ConverterOperation.number(num1, inputUnit, ConverterUnit.numberBinary), ConverterUnit.numberBinary, ConverterUnit.numberInteger)),
                                    ConverterUnit.numberInteger,
                                    inputUnit
                                );
                            }
                            return Functions.not(num1);
                    }
                    return "";
                }
            );

            // Remove unnecesary brackets
            input = input.replaceAllMapped(
                RegExp('(?<!$functions)\\(($numbers)\\)'),
                (match) => match[1]!
            );

            if (cache > 2000) break;
            ++cache;
        }
        if (settings.programmerPage.numberType == NumberType.integer && !input.isInteger()){
            input = double.parse(input).toInt().toString().toRealDigit();

        } else if (!input.isNumber()) {
            throw Exception("Output is not a number. [output: $input]");
        }
        return input;
    }

    void _scrollToCursorPosition() {
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
            final caretOffset = _getCaretPosition(renderBox, _input.selection.baseOffset);

            _inputScroll.animateTo(caretOffset, duration: const Duration(milliseconds: 10), curve: Curves.linear);
        }
    }

    double _getCaretPosition(RenderBox renderBox, int offset) {
        final caretOffset = _getCaretOffset(renderBox, offset);
        return renderBox.localToGlobal(Offset(caretOffset.dx, 0.0)).dx;
    }

    Offset _getCaretOffset(RenderBox renderBox, int offset) {
        final TextTheme textTheme = context.textTheme;
        final MediaQueryData mediaQueryData = context.mediaQueryData;
        TextStyle? inputStyle = textTheme.displayLarge;

        if (mediaQueryData.size.height <= 550){
            inputStyle = textTheme.headlineMedium;
        }
        final TextPainter textPainter = TextPainter(
            textDirection: TextDirection.ltr,
            text: TextSpan(text: _input.text, style: inputStyle),
            textScaleFactor: mediaQueryData.textScaleFactor,
        )..layout(minWidth: 0, maxWidth: double.infinity);
        final cursorOffset = textPainter.getOffsetForCaret(TextPosition(offset: offset), Rect.zero);
        return cursorOffset;
    }

    void _changeNumberType() async {
        const List<List<dynamic>> options = [
            ["Integer", NumberType.integer],
            ["Float 32", NumberType.float32],
            ["Float 64", NumberType.float64],
        ];
        final Settings settings = context.settings();
        final ColorScheme colorScheme = context.colorScheme;

        Widget builder(BuildContext context){
            Widget content = Material(
                color: Colors.transparent,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(options.length, (index) {
                        final List<dynamic> option = options[index];

                        ShapeBorder shape = RoundedRectangleBorder(borderRadius: BorderRadius.only(
                            topLeft    : Radius.circular(index == 0? 12 : 0),
                            topRight   : Radius.circular(index == 0? 12 : 0),
                            bottomLeft : Radius.circular(index == options.length-1? 12 : 0),
                            bottomRight: Radius.circular(index == options.length-1? 12 : 0),
                        ));

                        return CheckboxListTile(
                            shape: shape,
                            tileColor: colorScheme.secondaryContainer,
                            title: Text(option[0]),
                            value: settings.programmerPage.numberType == (option[1] as NumberType),
                            onChanged: (value){
                                settings.programmerPage.numberType = (option[1] as NumberType);
                                context.navigateBack();
                            }
                        );
                    }),
                ),
            );

            List<Widget> actions = [TextButton(
                child: const Text("Close"),
                onPressed: () => context.navigateBack()
            )];

            return AlertDialog(
                scrollable: true,
                icon: const Icon(Icons.pin_outlined),
                title: const Text("Number type"),
                actions: actions,
                content: content,
            );
        }

        await showDialog(
            context: context,
            builder: builder
        );

        if (_showBinaries){
            _realInput = _output.value = _input.text = "";
            _input.selection = TextSelection.fromPosition(const TextPosition(offset: 0));
        } else {
            _operate("", false);
        }
        setState((){});
    }

    void _updateInputRadix(Radix value){
        final Settings settings = context.settings();
        ConverterUnit inputUnit = ConverterUnit.numberInteger;

        switch (settings.programmerPage.numberType){
            case NumberType.integer: break;
            case NumberType.float32: inputUnit = ConverterUnit.numberFloat32;
            case NumberType.float64: inputUnit = ConverterUnit.numberFloat64;
        }

        switch (value){
            case Radix.dec:
                if (settings.programmerPage.inputRadix != Radix.dec) {
                    _realInput = _output.value;
                    _input.text = _realInput.mathFormat(settings: settings, scientificNotation: false);
                    _input.selection = TextSelection.fromPosition(TextPosition(offset: _input.text.length));
                }
            case Radix.hex:
                if (settings.programmerPage.inputRadix != Radix.hex) {
                    _realInput = _output.value.isEmpty? "" : ConverterOperation.number(_output.value, inputUnit, ConverterUnit.numberHexadecimal);
                    _input.text = _realInput.mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space);
                    _input.selection = TextSelection.fromPosition(TextPosition(offset: _input.text.length));
                }
            case Radix.oct:
                if (settings.programmerPage.inputRadix != Radix.oct) {
                    _realInput = _output.value.isEmpty? "" : ConverterOperation.number(_output.value, inputUnit, ConverterUnit.numberOctal);
                    _input.text = _realInput.mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space);
                    _input.selection = TextSelection.fromPosition(TextPosition(offset: _input.text.length));
                }
            case Radix.bin:
                if (settings.programmerPage.inputRadix != Radix.bin) {
                    _realInput = _output.value.isEmpty? "" : ConverterOperation.number(_output.value, inputUnit, ConverterUnit.numberBinary);
                    _input.text = _realInput.mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space);
                    _input.selection = TextSelection.fromPosition(TextPosition(offset: _input.text.length));
                }
        }
        settings.programmerPage.inputRadix = value;
    }

    void _changeInputRadix() async {
        const List<List<dynamic>> options = [
            ["Decimal", Radix.dec],
            ["Hexadecimal", Radix.hex],
            ["Octal", Radix.oct],
            ["Binary", Radix.bin],
        ];
        final Settings settings = context.settings();
        final ColorScheme colorScheme = context.colorScheme;

        Widget builder(BuildContext context){
            List<Widget> actions = [TextButton(
                onPressed: () => context.navigateBack(),
                child: const Text("Close")
            )];

            Widget content = Material(
                color: Colors.transparent,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(options.length, (index){
                        List<dynamic> option = options[index];

                        ShapeBorder shape = RoundedRectangleBorder(borderRadius: BorderRadius.only(
                            topLeft    : Radius.circular(index == 0? 12 : 0),
                            topRight   : Radius.circular(index == 0? 12 : 0),
                            bottomLeft : Radius.circular(index == options.length-1? 12 : 0),
                            bottomRight: Radius.circular(index == options.length-1? 12 : 0),
                        ));

                        return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: RadioListTile(
                                shape: shape,
                                tileColor: colorScheme.secondaryContainer,
                                title: Text(option[0]),
                                value: option[1] as Radix,
                                groupValue: settings.programmerPage.inputRadix,
                                onChanged: (value){
                                    _updateInputRadix(value!);
                                    context.navigateBack();
                                }
                            ),
                        );
                    }),
                ),
            );

            return AlertDialog(
                scrollable: true,
                icon: const Icon(Icons.pin_outlined),
                title: const Text("Radix/base input"),
                actions: actions,
                content: content,
            );
        }

        await showDialog(
            context: context,
            builder: builder
        );

        setState(() {});
    }

    void _changeMode(){
        final Settings settings = context.settings();

        if (!_showBinaries){
            if (_output.value.isNotEmpty){

                ConverterUnit inputUnit = ConverterUnit.numberInteger;
                switch (settings.programmerPage.numberType){
                    case NumberType.integer: break;
                    case NumberType.float32: inputUnit = ConverterUnit.numberFloat32; break;
                    case NumberType.float64: inputUnit = ConverterUnit.numberFloat64; break;
                }
                String binary = ConverterOperation.number(_output.value, inputUnit, ConverterUnit.numberBinary);
                if (settings.programmerPage.numberType == NumberType.float32 && binary.length > 32){
                    _output.value = ConverterOperation.number(binary.substring(binary.length - 32), ConverterUnit.numberBinary, inputUnit);
                } else if (binary.length > 64) {
                    _output.value = ConverterOperation.number(binary.substring(binary.length - 64), ConverterUnit.numberBinary, inputUnit);
                }

                switch (settings.programmerPage.inputRadix){
                    case Radix.dec:
                        _realInput = _output.value;
                        _input.text = _realInput.mathFormat(settings: settings);
                    case Radix.hex:
                        _realInput = ConverterOperation.number(_output.value, inputUnit, ConverterUnit.numberHexadecimal);
                        _input.text = _realInput.mathFormat(isHexNumber: true, minimumChar: 4, groupingFormat: NumberFormatGrouping.space);
                    case Radix.oct:
                        _realInput = ConverterOperation.number(_output.value, inputUnit, ConverterUnit.numberOctal);
                        _input.text = _realInput.mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space);
                    case Radix.bin:
                        _realInput = ConverterOperation.number(_output.value, inputUnit, ConverterUnit.numberBinary);
                        _input.text = _realInput.mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space);
                }
                _input.selection = TextSelection.fromPosition(TextPosition(offset: _input.text.length));
            } else {
                _realInput = _input.text = "";
                _input.selection = TextSelection.fromPosition(const TextPosition(offset: 0));
            }
        }
        setState(() => _showBinaries = !_showBinaries);
    }

    @override
    void didChangeDependencies(){
        super.didChangeDependencies();

        final Settings settings = context.settings();

        _realInput = settings.programmerPage.input;
        _input.text = _realInput.mathFormat(settings: settings, scientificNotation: false);
        _input.selection = TextSelection.fromPosition(TextPosition(offset: _input.text.length));
        _operate("", false);
    }

    @override
    void dispose(){
        _input.dispose();
        _inputScroll.dispose();
        _timer?.cancel();
        super.dispose();
    }

    Widget _appBar(){
        List<Widget> actions = [IconButton(
            onPressed: () => context.navigate(builder: (context) => const HistoryPage(page: Routes.programmer)),
            icon: const Icon(Icons.history_outlined)
        )];

        return SliverAppBar(
            title: const Text("Programmer"),
            actions: [...actions, const SizedBox(width: 8)],
            pinned: true
        );
    }

    Widget _body(){
        const List<List<String>> keys = [
            [Keyboard.inputRadix, Keyboard.openBracket, Keyboard.closeBracket, Keyboard.clear, Keyboard.delete],
            [Keyboard.hex_f, Keyboard.fNot, Keyboard.modulus, Keyboard.leftShift, Keyboard.rightShift],
            [Keyboard.hex_e, Keyboard.or, Keyboard.and, Keyboard.xor, Keyboard.power],
            [Keyboard.hex_d, Keyboard.key_7, Keyboard.key_8, Keyboard.key_9, Keyboard.division],
            [Keyboard.hex_c, Keyboard.key_4, Keyboard.key_5, Keyboard.key_6, Keyboard.multiply],
            [Keyboard.hex_b, Keyboard.key_1, Keyboard.key_2, Keyboard.key_3, Keyboard.min],
            [Keyboard.hex_a, Keyboard.point, Keyboard.key_0, Keyboard.equal, Keyboard.add]
        ];
        final Settings settings = context.settings(true);
        final TextTheme textTheme = context.textTheme;
        final ColorScheme colorScheme = context.colorScheme;
        TextStyle? inputStyle = textTheme.displayLarge;

        if (MediaQuery.of(context).size.height <= 550){
            inputStyle = textTheme.headlineMedium;
        }

        Widget inputBox = TextFormField(
            controller: _input,
            onChanged: (value){
                _realInput = value;
                _operate("");
            },
            decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                isCollapsed: true
            ),
            style: inputStyle,
            textAlign: TextAlign.end,
            keyboardType: TextInputType.none,
            readOnly: _showBinaries,
            scrollController: _inputScroll,
        );

        Widget outputBox = SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder<String>(
                valueListenable: _output,
                builder: (context, output, _) {

                    ConverterUnit inputUnit = ConverterUnit.numberInteger;
                    switch (settings.programmerPage.numberType){
                        case NumberType.integer: break;
                        case NumberType.float32: inputUnit = ConverterUnit.numberFloat32;
                        case NumberType.float64: inputUnit = ConverterUnit.numberFloat64;
                    }

                    List<List<dynamic>> options = [
                        [Radix.dec, ""],
                        [Radix.hex, ""],
                        [Radix.oct, ""],
                        [Radix.bin, ""],
                    ];
                    if (output.isNotEmpty){
                        options = [
                            [Radix.dec, output.mathFormat(settings: settings)],
                            [Radix.hex, ConverterOperation.number(output, inputUnit, ConverterUnit.numberHexadecimal).mathFormat(isHexNumber: true, minimumChar: 4, groupingFormat: NumberFormatGrouping.space)],
                            [Radix.oct, ConverterOperation.number(output, inputUnit, ConverterUnit.numberOctal).mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space)],
                            [Radix.bin, ConverterOperation.number(output, inputUnit, ConverterUnit.numberBinary).mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space)],
                        ];
                    }

                    return Column(children: List.generate(options.length, (index){
                        bool selected = settings.programmerPage.inputRadix == options[index][0];
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                                Flexible(child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                        options[index][1],
                                        style: TextStyle(
                                            fontWeight: selected? FontWeight.bold : null,
                                            color: selected? colorScheme.primary : null
                                        ),
                                    )
                                )),
                                const SizedBox(width: 8),
                                SizedBox(
                                    width: 36,
                                    child: Text(
                                        (options[index][0] as Radix).name.toUpperCase(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: selected? colorScheme.primary : null
                                        )
                                    )
                                )
                            ],
                        );
                    }));
                }
            ),
        );

        Widget actionOptions = Row(children: [
            IconButton(
                tooltip: _showBinaries? "Calculator" : "Binaries",
                onPressed: _changeMode,
                icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _showBinaries
                        ? const Icon(Icons.calculate_outlined, key: ValueKey("calc"))
                        : const Icon(Icons.dialpad_outlined, key: ValueKey("func"))
                )
            ),
            // BUG: Float32 & Float64 cause "Out of Memory"
            // TextButton(
            //     onPressed: _changeNumberType,
            //     child: Text((){
            //         switch (settings.programmerPage.numberType){
            //             case NumberType.integer: return "Integer";
            //             case NumberType.float32: return "Float32";
            //             case NumberType.float64: return "Float64";
            //         }
            //     }()),
            // ),
            if (_showBinaries) ...[
                const Spacer(),
                TextButton(
                    onPressed: () => _operateBinariesShift(Keyboard.leftShift),
                    child: const Text("LSH")
                ),
                TextButton(
                    onPressed: () => _operateBinariesShift(Keyboard.rightShift),
                    child: const Text("RSH")
                ),
                OutlinedButton(
                    onPressed: () => _operate(Keyboard.clear),
                    style: TextButton.styleFrom(
                        foregroundColor: colorScheme.error
                    ),
                    child: const Text("C"),
                ),
            ],
            if (settings.memoryButton && !_showBinaries) ...<String>[
                Keyboard.memory,
                Keyboard.memoryClear,
                Keyboard.memoryRecall,
                Keyboard.memoryPlus,
                Keyboard.memoryMin
            ].map<Widget>((m) => Expanded(child: TextButton(
                onPressed: () => _operate(m),
                child: Text(m)
            ))).toList()
        ]);

        Widget inputOutput = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                    inputBox,
                    outputBox,
                    const SizedBox(height: 8),
                    actionOptions
                ]
            ),
        );

        Widget binariesButtons = Scrollbar(child: SingleChildScrollView(child: ValueListenableBuilder<String>(
            valueListenable: _output,
            builder: (context, output, _) {
                int count = settings.programmerPage.numberType == NumberType.float32? 4 : 8;

                ConverterUnit inputUnit = ConverterUnit.numberInteger;
                switch (settings.programmerPage.numberType){
                    case NumberType.integer: break;
                    case NumberType.float32: inputUnit = ConverterUnit.numberFloat32;
                    case NumberType.float64: inputUnit = ConverterUnit.numberFloat64;
                }

                if (output.isEmpty){
                    output = "0".padLeft(settings.programmerPage.numberType == NumberType.float32? 32 : 64, "0");
                } else {
                    output = ConverterOperation.number(output, inputUnit, ConverterUnit.numberBinary).padLeft(settings.programmerPage.numberType == NumberType.float32? 32 : 64, "0");
                }

                return Column(children: List.generate(count, (index) => Column(children: [
                    if (index > 0) const Divider(height: 1),
                    Row(children: List.generate(2, (index2) => Expanded(child: Row(children: [
                        Container(
                            width: (context.mediaQueryData.size.width - 16) / 2 / 4,
                            margin: const EdgeInsets.only(left: 2.0, right: 2.0, top: 16.0),
                            // g(x,y,z) = 8x-8y-4z = 4(2x-2y-z) = 4(2(x-y)-z)
                            child: Center(child: Text("${4 * (2 * (count - index) - index2)}", style: const TextStyle(fontWeight: FontWeight.bold))),
                        ),
                    ])))),
                    Row(children: List.generate(8, (index2) => Expanded(child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: TextButton(
                            // f(i,j) = 8i+j
                            child: Text(output[8 * index + index2]),
                            onPressed: () => _operateBinaries(output, 8 * index + index2, output[8 * index + index2]),
                        )
                    )))),
                ])));
            }
        )));

        Widget generalButtons = Column(children: List.generate(keys.length, (index) => Flexible(child: Row(children: List.generate(keys[index].length, (index2) {
            bool disabled = false;
            switch (settings.programmerPage.inputRadix){
                case Radix.hex: disabled = [Keyboard.point].contains(keys[index][index2]);
                case Radix.dec: disabled = [
                    Keyboard.hex_a, Keyboard.hex_b, Keyboard.hex_c,
                    Keyboard.hex_d, Keyboard.hex_e, Keyboard.hex_f,
                    if (settings.programmerPage.numberType == NumberType.integer) Keyboard.point
                ].contains(keys[index][index2]);
                case Radix.oct: disabled = [
                    Keyboard.hex_a, Keyboard.hex_b, Keyboard.hex_c,
                    Keyboard.hex_d, Keyboard.hex_e, Keyboard.hex_f,
                    Keyboard.point, Keyboard.key_9, Keyboard.key_8
                ].contains(keys[index][index2]);
                case Radix.bin: disabled = [
                    Keyboard.hex_a, Keyboard.hex_b, Keyboard.hex_c,
                    Keyboard.hex_d, Keyboard.hex_e, Keyboard.hex_f,
                    Keyboard.point, Keyboard.key_9, Keyboard.key_8,
                    Keyboard.key_7, Keyboard.key_6, Keyboard.key_5,
                    Keyboard.key_4, Keyboard.key_3, Keyboard.key_2
                ].contains(keys[index][index2]);
            }

            TextStyle? textStyle = textTheme.headlineMedium?.copyWith(color: disabled? colorScheme.onSurface.withOpacity(0.33) : null);
            Widget child = Text(keys[index][index2].toUpperCase(), style: textStyle);
            ButtonStyle style = TextButton.styleFrom(
                backgroundColor: disabled? null : Keyboard.isNumber(keys[index][index2]) || Keyboard.isHexNumber(keys[index][index2])
                    ? colorScheme.primaryContainer
                    : keys[index][index2] == Keyboard.equal? colorScheme.tertiaryContainer : null,
                foregroundColor: disabled? colorScheme.onSurface.withOpacity(0.33) : Keyboard.isNumber(keys[index][index2]) || Keyboard.isHexNumber(keys[index][index2])
                    ? colorScheme.onPrimaryContainer
                    : keys[index][index2] == Keyboard.equal? colorScheme.onTertiaryContainer : null,
                minimumSize: const Size(double.infinity, double.infinity),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(index == 0 && index2 == 0? 10 : 4),
                    topRight: Radius.circular(index == 0 && index2 == keys[index].length-1? 10 : 4),
                    bottomLeft: Radius.circular(index == keys.length-1 && index2 == 0? 10 : 4),
                    bottomRight: Radius.circular(index == keys.length-1 && index2 == keys[index].length-1? 10 : 4),
                ))
            );

            switch (keys[index][index2]){
                case Keyboard.clear: child = Text("C", style: textStyle?.copyWith(color: colorScheme.error));
                case Keyboard.inputRadix: child = Text(settings.programmerPage.inputRadix.name.toUpperCase(), style: textStyle);
                case Keyboard.min: child = Text("−", style: textStyle);
                case Keyboard.delete: child = Icon(
                    Icons.backspace_outlined,
                    size: textStyle!.fontSize,
                    color: colorScheme.error
                );
                case Keyboard.swap: child = Icon(
                    Icons.swap_vert,
                    size: textStyle!.fontSize,
                    color: textStyle.color,
                );
                case Keyboard.point:
                    if (settings.numberFormatDecimal == NumberFormatDecimals.comma)
                        child = Text(",", style: textStyle);
            }

            return Expanded(child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: TextButton(
                    onPressed: disabled? null : () => _operate(keys[index][index2]),
                    style: style,
                    child: FittedBox(child: child)
                ),
            ));
        })))));

        Widget keyboard = Flexible(child: Card(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Container(
                constraints: const BoxConstraints(maxHeight: 75 * 6, minHeight: 0),
                padding: const EdgeInsets.all(2.0),
                child: _showBinaries? binariesButtons : generalButtons
            )
        ));

        Widget body = SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                    inputOutput,
                    keyboard
                ]
            )
        );

        body = CustomScrollView(slivers: [
            _appBar(),
            body
        ]);

        return SafeArea(
            top: false,
            child: body
        );
    }

    @override
    Widget build(BuildContext context) {
        context.changeSystemUI();

        return Scaffold(
            drawer: const NavigationDrawerWidget(selectedIndex: 3),
            body: _body()
        );
    }
}