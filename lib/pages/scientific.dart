// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import "dart:math" as math;

import 'package:calculator/utils/build_context.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/enums.dart';
import '../widgets/drawer.dart';
import '../utils/operations.dart';
import '../utils/functions.dart';
import '../utils/converter.dart';
import '../utils/string.dart';
import '../data/settings.dart';
import '../data/keyboard.dart';
import '../data/history.dart';
import '../data/converter.dart';
import 'history.dart';

class ScientificPage extends StatefulWidget {
    const ScientificPage({super.key});

    @override
    State<ScientificPage> createState() => _ScientificPageState();
}

class _ScientificPageState extends State<ScientificPage> {

    final TextEditingController _input = TextEditingController();
    final ScrollController _inputScroll = ScrollController();
    final ValueNotifier<String> _output = ValueNotifier("");
    String _realInput = "";
    Timer? _timer;
    bool _showFunctions = false;
    bool _invFunction = false;
    bool _hypFunction = false;

    void _saveToHistory(){
        final Settings settings = context.settings();

        if (_output.value.isEmpty || _output.value == _realInput || _realInput.isEmpty) return;
        ScientificHistory history = ScientificHistory(
            input: _realInput,
            output: _output.value,
            angleUnit: settings.scientificPage.angleUnit,
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
                RegExp("($number|[\\)${Keyboard.percentage}${Keyboard.factorial}${Keyboard.eurel}${Keyboard.pi}])([\\(${Keyboard.eurel}${Keyboard.pi}${Keyboard.squareRoot}]|${Keyboard.functionsRegex()})"),
                (match) => match[1]! + Keyboard.multiply + match[2]!
            )
            .replaceAllMapped(
                RegExp("([\\)${Keyboard.percentage}${Keyboard.pi}${Keyboard.factorial}${Keyboard.eurel}])($number|[\\(${Keyboard.pi}${Keyboard.eurel}${Keyboard.squareRoot}]|${Keyboard.functionsRegex()})"),
                (match) => match[1]! + Keyboard.multiply + match[2]!
            )
            .replaceAll(RegExp("(?<!c|s)${Keyboard.eurel}(?!il|c)"), math.e.toString())
            .replaceAll(Keyboard.pi, math.pi.toString())
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
            Settings.numberFormatGroupingChar(settings.numberFormatGrouping)
        );

        if (cursorPosition <= 0) cursorPosition = 0;
        if (cursorPosition > _realInput.length) cursorPosition = _realInput.length;
        String prefix = _realInput.substring(0, cursorPosition);
        String suffix = _realInput.substring(cursorPosition);

        switch (key){
            case Keyboard.equal:
                _saveToHistory();
                setState(() => _realInput = _output.value);
                _input.text = _realInput.mathFormat(settings: settings, scientificNotation: false);
                _input.selection = TextSelection.fromPosition(TextPosition(offset: _input.text.length));
                _operate("", false);
                return;
            case Keyboard.clear:
                _realInput = "";
                cursorPosition = 0;
                break;
            case Keyboard.delete:
                if (cursorPosition > 0){
                    var re = RegExp("(?:(?:${Keyboard.functionsRegex()})\\(?|${Keyboard.modulus})\$");
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
                break;
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
                _realInput = prefix + settings.memoryValue + suffix;
                cursorPosition += settings.memoryValue.length;
                break;
            case Keyboard.powerOfTwo:
                _realInput = "$prefix${Keyboard.power}2$suffix";
                cursorPosition += "${Keyboard.power}2".length;
                break;
            case Keyboard.tenPower:
                _realInput = "${prefix}10${Keyboard.power}$suffix";
                cursorPosition += key.length;
                break;
            case Keyboard.eurelPower:
                _realInput = prefix + Keyboard.eurel + Keyboard.power + suffix;
                cursorPosition += (Keyboard.eurel + Keyboard.power).length;
                break;
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
            _output.value = _calculate(_realInput);
            if (saveToHistory) _timer = Timer(const Duration(seconds: 3), () => _saveToHistory());
        } catch (e){
            _timer?.cancel();
            debugPrint(e.toString());
            _output.value = "";
        }
        cursorPosition += _countFormatNumberChar(
            _realInput.mathFormat(settings: settings, scientificNotation: false),
            cursorPosition,
            Settings.numberFormatGroupingChar(settings.numberFormatGrouping)
        );
        _input.text = _realInput.mathFormat(settings: settings, scientificNotation: false);
        _input.selection = TextSelection.fromPosition(TextPosition(offset: cursorPosition));
        settings.scientificPage.input = _realInput;

        _scrollToCursorPosition();
    }

    String _calculate(String input){
        const String numbers = '(?<!\\d|${Keyboard.percentage}|${Keyboard.factorial}|\\))[-+]?(?:\\d*\\.)?\\d+';
        final Settings settings = context.settings();
        final String functions = Keyboard.functionsRegex();
        final RegExp regex = RegExp(
            "\\($numbers\\)|"
            "${Keyboard.squareRoot}(?:$numbers)|"
            "(?:$numbers)[${Keyboard.percentage}${Keyboard.factorial}]|"
            "(?:$numbers)(?:[-+${Keyboard.multiply}${Keyboard.division}\\${Keyboard.power}]|${Keyboard.modulus})(?:$numbers)"
        );
        int cache = 0;
        input = _repairInput(input).replaceAll(RegExp(r"[ \n]"), "").mathSimplify();
        while (regex.hasMatch(input)){

            // Square root operation
            input = input.replaceAllMapped(
                RegExp("${Keyboard.squareRoot}($numbers)"),
                (match) => Operation.sqrt(match[1]!)
            );

            // Percentage & factorial operation
            input = input.replaceAllMapped(
                RegExp("($numbers)([${Keyboard.percentage}${Keyboard.factorial}])"),
                (match) => switch (match[2]){
                    Keyboard.percentage => Operation.percentage(match[1]!),
                    Keyboard.factorial => Operation.factorial(match[1]!),
                    _ => ''
                }
            );

            // Exponential operation
            input = input.reverse()
            .replaceAllMapped(
                RegExp("(\\d+\\.?\\d*[-+]?(?!\\d))(\\${Keyboard.power})\\)(\\d+\\.?\\d*[-]?(?!\\d))\\("),
                (match) => Operation.power(match[3]!.reverse(), match[1]!.reverse()).reverse()
            )
            .replaceAllMapped(
                RegExp("(\\d+\\.?\\d*[-+]?(?!\\d))(\\${Keyboard.power})(\\d+\\.?\\d*[+]?(?!\\d))"),
                (match) => Operation.power(match[3]!.reverse(), match[1]!.reverse()).reverse()
            )
            .reverse();

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

            // Functions operation
            input = input.replaceAllMapped(
                RegExp('($functions)\\(($numbers)\\)'),
                (match) {
                    String radianValue = settings.scientificPage.angleUnit == ConverterUnit.angleRadian
                        ? match[2]!
                        : ConverterOperation.angle(match[2]!, settings.scientificPage.angleUnit, ConverterUnit.angleRadian)
                    ;
                    switch (match[1]!){
                        case Keyboard.fAbs: return Functions.abs(match[2]!);
                        case Keyboard.fLog: return Functions.log(match[2]!);
                        case Keyboard.fLn: return Functions.ln(match[2]!);
                        case Keyboard.fCeil: return Functions.ceil(match[2]!);
                        case Keyboard.fFloor: return Functions.floor(match[2]!);
                        case Keyboard.fRound: return Functions.round(match[2]!);
                        case Keyboard.fSin: return Functions.sin(radianValue);
                        case Keyboard.fCos: return Functions.cos(radianValue);
                        case Keyboard.fTan: return Functions.tan(radianValue);
                        case Keyboard.fCsc: return Functions.csc(radianValue);
                        case Keyboard.fSec: return Functions.sec(radianValue);
                        case Keyboard.fCot: return Functions.cot(radianValue);
                        case Keyboard.fSinHyper: return Functions.sinh(radianValue);
                        case Keyboard.fCosHyper: return Functions.cosh(radianValue);
                        case Keyboard.fTanHyper: return Functions.tanh(radianValue);
                        case Keyboard.fCscHyper: return Functions.csch(radianValue);
                        case Keyboard.fSecHyper: return Functions.sech(radianValue);
                        case Keyboard.fCotHyper: return Functions.coth(radianValue);
                        case Keyboard.fSinInverse: return Functions.asin(radianValue);
                        case Keyboard.fCosInverse: return Functions.acos(radianValue);
                        case Keyboard.fTanInverse: return Functions.atan(radianValue);
                        case Keyboard.fCscInverse: return Functions.acsc(radianValue);
                        case Keyboard.fSecInverse: return Functions.asec(radianValue);
                        case Keyboard.fCotInverse: return Functions.acot(radianValue);
                        case Keyboard.fSinHyperInverse: return Functions.asinh(radianValue);
                        case Keyboard.fCosHyperInverse: return Functions.acosh(radianValue);
                        case Keyboard.fTanHyperInverse: return Functions.atanh(radianValue);
                        case Keyboard.fCscHyperInverse: return Functions.acsch(radianValue);
                        case Keyboard.fSecHyperInverse: return Functions.asech(radianValue);
                        case Keyboard.fCotHyperInverse: return Functions.acoth(radianValue);
                        default: return '';
                    }
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
        if (!input.isNumber()) throw Exception("Output is not a number [output: $input]");
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

        if (mediaQueryData.size.height <= 450){
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

    void _changeAngleUnit() async {
        const List<ConverterUnit> options = [
            ConverterUnit.angleDegree,
            ConverterUnit.angleRadian
        ];
        final Settings settings = context.settings();
        final ColorScheme colorScheme = context.colorScheme;

        Widget builder(BuildContext context){
            Widget content = Material(
                color: Colors.transparent,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(options.length, (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: RadioListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                                topLeft    : Radius.circular(index == 0? 12 : 0),
                                topRight   : Radius.circular(index == 0? 12 : 0),
                                bottomLeft : Radius.circular(index == options.length-1? 12 : 0),
                                bottomRight: Radius.circular(index == options.length-1? 12 : 0),
                            )),
                            tileColor: colorScheme.secondaryContainer,
                            title: Text(options[index].name),
                            secondary: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4)
                                ),
                                child: Text(
                                    options[index].symbol,
                                    style: TextStyle(color: colorScheme.onPrimary),
                                )
                            ),
                            value: options[index],
                            groupValue: settings.scientificPage.angleUnit,
                            onChanged: (value){
                                settings.scientificPage.angleUnit = value!;
                                context.navigateBack();
                            }
                        ),
                    )),
                ),
            );

            List<Widget> actions = [TextButton(
                onPressed: () => context.navigateBack(),
                child: const Text("Close")
            )];

            return AlertDialog(
                scrollable: true,
                icon: const Icon(MdiIcons.angleAcute),
                title: const Text("Angle"),
                actions: actions,
                content: content,
            );
        }

        await showDialog(
            context: context,
            builder: builder
        );
        setState(() {});
        _operate("", false);
    }

    @override
    void didChangeDependencies(){
        super.didChangeDependencies();

        final Settings settings = context.settings();

        _realInput = settings.scientificPage.input;
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
            onPressed: () => context.navigate(builder: (context) => const HistoryPage(page: Routes.scientific)),
            icon: const Icon(Icons.history_outlined)
        )];

        return SliverAppBar(
            title: const Text("Scientific"),
            actions: [...actions, const SizedBox(width: 8)],
            pinned: true
        );
    }

    Widget _body(){
        final Settings settings = context.settings(true);
        final TextTheme textTheme = context.textTheme;
        final ColorScheme colorScheme = context.colorScheme;
        TextStyle? inputStyle = textTheme.displayLarge;
        if (MediaQuery.of(context).size.height <= 450){
            inputStyle = textTheme.headlineMedium;
        }
        List<List<String>> keys = [
            [Keyboard.modulus, Keyboard.openBracket, Keyboard.closeBracket, Keyboard.clear, Keyboard.delete],
            [Keyboard.percentage, Keyboard.tenPower, Keyboard.powerOfTwo, Keyboard.eurelPower, Keyboard.power],
            [Keyboard.factorial, Keyboard.key_7, Keyboard.key_8, Keyboard.key_9, Keyboard.division],
            [Keyboard.eurel, Keyboard.key_4, Keyboard.key_5, Keyboard.key_6, Keyboard.multiply],
            [Keyboard.pi, Keyboard.key_1, Keyboard.key_2, Keyboard.key_3, Keyboard.min],
            [Keyboard.squareRoot, Keyboard.point, Keyboard.key_0, Keyboard.equal, Keyboard.add]
        ];

        if (_showFunctions){
            keys = [
                [Keyboard.fAbs, Keyboard.fLog, Keyboard.fLn],
                [Keyboard.fCeil, Keyboard.fRound, Keyboard.fFloor],

                if (!_hypFunction && !_invFunction) ...[
                    [Keyboard.fSin, Keyboard.fCos, Keyboard.fTan],
                    [Keyboard.fCsc, Keyboard.fSec, Keyboard.fCot]
                ],

                if (_hypFunction && !_invFunction) ...[
                    [Keyboard.fSinHyper, Keyboard.fCosHyper, Keyboard.fTanHyper],
                    [Keyboard.fCscHyper, Keyboard.fSecHyper, Keyboard.fCotHyper]
                ],

                if (!_hypFunction && _invFunction) ...[
                    [Keyboard.fSinInverse, Keyboard.fCosInverse, Keyboard.fTanInverse],
                    [Keyboard.fCscInverse, Keyboard.fSecInverse, Keyboard.fCotInverse]
                ],

                if (_hypFunction && _invFunction) ...[
                    [Keyboard.fSinHyperInverse, Keyboard.fCosHyperInverse, Keyboard.fTanHyperInverse],
                    [Keyboard.fCscHyperInverse, Keyboard.fSecHyperInverse, Keyboard.fCotHyperInverse]
                ],
            ];
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
            scrollController: _inputScroll,
        );

        Widget outputBox = SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder<String>(
                valueListenable: _output,
                builder: (context, output, _) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                        double.tryParse(output) == null || output == _realInput
                            ? ''
                            : output.mathFormat(settings: settings),
                        textAlign: TextAlign.end,
                        style: textTheme.headlineMedium
                    ),
                )
            ),
        );

        Widget actionOptions = Row(children: [
            IconButton(
                tooltip: _showFunctions? "Calculator" : "Functions",
                onPressed: () => setState(() => _showFunctions = !_showFunctions),
                icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _showFunctions
                        ? const Icon(Icons.calculate_outlined, key: ValueKey("calc"))
                        : const Icon(Icons.functions_outlined, key: ValueKey("func"))
                )
            ),
            TextButton(
                onPressed: _changeAngleUnit,
                child: Text((() => switch (settings.scientificPage.angleUnit.name){
                    "Radian" => "RAD",
                    "Degree" => "DEG",
                    "Gradian" => "GON",
                    _ => ''
                })()),
            ),
            if (_showFunctions) ...[
                const Spacer(),
                FilterChip(
                    label: const Text("INV"),
                    selected: _invFunction,
                    onSelected: (value) => setState(() => _invFunction = value),
                ),
                const SizedBox(width: 4),
                FilterChip(
                    label: const Text("HYP"),
                    selected: _hypFunction,
                    onSelected: (value) => setState(() => _hypFunction = value),
                ),
            ],
            if (settings.memoryButton && !_showFunctions) ...<String>[
                Keyboard.memory,
                Keyboard.memoryClear,
                Keyboard.memoryRecall,
                Keyboard.memoryPlus,
                Keyboard.memoryMin
            ].map<Widget>((m) => Expanded(child: TextButton(
                onPressed: () => _operate(m),
                child: Text(m)
            ))).toList(),
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

        Widget keyboard = Flexible(child: Card(
            margin: const EdgeInsets.all(8),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Container(
                constraints: const BoxConstraints(maxHeight: 75 * 6, minHeight: 0),
                padding: const EdgeInsets.all(2.0),
                child: Column(children: List.generate(keys.length, (index) {
                    return Flexible(child: Row(children: List.generate(keys[index].length, (index2) {
                        TextStyle? textStyle = textTheme.headlineMedium;
                        Widget child = Text(keys[index][index2], style: textStyle);
                        ButtonStyle style = TextButton.styleFrom(
                            backgroundColor: Keyboard.isNumber(keys[index][index2])
                                ? colorScheme.primaryContainer
                                : keys[index][index2] == Keyboard.equal? colorScheme.tertiaryContainer : null,
                            foregroundColor: Keyboard.isNumber(keys[index][index2])
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
                            case Keyboard.modulus: child = Text("MOD", style: textStyle, maxLines: 1);
                            case Keyboard.clear: child = Text("C", style: textStyle?.copyWith(color: colorScheme.error));
                            case Keyboard.min: child = Text("−", style: textStyle);
                            case Keyboard.delete: child = Icon(
                                Icons.backspace_outlined,
                                size: textStyle!.fontSize,
                                color: colorScheme.error
                            );
                            case Keyboard.point:
                                if (settings.numberFormatDecimal == NumberFormatDecimals.comma)
                                    child = Text(",", style: textStyle);
                        }

                        return Expanded(child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TextButton(
                                onPressed: () => _operate(keys[index][index2]),
                                style: style,
                                child: FittedBox(child: child)
                            ),
                        ));
                      })),
                    );
                }))
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
            drawer: const NavigationDrawerWidget(selectedIndex: 1),
            body: _body()
        );
    }
}