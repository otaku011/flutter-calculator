import 'dart:async';

import 'package:calculator/utils/build_context.dart';
import 'package:flutter/material.dart';

import 'history.dart';
import '../data/enums.dart';
import '../widgets/drawer.dart';
import '../utils/operations.dart';
import '../utils/string.dart';
import '../data/settings.dart';
import '../data/keyboard.dart';
import '../data/history.dart';

class BasicPage extends StatefulWidget {
    const BasicPage({super.key});

    @override
    State<BasicPage> createState() => _BasicPageState();
}

class _BasicPageState extends State<BasicPage> {

    final TextEditingController _input = TextEditingController();
    final ScrollController _inputScroll = ScrollController();
    final ValueNotifier<String> _output = ValueNotifier("");
    String _realInput = "";
    Timer? _timer;

    void _saveToHistory(){
        if (_output.value.isEmpty || _output.value == _realInput || _realInput.isEmpty) return;
        BasicHistory history = BasicHistory(
            input: _realInput,
            output: _output.value,
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
        return input
            .replaceAllMapped(
                RegExp("($number|${Keyboard.percentage})(${Keyboard.squareRoot})"),
                (match) => match[1]! + Keyboard.multiply + match[2]!
            )
            .replaceAllMapped(
                RegExp("(${Keyboard.percentage})($number|${Keyboard.squareRoot})"),
                (match) => match[1]! + Keyboard.multiply + match[2]!
            );
    }

    void _showMemoryValue(){
        showDialog(
            context: context,
            builder: (context) => StatefulBuilder(builder: (context, setState) {

                Widget content = Text(
                    context.settings().memoryValue.mathFormat(settings: context.settings()),
                    style: context.textTheme.headlineMedium
                );

                List<Widget> actions = [
                    TextButton(
                        onPressed: (){ _operate(Keyboard.memoryClear); setState((){}); },
                        child: const Text("MC")
                    ),
                    FilledButton(
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
        final settings = context.settings();

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
            case Keyboard.delete:
                if (cursorPosition > 0){
                    _realInput = prefix.substring(0, cursorPosition-1) + suffix;
                    --cursorPosition;
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
                _realInput = prefix + settings.memoryValue + suffix;
                cursorPosition += settings.memoryValue.length;
            default:
                _realInput = prefix + key + suffix;
                cursorPosition += key.length;
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
        settings.basicPage.input = _realInput;

        _scrollToCursorPosition();
    }

    String _calculate(String input){
        const String numbers = '(?<!\\d|${Keyboard.percentage}|${Keyboard.factorial}|\\))[-+]?(?:\\d*\\.)?\\d+';
        final RegExp regex = RegExp(
            "${Keyboard.squareRoot}($numbers)|"
            "($numbers)${Keyboard.percentage}|"
            "($numbers)[-+${Keyboard.multiply}${Keyboard.division}]($numbers)"
        );
        int cache = 0;
        input = _repairInput(input).replaceAll(RegExp(r"[ \n]"), "").mathSimplify();
        while (regex.hasMatch(input)){
            // Square root operation
            input = input.replaceAllMapped(
                RegExp("${Keyboard.squareRoot}($numbers)"),
                (match) => Operation.sqrt(match[1]!)
            );

            // Percentage operation
            input = input.replaceAllMapped(
                RegExp("($numbers)${Keyboard.percentage}"),
                (match) => Operation.percentage(match[1]!)
            );

            // Division & multiplication operation
            input = input.replaceAllMapped(
                RegExp("($numbers)([${Keyboard.multiply}${Keyboard.division}])($numbers)"),
                (match) => switch (match[2]){
                    Keyboard.multiply => Operation.multiply(match[1]!, match[3]!),
                    Keyboard.division => Operation.division(match[1]!, match[3]!),
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
        final MediaQueryData mediaQuery = context.mediaQueryData;
        TextStyle? inputStyle = textTheme.displayLarge;

        if (mediaQuery.size.height <= 450){
            inputStyle = textTheme.headlineMedium;
        }

        final TextPainter textPainter = TextPainter(
            textDirection: TextDirection.ltr,
            text: TextSpan(text: _input.text, style: inputStyle),
            textScaleFactor: mediaQuery.textScaleFactor,
        )..layout(minWidth: 0, maxWidth: double.infinity);
        final cursorOffset = textPainter.getOffsetForCaret(TextPosition(offset: offset), Rect.zero);
        return cursorOffset;
    }

    @override
    void didChangeDependencies(){
        super.didChangeDependencies();

        final Settings settings = context.settings();

        _realInput = settings.basicPage.input;
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
            onPressed: () => context.navigate(builder: (context) => const HistoryPage(page: Routes.basic)),
            icon: const Icon(Icons.history_outlined)
        )];

        return SliverAppBar(
            title: const Text("Basic"),
            actions: [...actions, const SizedBox(width: 8)],
            pinned: true
        );
    }

    Widget _body(){
        const List<List<String>> keys = [
            [Keyboard.percentage, Keyboard.squareRoot, Keyboard.clear, Keyboard.delete],
            [Keyboard.key_7, Keyboard.key_8, Keyboard.key_9, Keyboard.division],
            [Keyboard.key_4, Keyboard.key_5, Keyboard.key_6, Keyboard.multiply],
            [Keyboard.key_1, Keyboard.key_2, Keyboard.key_3, Keyboard.min],
            [Keyboard.point, Keyboard.key_0, Keyboard.equal, Keyboard.add]
        ];
        final TextTheme textTheme = context.textTheme;
        final ColorScheme colorScheme = context.colorScheme;
        final Settings settings = context.settings(true);
        TextStyle? inputStyle = textTheme.displayLarge;

        if (MediaQuery.of(context).size.height <= 450){
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
                        output.isEmpty || output == _realInput
                            ? ''
                            :output.mathFormat(settings: settings),
                        textAlign: TextAlign.end,
                        style: textTheme.headlineMedium
                    ),
                )
            ),
        );

        Widget memory = Row(children: [
            Keyboard.memory,
            Keyboard.memoryClear,
            Keyboard.memoryRecall,
            Keyboard.memoryPlus,
            Keyboard.memoryMin
        ].map<Widget>((key) => Expanded(child: TextButton(
            onPressed: () => _operate(key),
            child: Text(key)
        ))).toList());

        Widget inputOutput = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                    inputBox,
                    outputBox,
                    if (settings.memoryButton) ...[
                        const SizedBox(height: 8),
                        memory
                    ]
                ]
            ),
        );

        Widget keyboard = Flexible(child: Card(
            margin: const EdgeInsets.all(8),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Container(
                constraints: const BoxConstraints(maxHeight: 75 * 5, minHeight: 0),
                padding: const EdgeInsets.all(2.0),
                child: Column(children: List.generate(keys.length, (index) => Flexible(child: Row(children: List.generate(keys[index].length, (index2) {
                    TextStyle? textStyle = textTheme.headlineMedium;
                    Widget child = Text(keys[index][index2], style: textStyle);
                    ButtonStyle buttonStyle = TextButton.styleFrom(
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
                        case Keyboard.clear: child = Text("C", style: textStyle?.copyWith(color: colorScheme.error));
                        case Keyboard.min: child = Text("−", style: textStyle);
                        case Keyboard.point:
                            if (settings.numberFormatDecimal == NumberFormatDecimals.comma) {
                                child = Text(",", style: textStyle);
                            }
                        case Keyboard.delete: child = Icon(
                            Icons.backspace_outlined,
                            size: textStyle!.fontSize,
                            color: colorScheme.error
                        );
                    }

                    return Expanded(child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: TextButton(
                            onPressed: () => _operate(keys[index][index2]),
                            style: buttonStyle,
                            child: FittedBox(child: child)
                        ),
                    ));
                })))))
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
            drawer: const NavigationDrawerWidget(selectedIndex: 0),
            body: _body()
        );
    }
}