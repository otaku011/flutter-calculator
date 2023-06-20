// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';

import 'package:calculator/utils/build_context.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/converter.dart';
import '../data/enums.dart';
import '../widgets/drawer.dart';
import '../utils/operations.dart';
import '../utils/converter.dart';
import '../utils/string.dart';
import '../data/settings.dart';
import '../data/keyboard.dart';
import '../data/history.dart';
import 'history.dart';

class ConverterPage extends StatefulWidget {
    const ConverterPage({super.key});

    @override
    State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {

    final TextEditingController _input = TextEditingController();
    final ScrollController _inputScroll = ScrollController();
    final ValueNotifier<String> _output = ValueNotifier("");
    String _realInput = "";
    Timer? _timer;

    void _saveToHistory(){
        final Settings settings = context.settings();

        if (_output.value.isEmpty || _output.value == _realInput || _realInput.isEmpty) return;
        ConverterHistory history = ConverterHistory(
            input: _realInput,
            output: _output.value,
            converter: settings.converterPage.converter,
            inputUnit: settings.converterPage.inputUnit,
            outputUnit: settings.converterPage.outputUnit,
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

    void _showMemoryValue(){
        showDialog(
            context: context,
            builder: (context) => StatefulBuilder(builder: (context, setState) {
                final Settings settings = context.settings();
                final TextTheme textTheme = context.textTheme;

                Widget content = Text(
                    settings.memoryValue.mathFormat(settings: settings),
                    style: textTheme.headlineMedium,
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
                break;
            case Keyboard.plusMinus:
                _realInput = prefix + suffix;
                if (RegExp(r'^-').hasMatch(_realInput)){
                    _realInput = _realInput.substring(1);
                    cursorPosition -= 1;
                } else {
                    _realInput = '-$_realInput';
                    cursorPosition += 1;
                }
            case Keyboard.swap:
                return _swapUnit();
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
        settings.converterPage.input = _realInput;

        _scrollToCursorPosition();
    }

    String _calculate(String input){
        final Settings settings = context.settings();

        input = input.mathSimplify();
        switch (settings.converterPage.converter){
            case Converter.angle      : input = ConverterOperation.angle      (input, settings.converterPage.inputUnit, settings.converterPage.outputUnit); break;
            case Converter.area       : input = ConverterOperation.area       (input, settings.converterPage.inputUnit, settings.converterPage.outputUnit); break;
            case Converter.frequency  : input = ConverterOperation.frequency  (input, settings.converterPage.inputUnit, settings.converterPage.outputUnit); break;
            case Converter.length     : input = ConverterOperation.length     (input, settings.converterPage.inputUnit, settings.converterPage.outputUnit); break;
            case Converter.pressure   : input = ConverterOperation.pressure   (input, settings.converterPage.inputUnit, settings.converterPage.outputUnit); break;
            case Converter.temperature: input = ConverterOperation.temperature(input, settings.converterPage.inputUnit, settings.converterPage.outputUnit); break;
            case Converter.time       : input = ConverterOperation.time       (input, settings.converterPage.inputUnit, settings.converterPage.outputUnit); break;
            case Converter.volume     : input = ConverterOperation.volume     (input, settings.converterPage.inputUnit, settings.converterPage.outputUnit); break;
            case Converter.weight     : input = ConverterOperation.weight     (input, settings.converterPage.inputUnit, settings.converterPage.outputUnit); break;
            case Converter.number     : break;
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

        if (MediaQuery.of(context).size.height <= 450){
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

    void _changeUnit(bool isInput) async {
        final Settings settings = context.settings();
        final TextTheme textTheme = context.textTheme;
        final ColorScheme colorScheme = context.colorScheme;
        final List<ConverterUnit> units = ConverterUnit.getUnitsBy(settings.converterPage.converter);

        Widget builder(BuildContext context){
            Widget header = SizedBox(
                width: double.infinity,
                child: Text(
                    isInput? "Convert from" : "Convert to",
                    style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Plus Jakarta Sans'
                    )
                ),
            );

            Widget options = Flexible(child: Material(
                color: Colors.transparent,
                child: SingleChildScrollView(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.generate(units.length, (index){
                        final ConverterUnit unit = units[index];

                        void onChanged(ConverterUnit? _){
                            if (isInput) settings.converterPage.inputUnit = unit;
                            else settings.converterPage.outputUnit = unit;

                            context.navigateBack();
                        }

                        Widget? subtitle;
                        if (_realInput.isNotEmpty) {
                            subtitle = Text((){
                                try { switch (settings.converterPage.converter){
                                    case Converter.angle      : return ConverterOperation.angle      (_realInput, settings.converterPage.inputUnit, unit);
                                    case Converter.area       : return ConverterOperation.area       (_realInput, settings.converterPage.inputUnit, unit);
                                    case Converter.frequency  : return ConverterOperation.frequency  (_realInput, settings.converterPage.inputUnit, unit);
                                    case Converter.length     : return ConverterOperation.length     (_realInput, settings.converterPage.inputUnit, unit);
                                    case Converter.pressure   : return ConverterOperation.pressure   (_realInput, settings.converterPage.inputUnit, unit);
                                    case Converter.temperature: return ConverterOperation.temperature(_realInput, settings.converterPage.inputUnit, unit);
                                    case Converter.time       : return ConverterOperation.time       (_realInput, settings.converterPage.inputUnit, unit);
                                    case Converter.volume     : return ConverterOperation.volume     (_realInput, settings.converterPage.inputUnit, unit);
                                    case Converter.weight     : return ConverterOperation.weight     (_realInput, settings.converterPage.inputUnit, unit);
                                    case Converter.number     : return ConverterOperation.number     (_realInput, settings.converterPage.inputUnit, unit);
                                    default: return ConverterOperation.length(_realInput, settings.converterPage.inputUnit, settings.converterPage.outputUnit);
                                } } catch (e) { return "0"; }
                            }().mathFormat(settings: settings));
                        }

                        Widget secondary = Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(4)
                            ),
                            child: Text(
                                unit.symbol,
                                style: TextStyle(color: colorScheme.onPrimary),
                            )
                        );

                        return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: RadioListTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                                    topLeft    : Radius.circular(index == 0? 12 : 0),
                                    topRight   : Radius.circular(index == 0? 12 : 0),
                                    bottomLeft : Radius.circular(index == units.length-1? 12 : 0),
                                    bottomRight: Radius.circular(index == units.length-1? 12 : 0),
                                )),
                                tileColor: colorScheme.secondaryContainer,
                                title: Text(unit.name),
                                secondary: secondary,
                                subtitle: subtitle,
                                value: unit,
                                groupValue: (isInput? settings.converterPage.inputUnit : settings.converterPage.outputUnit),
                                onChanged: onChanged
                            ),
                        );
                    }),
                )),
            ));

            Widget footer = TextFormField(
                initialValue: _input.text,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    isDense: true,
                    labelText: "${settings.converterPage.inputUnit.name} [${settings.converterPage.inputUnit.symbol}]"
                ),
                readOnly: true,
                showCursor: false,
            );

            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        header,
                        const SizedBox(height: 8),
                        options,
                        if (_input.text.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            footer
                        ]
                    ],
                ),
            );
        }

        await showModalBottomSheet(
            context: context,
            useSafeArea: true,
            showDragHandle: true,
            isScrollControlled: true,
            builder: builder
        );

        _operate("", false);
        setState((){});
    }

    void _swapUnit(){
        final Settings settings = context.settings();
        final ConverterUnit inputUnit = settings.converterPage.inputUnit;
        setState((){
            settings.converterPage.inputUnit = settings.converterPage.outputUnit;
            settings.converterPage.outputUnit = inputUnit;
        });
        _operate("", false);
    }

    void _changeConverter() async {
        const List<List<dynamic>> converters = [
            [Converter.angle, "Angle", MdiIcons.angleAcute],
            [Converter.area, "Area", Icons.crop_din_outlined],
            [Converter.frequency, "Frequency", Icons.wifi_outlined],
            [Converter.length, "Length", Icons.straighten_outlined],
            [Converter.pressure, "Pressure", Icons.compress_outlined],
            [Converter.temperature, "Temperature", Icons.thermostat_outlined],
            [Converter.time, "Time", Icons.timer_outlined],
            [Converter.volume, "Volume", MdiIcons.packageVariantClosed],
            [Converter.weight, "Weight & Mass", MdiIcons.weightKilogram]
        ];
        final Settings settings = context.settings();
        final TextTheme textTheme = context.textTheme;
        final ColorScheme colorScheme = context.colorScheme;

        Widget builder(BuildContext context){
            Widget header = SizedBox(
                width: double.infinity,
                child: Text(
                    "Converter",
                    style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Plus Jakarta Sans'
                    )
                ),
            );

            Widget options = Flexible(child: Material(
                color: Colors.transparent,
                child: SingleChildScrollView(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.generate(converters.length, (index){
                        final List<dynamic> converter = converters[index];

                        ShapeBorder shape = RoundedRectangleBorder(borderRadius: BorderRadius.only(
                            topLeft    : Radius.circular(index == 0? 12 : 0),
                            topRight   : Radius.circular(index == 0? 12 : 0),
                            bottomLeft : Radius.circular(index == converters.length-1? 12 : 0),
                            bottomRight: Radius.circular(index == converters.length-1? 12 : 0),
                        ));

                        return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: RadioListTile(
                                shape: shape,
                                tileColor: colorScheme.secondaryContainer,
                                title: Text(converter[1]),
                                secondary: Icon(converter[2]),
                                value: converter[0],
                                groupValue: settings.converterPage.converter,
                                onChanged: (value){
                                    settings.converterPage.converter = converter[0];
                                    context.navigateBack();
                                }
                            ),
                        );
                    }),
                )),
            ));

            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        header,
                        const SizedBox(height: 8),
                        options,
                    ],
                )
            );
        }

        await showModalBottomSheet(
            context: context,
            useSafeArea: true,
            showDragHandle: true,
            isScrollControlled: true,
            builder: builder
        );

        _operate("", false);
        setState((){});
    }

    @override
    void didChangeDependencies(){
        super.didChangeDependencies();

        final Settings settings = context.settings();

        _realInput = settings.converterPage.input;
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
            onPressed: () => context.navigate(builder: (context) => const HistoryPage(page: Routes.converter)),
            icon: const Icon(Icons.history_outlined)
        )];

        return SliverAppBar(
            title: const Text("Converter"),
            actions: [...actions, const SizedBox(width: 8)],
            pinned: true,
        );
    }

    Widget _body(){
        const List<List<String>> keys = [
            [Keyboard.key_7, Keyboard.key_8, Keyboard.key_9, Keyboard.delete],
            [Keyboard.key_4, Keyboard.key_5, Keyboard.key_6, Keyboard.clear],
            [Keyboard.key_1, Keyboard.key_2, Keyboard.key_3, Keyboard.plusMinus],
            [Keyboard.point, Keyboard.key_0, Keyboard.equal, Keyboard.swap]
        ];
        final TextTheme textTheme = context.textTheme;
        final ColorScheme colorScheme = context.colorScheme;
        final Settings settings = context.settings(true);
        final List converter = <List<dynamic>>[
            [Converter.angle, "Angle", MdiIcons.angleAcute],
            [Converter.area, "Area", Icons.crop_din_outlined],
            [Converter.frequency, "Frequency", Icons.wifi_outlined],
            [Converter.length, "Length", Icons.straighten_outlined],
            [Converter.pressure, "Pressure", Icons.compress_outlined],
            [Converter.temperature, "Temperature", Icons.thermostat_outlined],
            [Converter.time, "Time", Icons.timer_outlined],
            [Converter.volume, "Volume", MdiIcons.packageVariantClosed],
            [Converter.weight, "Weight & Mass", MdiIcons.weightKilogram]
        ].singleWhere((element) => element[0] == settings.converterPage.converter, orElse: () => [Converter.angle, "Angle", Icons.change_history_outlined]);
        TextStyle? inputStyle = textTheme.displayLarge;

        if (MediaQuery.of(context).size.height <= 450){
            inputStyle = textTheme.headlineMedium;
        }

        Widget converterOptions = Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ElevatedButton.icon(
                onPressed: _changeConverter,
                icon: Icon(converter[2]),
                label: Text(converter[1]),
            ),
        );

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

        Widget unitOptions = Row(children: <Widget>[
            Expanded(child: OutlinedButton.icon(
                icon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(4)
                    ),
                    child: Text(
                        settings.converterPage.inputUnit.symbol,
                        style: TextStyle(color: colorScheme.onPrimary),
                    )
                ),
                onPressed: () => _changeUnit(true),
                label: Text(settings.converterPage.inputUnit.name)
            )),
            IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _swapUnit,
            ),
            Expanded(child: OutlinedButton.icon(
                icon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(4)
                    ),
                    child: Text(
                        settings.converterPage.outputUnit.symbol,
                        style: TextStyle(color: colorScheme.onPrimary),
                    )
                ),
                onPressed: () => _changeUnit(false),
                label: Text(settings.converterPage.outputUnit.name)
            )),
        ]);

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
                    ],
                    unitOptions,
                ]
            ),
        );

        Widget keyboard = Flexible(child: Card(
            margin: const EdgeInsets.all(8),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Container(
                constraints: const BoxConstraints(maxHeight: 75 * 4, minHeight: 0),
                padding: const EdgeInsets.all(2.0),
                child: Column(children: List.generate(keys.length, (index) => Flexible(child: Row(children: List.generate(keys[index].length, (index2) {
                    TextStyle? textStyle = textTheme.headlineMedium;
                    Widget child = Text(keys[index][index2], style: textStyle);

                    switch (keys[index][index2]){
                        case Keyboard.clear: child = Text("C", style: textStyle?.copyWith(color: colorScheme.error));
                        case Keyboard.delete: child = Icon(Icons.backspace_outlined, size: textStyle!.fontSize, color: colorScheme.error);
                        case Keyboard.swap: child = Icon(Icons.swap_horiz, size: textStyle!.fontSize, color: textStyle.color);
                        case Keyboard.point:
                            if (settings.numberFormatDecimal == NumberFormatDecimals.comma) child = Text(",", style: textStyle);
                    }

                    ButtonStyle style = TextButton.styleFrom(
                        backgroundColor: Keyboard.isNumber(keys[index][index2]) || Keyboard.isHexNumber(keys[index][index2])
                            ? colorScheme.primaryContainer
                            : keys[index][index2] == Keyboard.equal? colorScheme.tertiaryContainer : null,
                        foregroundColor: Keyboard.isNumber(keys[index][index2]) || Keyboard.isHexNumber(keys[index][index2])
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

                    return Expanded(child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: TextButton(
                            onPressed: () => _operate(keys[index][index2]),
                            style: style,
                            child: FittedBox(child: child)
                        ),
                    ));
                    })),
                )))
            )
        ));

        Widget body = SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    converterOptions,
                    Expanded(child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                            inputOutput,
                            keyboard
                        ]
                    )),
                ],
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
            drawer: const NavigationDrawerWidget(selectedIndex: 2),
            body: _body()
        );
    }
}