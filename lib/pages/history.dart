// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../data/converter.dart';
import '../data/enums.dart';
import '../data/history.dart';
import '../data/settings.dart';
import '../utils/converter.dart';
import '../utils/string.dart';
import '../utils/build_context.dart';

class HistoryPage extends StatefulWidget {
    const HistoryPage({super.key, required this.page});

    final Routes page;

    @override
    State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

    final List<_HistoryGroup> _histories = [];
    List<History> _historyData = [];
    bool _isLoading = true;

    void _clear() async {
        bool isCancel = (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                icon: const Icon(Icons.clear),
                title: const Text("Clear history"),
                content: const Text("Are you sure want to clear history?"),
                actions: [
                    TextButton(onPressed: () => context.navigateBack(), child: const Text("Cancel")),
                    FilledButton(onPressed: () => context.navigateBack(false), child: const Text("Clear")),
                ]
            )
        )) ?? true;

        if (isCancel) return;
        switch (widget.page){
            case Routes.basic: await BasicHistory.clearDB();
            case Routes.scientific: await ScientificHistory.clearDB();
            case Routes.converter: await ConverterHistory.clearDB();
            case Routes.programmer: await ProgrammerHistory.clearDB();
            case Routes.date: await DateHistory.clearDB();
            case Routes.history:
            case Routes.settings:
        }
        _update();
    }

    void _update() async {
        switch (widget.page) {
            case Routes.basic: _historyData = await BasicHistory.queryDB();
            case Routes.scientific: _historyData = await ScientificHistory.queryDB();
            case Routes.converter: _historyData = await ConverterHistory.queryDB();
            case Routes.programmer: _historyData = await ProgrammerHistory.queryDB();
            case Routes.date: _historyData = await DateHistory.queryDB();
            case Routes.history: break;
            case Routes.settings: break;
        }
        _histories.clear();
        _historyData.sort((a, b) => (a.date).compareTo(b.date));

        List<History> items = List.from(_historyData.reversed.toList());
        for (History item in items){
            if (_histories.isEmpty){
                _histories.add(_HistoryGroup(histories: [item], date: item.date));
            } else if (DateUtils.isSameDay(_histories.last.date, item.date)) {
                _histories.last.histories.add(item);
            } else {
                _histories.add(_HistoryGroup(histories: [item], date: item.date));
            }
        }
        setState(() {
            _isLoading = false;
        });
    }

    String historyInString(History history){
        final Settings settings = context.settings();

        String text = "";
        switch (widget.page){
            case Routes.basic:
                text = "${(history as BasicHistory).input} = ${history.output}".mathFormat(settings: settings);
                break;
            case Routes.scientific:
                text = "${(history as ScientificHistory).input} = ${history.output}".mathFormat(settings: settings);
                if (RegExp(r'(?:sin|cos|tan|csc|cot|sec)\(').hasMatch(history.input)){
                    text = (history.angleUnit == ConverterUnit.angleDegree? "[DEG] " : "[RAD] ") + text;
                }
                break;
            case Routes.converter:
                text = "${(history as ConverterHistory).input} [${history.inputUnit.name} \"${history.inputUnit.symbol}\"] = ${history.output} [${history.outputUnit.name} \"${history.outputUnit.symbol}\"]".mathFormat(settings: settings);
                break;
            case Routes.programmer:
                String formattedInput = "";
                switch ((history as ProgrammerHistory).inputRadix){
                    case Radix.dec: formattedInput = history.input.mathFormat(settings: settings, scientificNotation: false); break;
                    case Radix.hex: formattedInput = history.input.mathFormat(groupingFormat: NumberFormatGrouping.space, isHexNumber: true, minimumChar: 4); break;
                    case Radix.oct: formattedInput = history.input.mathFormat(groupingFormat: NumberFormatGrouping.space, minimumChar: 4); break;
                    case Radix.bin: formattedInput = history.input.mathFormat(groupingFormat: NumberFormatGrouping.space, minimumChar: 4); break;
                }
                ConverterUnit inputUnit = ConverterUnit.numberInteger;
                switch (history.numberType){
                    case NumberType.integer: break;
                    case NumberType.float32: inputUnit = ConverterUnit.numberFloat32; break;
                    case NumberType.float64: inputUnit = ConverterUnit.numberFloat64; break;
                }
                text = "[${history.inputRadix.name.toUpperCase()}] $formattedInput = \n";
                text += "[DEC] ${history.output.mathFormat(settings: settings)}\n";
                text += "[HEX] ${ConverterOperation.number(history.output, inputUnit, ConverterUnit.numberHexadecimal).mathFormat(isHexNumber: true, minimumChar: 4, groupingFormat: NumberFormatGrouping.space)}\n";
                text += "[OCT] ${ConverterOperation.number(history.output, inputUnit, ConverterUnit.numberOctal).mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space)}\n";
                text += "[BIN] ${ConverterOperation.number(history.output, inputUnit, ConverterUnit.numberBinary).mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space)}";
                break;
            case Routes.date:
                text = "From date: ${DateFormat.yMMMMd().format((history as DateHistory).fromDate)}\n";
                text += (){
                    String input = "${history.years} year${history.years > 1? "s" : ""}, ${history.months} month${history.months > 1? "s" : ""}, ${history.days} day${history.days > 1? "s" : ""}";
                    switch (history.operation){
                        case DateOperations.addition: return "Add: $input";
                        case DateOperations.subtraction: return "Subtract: $input";
                        case DateOperations.difference: return "To date: ${DateFormat.yMMMMd().format(history.toDate)}";
                    }
                }();
                text += "\n${(history.operation == DateOperations.difference? "Difference: " : "Result: ") + history.output}";
                break;
            case Routes.history:
            case Routes.settings:
        }
        return text;
    }

    void _copy(History history){
        Clipboard.setData(ClipboardData(text: historyInString(history)));
        context.showSnackBar(const Text("Copied"));
    }

    void _share(History history){
        Share.share(historyInString(history));
    }

    void _delete(History history) async {
        await history.deleteDB();
        _update();
        if (mounted) context.showSnackBar(const Text("Deleted"));
    }

    void _showDetail(History history) async {
        final TextTheme textTheme = context.textTheme;
        final ColorScheme colorScheme = context.colorScheme;
        final Settings settings = context.settings();

        Widget builder(BuildContext context){
            Widget content = Flexible(child: SingleChildScrollView(child: (() => switch (widget.page){
                Routes.basic => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        SelectableText(
                            (history as BasicHistory).input.mathFormat(settings: settings),
                            style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary
                            )
                        ),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                SelectableText("=", style: textTheme.headlineMedium),
                                const SizedBox(width: 8),
                                Expanded(child: SelectableText(history.output.mathFormat(settings: settings), style: textTheme.headlineMedium)),
                            ],
                        ),
                    ]
                ),
                Routes.scientific => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        if (RegExp(r'sin|cos|tan|csc|cot|sec').hasMatch((history as ScientificHistory).input)) Text(
                            history.angleUnit == ConverterUnit.angleDegree? "[ DEG ]" : "[ RAD ]",
                            style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)
                        ),
                        SelectableText(
                            (history).input.mathFormat(settings: settings),
                            style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary
                            )
                        ),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                SelectableText("=", style: textTheme.headlineMedium),
                                const SizedBox(width: 8),
                                Expanded(child: SelectableText(history.output.mathFormat(settings: settings), style: textTheme.headlineMedium)),
                            ],
                        ),
                    ]
                ),
                Routes.converter => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(children: [
                            Text(
                                (history as ConverterHistory).inputUnit.name,
                                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(width: 4),
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: colorScheme.primary,
                                ),
                                child: Text(history.inputUnit.symbol, style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold))
                            )
                        ]),
                        SelectableText(history.input.mathFormat(settings: settings), style: textTheme.headlineMedium),
                        const Divider(height: 32,),
                        Row(children: [
                            Text(history.outputUnit.name, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: colorScheme.primary,
                                ),
                                child: Text(history.outputUnit.symbol, style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold))
                            )
                        ]),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                SelectableText("=", style: textTheme.headlineMedium),
                                const SizedBox(width: 8),
                                Expanded(child: SelectableText(history.output.mathFormat(settings: settings), style: textTheme.headlineMedium)),
                            ],
                        ),
                    ]
                ),
                Routes.date => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text("From:", style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SelectableText(DateFormat.yMMMMd().format((history as DateHistory).fromDate), style: textTheme.headlineMedium),
                        const Divider(height: 32),
                        Text((() => switch (history.operation){
                            DateOperations.addition => "Add:",
                            DateOperations.subtraction => "Subtract:",
                            DateOperations.difference => "To:"
                        })(), style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (history.operation == DateOperations.difference)...[
                            SelectableText(DateFormat.yMMMMd().format(history.toDate), style: textTheme.headlineMedium),
                            const Divider(height: 32),
                            Text("Difference:", style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            SelectableText(history.output)
                        ] else ...[
                            SelectableText("${history.years} year${history.years > 1? "s" : ""}, ${history.months} month${history.months > 1? "s" : ""}, ${history.days} day${history.days > 1? "s" : ""}"),
                            const Divider(height: 32),
                            Text("Date:", style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            SelectableText(history.output, style: textTheme.headlineMedium)
                        ]
                    ]
                ),
                Routes.programmer => (){
                    String formattedInput = "";
                    switch ((history as ProgrammerHistory).inputRadix){
                        case Radix.dec: formattedInput = history.input.mathFormat(settings: settings, scientificNotation: false);
                        case Radix.hex: formattedInput = history.input.mathFormat(groupingFormat: NumberFormatGrouping.space, isHexNumber: true, minimumChar: 4);
                        case Radix.oct: formattedInput = history.input.mathFormat(groupingFormat: NumberFormatGrouping.space, minimumChar: 4);
                        case Radix.bin: formattedInput = history.input.mathFormat(groupingFormat: NumberFormatGrouping.space, minimumChar: 4);
                    }
                    ConverterUnit inputUnit = ConverterUnit.numberInteger;
                    switch (history.numberType){
                        case NumberType.integer: break;
                        case NumberType.float32: inputUnit = ConverterUnit.numberFloat32;
                        case NumberType.float64: inputUnit = ConverterUnit.numberFloat64;
                    }
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            // Text(history.numberType.name.titleCase()),
                            SelectableText(formattedInput, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    SelectableText("=", style: textTheme.headlineMedium),
                                    const SizedBox(width: 8),
                                    Expanded(child: Padding(
                                        padding: const EdgeInsets.only(top: 10.0),
                                        child: Column(children: <List<dynamic>>[
                                                [Radix.dec, history.output.mathFormat(settings: settings)],
                                                [Radix.hex, ConverterOperation.number(history.output, inputUnit, ConverterUnit.numberHexadecimal).mathFormat(isHexNumber: true, minimumChar: 4, groupingFormat: NumberFormatGrouping.space)],
                                                [Radix.oct, ConverterOperation.number(history.output, inputUnit, ConverterUnit.numberOctal).mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space)],
                                                [Radix.bin, ConverterOperation.number(history.output, inputUnit, ConverterUnit.numberBinary).mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space)],
                                            ].map<Widget>((option) {
                                                bool selected = history.inputRadix == option[0];
                                                return Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        SizedBox(
                                                            width: 36,
                                                            child: Text(
                                                                (option[0] as Radix).name.toUpperCase(),
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    color: selected? colorScheme.primary : null
                                                                )
                                                            )
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(child: Text(
                                                            option[1],
                                                            style: TextStyle(
                                                                fontWeight: selected? FontWeight.bold : null,
                                                                color: selected? colorScheme.primary : null
                                                            ),
                                                        ))
                                                    ]
                                                );
                                            }).toList(),
                                        )
                                    )),
                                ],
                            ),
                        ]
                    );
                }(),
                _ => Container()
            })()));

            Widget actions = Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <List<dynamic>>[
                        ["Copy", Icons.copy_outlined, _copy],
                        ["Share", Icons.share_outlined, _share],
                        ["Delete", Icons.delete_outline, _delete],
                    ].map<Widget>((option) => IconButton(
                        tooltip: option[0],
                        icon: Icon(option[1]),
                        onPressed: (){
                            option[2](history);
                            context.navigateBack();
                        },
                    )).toList(),
                ),
            );

            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        content,
                        const SizedBox(height: 8),
                        actions,
                    ]
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
    }

    @override
    void didChangeDependencies() async {
        super.didChangeDependencies();
        _update();
    }

    List<Widget> historiesWidget(int index){
        final TextTheme textTheme = context.textTheme;
        final ColorScheme colorScheme = context.colorScheme;
        final Settings settings = context.settings(true);

        return List.generate(_histories[index].histories.length, (index2) {
            var history = _histories[index].histories[index2];

            void delete(dynamic history, int index, int index2) async {
                await (history as dynamic).deleteDB();
                setState((){
                    _histories[index].histories.removeAt(index2);
                    if (_histories[index].histories.isEmpty) _histories.removeAt(index);
                });
            }

            Widget? title;
            Widget? subtitle;
            Widget? trailing;

            switch (widget.page){
                case Routes.basic:
                    title = Text(
                        (history as BasicHistory).input.mathFormat(settings: settings, scientificNotation: false),
                        style: textTheme.headlineSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                    );
                    subtitle = Text(history.output.mathFormat(settings: settings));
                    break;
                case Routes.scientific:
                    title = Text(
                        (history as ScientificHistory).input.mathFormat(settings: settings, scientificNotation: false),
                        style: textTheme.headlineSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                    );
                    subtitle = Text(history.output.mathFormat(settings: settings));
                    if (RegExp(r'sin|cos|tan|csc|cot|sec').hasMatch(history.input)){
                        trailing = Text(
                            history.angleUnit == ConverterUnit.angleDegree? "DEG" : "RAD",
                            style: TextStyle(color: colorScheme.tertiary, fontWeight: FontWeight.bold)
                        );
                    }
                    break;
                case Routes.converter:
                    title = Wrap(
                        spacing: 4,
                        children: [
                            Text((history as ConverterHistory).input.mathFormat(settings: settings)),
                            const Icon(Icons.arrow_forward, size: 20),
                            Text(history.output.mathFormat(settings: settings)),
                        ]
                    );
                    subtitle = DefaultTextStyle(
                        style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                        child: Wrap(
                            spacing: 4,
                            children: [
                                Text((history).inputUnit.name, style: TextStyle(color: colorScheme.primary)),
                                Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: colorScheme.primary,
                                    ),
                                    child: Text(history.inputUnit.symbol, style: TextStyle(color: colorScheme.onPrimary))
                                ),
                                const Icon(Icons.arrow_forward, size: 20),
                                Text(history.outputUnit.name, style: TextStyle(color: colorScheme.primary)),
                                Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: colorScheme.primary,
                                    ),
                                    child: Text(history.outputUnit.symbol, style: TextStyle(color: colorScheme.onPrimary))
                                ),
                            ],
                        ),
                    );
                    break;
                case Routes.programmer:
                    String formattedInput = "";
                    switch ((history as ProgrammerHistory).inputRadix){
                        case Radix.dec: formattedInput = history.input.mathFormat(settings: settings, scientificNotation: false); break;
                        case Radix.hex: formattedInput = history.input.mathFormat(groupingFormat: NumberFormatGrouping.space, isHexNumber: true, minimumChar: 4); break;
                        case Radix.oct: formattedInput = history.input.mathFormat(groupingFormat: NumberFormatGrouping.space, minimumChar: 4); break;
                        case Radix.bin: formattedInput = history.input.mathFormat(groupingFormat: NumberFormatGrouping.space, minimumChar: 4); break;
                    }
                    title = Text(formattedInput, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold));
                    String numberType = "";
                    ConverterUnit inputUnit = ConverterUnit.numberInteger;
                    switch (history.numberType){
                        case NumberType.integer: numberType = "INT"; break;
                        case NumberType.float32: numberType = "FLOAT32"; inputUnit = ConverterUnit.numberFloat32; break;
                        case NumberType.float64: numberType = "FLOAT64"; inputUnit = ConverterUnit.numberFloat64; break;
                    }
                    subtitle = Column(children: List.generate(4, (index) {
                        List options = [
                            [Radix.dec, history.output.mathFormat(settings: settings)],
                            [Radix.hex, ConverterOperation.number(history.output, inputUnit, ConverterUnit.numberHexadecimal).mathFormat(isHexNumber: true, minimumChar: 4, groupingFormat: NumberFormatGrouping.space)],
                            [Radix.oct, ConverterOperation.number(history.output, inputUnit, ConverterUnit.numberOctal).mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space)],
                            [Radix.bin, ConverterOperation.number(history.output, inputUnit, ConverterUnit.numberBinary).mathFormat(minimumChar: 4, groupingFormat: NumberFormatGrouping.space)],
                        ];
                        bool selected = history.inputRadix == options[index][0];
                        return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                SizedBox(
                                    width: 28,
                                    child: Text(
                                        (options[index][0] as Radix).name.toUpperCase(),
                                        style: textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: selected? colorScheme.primary : null
                                        )
                                    )
                                ),
                                const SizedBox(width: 4),
                                Expanded(child: Text(
                                    options[index][1],
                                    style: textTheme.labelSmall?.copyWith(
                                        fontWeight: selected? FontWeight.bold : null,
                                        color: selected? colorScheme.primary : null
                                    ),
                                ))
                            ]
                        );
                    }));
                    // trailing = Text(numberType);
                    break;
                case Routes.date:
                    title = Text(
                        DateFormat.yMMMMd().format((history as DateHistory).fromDate),
                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)
                    );
                    subtitle = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            RichText(text: TextSpan(
                                style: textTheme.bodyMedium,
                                children: [
                                    TextSpan(
                                        text: (){
                                            switch (history.operation){
                                                case DateOperations.addition: return "Add: ";
                                                case DateOperations.subtraction: return "Subtract: ";
                                                case DateOperations.difference: return "To: ";
                                            }
                                        }(),
                                        style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold)
                                    ),
                                    TextSpan(text: history.operation == DateOperations.difference? DateFormat.yMMMMd().format(history.toDate) : "${history.years} year${history.years > 1? "s" : ""}, ${history.months} month${history.months > 1? "s" : ""}, ${history.days} day${history.days > 1? "s" : ""}")
                                ]
                            )),
                            RichText(text: TextSpan(
                                style: textTheme.bodyMedium,
                                children: [
                                    TextSpan(
                                        text: history.operation == DateOperations.difference? "Difference: " : "Date: ",
                                        style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold)
                                    ),
                                    TextSpan(text: history.output)
                                ]
                            )),
                        ]
                    );
                    break;
                case Routes.history:
                case Routes.settings:
            }

            return Dismissible(
                key: ValueKey("${history.id}"),
                onDismissed: (direction) => delete(history, index, index2),
                background: Container(
                    color: colorScheme.error,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                        Icon(Icons.delete_outlined, color: colorScheme.onError),
                        const SizedBox(width: 16),
                        Text("Delete", style: textTheme.labelLarge?.copyWith(color: colorScheme.onError))
                    ])
                ),
                secondaryBackground: Container(
                    color: colorScheme.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.all(16),
                    child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text("Delete", style: textTheme.labelLarge?.copyWith(color: colorScheme.onError)),
                        const SizedBox(width: 16),
                        Icon(Icons.delete_outlined, color: colorScheme.onError),
                    ])
                ),
                child: ListTile(
                    title: title,
                    subtitle: subtitle,
                    trailing: trailing,
                    onTap: () => _showDetail(history),
                ),
            );
        });
    }

    Widget _appBar() {
        Widget leading = IconButton(
            onPressed: () => context.navigateBack(),
            icon: const Icon(Icons.arrow_back)
        );

        Widget title = const Text(
            'History',
            style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Plus Jakarta Sans')
        );

        List<Widget> actions = [
            AnimatedCrossFade(
                firstChild: Container(),
                secondChild: PopupMenuButton(
                    onSelected: (value){ switch(value){ case "clear": _clear(); } },
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem(
                            value: 'clear',
                            child: Text("Clear"),
                        )
                    ]
                ),
                crossFadeState: _histories.isNotEmpty? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250)
            )
        ];

        Widget appBar = SliverAppBar.large(
            leadingWidth: 52.0,
            title: title,
            leading: leading,
            actions: [...actions, const SizedBox(width: 8)],
        );

        if (context.isBigScreen){
            appBar = SliverAppBar(
                leadingWidth: 52.0,
                title: title,
                leading: leading,
                actions: [...actions, const SizedBox(width: 8)],
                pinned: true
            );
        }

        return appBar;
    }

    Widget _body(){
        final TextTheme textTheme = context.textTheme;
        final ColorScheme colorScheme = context.colorScheme;

        List<Widget> histories = List.generate(_histories.length, (index){
            Widget date = Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Text(
                    DateFormat.yMMMMd().format(_histories[index].date),
                    style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer)
                ),
            );

            Widget item = Card(
                margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                clipBehavior: Clip.antiAlias,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        date,
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        ...historiesWidget(index),
                        const SizedBox(height: 8),
                    ]
                )
            );

            if (context.isBigScreen){
                item = Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Flexible(child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: item
                    ))]
                );
            }

            return item;
        });

        Widget body = const SliverFillRemaining();

        if (_histories.isEmpty){
            body = SliverFillRemaining(child: SizedBox(
                width: double.infinity,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Icon(Icons.history, size: textTheme.displayLarge?.fontSize),
                        const SizedBox(height: 16,),
                        Text("No history", style: textTheme.titleLarge)
                    ]
                ),
            ));
        }

        if (_histories.isNotEmpty){
            body = SliverList(delegate: SliverChildListDelegate(histories));
        }

        if (_isLoading) {
            body = const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));;
        }

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
        return Scaffold(body: _body());
    }
}


class _HistoryGroup {
    final DateTime date;
    final List<History> histories;

    _HistoryGroup({required this.histories, required this.date});
}