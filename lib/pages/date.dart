// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:calculator/data/history.dart';
import 'package:calculator/utils/build_context.dart';
import 'package:calculator/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/enums.dart';
import '../widgets/drawer.dart';
import '../data/settings.dart';
import 'history.dart';

class DatePage extends StatefulWidget {
    const DatePage({super.key});

    @override
    State<DatePage> createState() => _DatePageState();
}

class _DatePageState extends State<DatePage> {

    final TextEditingController _inputYears = TextEditingController();
    final TextEditingController _inputMonths = TextEditingController();
    final TextEditingController _inputDays = TextEditingController();
    final ValueNotifier<String> _output = ValueNotifier("");

    void _saveToHistory(){
        final Settings settings = context.settings();

        DateHistory history = DateHistory(
            fromDate: settings.datePage.fromDate,
            toDate: settings.datePage.toDate,
            operation: settings.datePage.operation,
            years: settings.datePage.years,
            months: settings.datePage.months,
            days: settings.datePage.days,
            output: _output.value,
            date: DateTime.now()
        );
        history.insertDB();
    }

    void _changeFromDate() async {
        final Settings settings = context.settings();

        DateTime fromDate = await showDatePicker(
            currentDate: DateTime.now(),
            context: context,
            initialDate: settings.datePage.fromDate,
            firstDate: DateTime(1970),
            lastDate: DateTime(DateTime.now().year + 2000)
        ) ?? settings.datePage.fromDate;

        bool changed = settings.datePage.fromDate != fromDate;
        setState(() => settings.datePage.fromDate = fromDate);
        _calculate(changed);
    }

    void _changeToDate() async {
        final Settings settings = context.settings();

        DateTime toDate = await showDatePicker(
            currentDate: DateTime.now(),
            context: context,
            initialDate: settings.datePage.toDate,
            firstDate: DateTime(1970),
            lastDate: DateTime(DateTime.now().year + 2000)
        ) ?? settings.datePage.toDate;

        bool changed = toDate != settings.datePage.toDate;
        setState(() => settings.datePage.toDate = toDate);
        _calculate(changed);
    }

    void _changeInputDate() async {
        final Settings settings = context.settings();

        Widget builder(BuildContext context){
            final List<List> options = [
                ["Years", _inputYears],
                ["Months", _inputMonths],
                ["Days", _inputDays],
            ];

            List<Widget> children = List.generate(options.length, (index) => Flexible(child: Padding(
                padding: EdgeInsets.only(left: index > 0? 4.0 : 0, right: index < 2? 4.0 : 0),
                child: TextFormField(
                    controller: options[index][1],
                    decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                        isDense: true,
                        labelText: options[index][0],
                    ),
                    autovalidateMode: AutovalidateMode.always,
                    maxLength: 3,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                    validator: (String? value){
                        if (value == null) return null;
                        if (int.tryParse(value) == null) return "Not an integer";
                        if (int.parse(value) < 0) return "Number must positive";
                        return null;
                    },
                ),
            )));

            return Padding(
                padding: context.mediaQueryData.viewInsets,
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: children
                    )
                ),
            );
        }

        await showModalBottomSheet(
            context: context,
            useSafeArea: true,
            isScrollControlled: true,
            builder: builder
        );

        bool changed = false;
        setState((){
            if (
                _inputYears.text.isNotEmpty &&
                int.tryParse(_inputYears.text) != null &&
                int.parse(_inputYears.text) >= 0 &&
                int.parse(_inputYears.text) < 1000
            ){
                changed = settings.datePage.years != int.parse(_inputYears.text);
                settings.datePage.years = int.parse(_inputYears.text);
            }

            if (
                _inputMonths.text.isNotEmpty &&
                int.tryParse(_inputMonths.text) != null &&
                int.parse(_inputMonths.text) >= 0 &&
                int.parse(_inputMonths.text) < 1000
            ){
                if (!changed) changed = settings.datePage.months != int.parse(_inputMonths.text);
                settings.datePage.months = int.parse(_inputMonths.text);
            }

            if (
                _inputDays.text.isNotEmpty &&
                int.tryParse(_inputDays.text) != null &&
                int.parse(_inputDays.text) >= 0 &&
                int.parse(_inputDays.text) < 1000
            ){
                if (!changed) changed = settings.datePage.days != int.parse(_inputDays.text);
                settings.datePage.days = int.parse(_inputDays.text);
            }
        });
        _calculate(changed);
    }

    void _calculate([bool saveToHistory = true]){
        final Settings settings = context.settings();

        DateTime date = DateTime(settings.datePage.years, settings.datePage.months, settings.datePage.days);
        switch (settings.datePage.operation){
            case DateOperations.addition:
                _output.value = DateFormat.yMMMMd().format(DateTime(
                    settings.datePage.fromDate.year  + date.year,
                    settings.datePage.fromDate.month + date.month,
                    settings.datePage.fromDate.day   + date.day,
                ));
            case DateOperations.subtraction:
                _output.value = DateFormat.yMMMMd().format(DateTime(
                    settings.datePage.fromDate.year  - date.year,
                    settings.datePage.fromDate.month - date.month,
                    settings.datePage.fromDate.day   - date.day,
                ));
            case DateOperations.difference:
                String output = "";
                int days = settings.datePage.fromDate.difference(settings.datePage.toDate).inDays.abs();
                int inDays = days;
                if (days >= 365.25){
                    output = "${days ~/ 365.25} year${days ~/ 365.25 > 1? "s" : ""}";
                    days = (days % 365.25).floor();
                }
                if (days >= 30.437){
                    if (output.isNotEmpty) output += ", ";
                    output += "${days ~/ 30.437} month${days ~/ 30.437 > 1? "s" : ""}";
                    days = (days % 30.437).floor();
                }
                if (days >= 7){
                    if (output.isNotEmpty) output += ", ";
                    output += "${days ~/ 7} week${days ~/ 7 > 1? "s" : ""}";
                    days = (days % 7).floor();
                }
                if (days > 0){
                    if (output.isNotEmpty) output += ", ";
                    output += "$days day${days > 1? "s" : ""}";
                }
                if (inDays == 0) {
                    output = "Same date";
                } else if (inDays >= 7) {
                    output += " ($inDays day${inDays > 1? "s" : ""})";
                }
                _output.value = output;
        }
        if (saveToHistory) _saveToHistory();
    }

    @override
    void didChangeDependencies(){
        super.didChangeDependencies();

        final Settings settings = context.settings();

        _inputYears.text = settings.datePage.years.toString();
        _inputMonths.text = settings.datePage.months.toString();
        _inputDays.text = settings.datePage.days.toString();
        _calculate(false);
    }

    @override
    void dispose(){
        _inputYears.dispose();
        _inputMonths.dispose();
        _inputDays.dispose();
        super.dispose();
    }

    Widget _appBar(){
        List<Widget> actions = [IconButton(
            onPressed: () => context.navigate(builder: (context) => const HistoryPage(page: Routes.date)),
            icon: const Icon(Icons.history_outlined)
        )];

        return SliverAppBar(
            title: const Text("Date"),
            actions: [...actions, const SizedBox(width: 8)],
            pinned: true
        );
    }

    Widget _body(){
        final Settings settings = context.settings(true);
        final TextTheme textTheme = context.textTheme;
        final ColorScheme colorScheme = context.colorScheme;

        Widget operation = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: List.generate(DateOperations.values.length, (index) => Padding(
                padding: EdgeInsets.only(left: index == 0? 8 : 2, right: index == DateOperations.values.length-1? 8 : 2),
                child: ChoiceChip(
                    label: Text(DateOperations.values[index].name.titleCase()),
                    selected: settings.datePage.operation == DateOperations.values[index],
                    onSelected: (value){
                        settings.datePage.operation = DateOperations.values[index];
                        _calculate(false);
                        setState((){});
                    },
                ),
            ))),
        );

        Widget fromDate = SizedBox(
            width: double.infinity,
            child: InkWell(
                onTap: _changeFromDate,
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text("From: ", style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: "Plus Jakarta Sans",
                                color: colorScheme.primary
                            )),
                            const SizedBox(height: 8),
                            Text(DateFormat.yMMMMd().format(settings.datePage.fromDate), style: textTheme.displaySmall),
                        ]
                    ),
                ),
            )
        );

        Widget toDate = SizedBox(
            width: double.infinity,
            child: InkWell(
                onTap: _changeToDate,
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text("To: ", style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: "Plus Jakarta Sans",
                                color: colorScheme.primary
                            )),
                            const SizedBox(height: 8),
                            Text(DateFormat.yMMMMd().format(settings.datePage.toDate), style: textTheme.displaySmall),
                        ]
                    ),
                ),
            )
        );

        Widget inputs = SizedBox(
            width: double.infinity,
            child: InkWell(
                onTap: _changeInputDate,
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(settings.datePage.operation == DateOperations.addition? "Add:" : "Subtract:", style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: "Plus Jakarta Sans",
                                color: colorScheme.primary
                            )),
                            const SizedBox(height: 8),
                            Text("${settings.datePage.years} year${settings.datePage.years > 1? "s" : ""}, ${settings.datePage.months} month${settings.datePage.months > 1? "s" : ""}, ${settings.datePage.days} day${settings.datePage.days > 1? "s" : ""}", style: textTheme.bodyLarge),
                        ]
                    ),
                ),
            )
        );

        Widget inputOutput = Card(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: SizedBox(
                width: double.infinity,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        fromDate,
                        const Divider(height: 1),
                        if (settings.datePage.operation == DateOperations.difference) toDate
                        else inputs
                    ]
                ),
            ),
        );

        Widget outputBox = Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(settings.datePage.operation == DateOperations.difference? "Difference:" : "Date:", style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Plus Jakarta Sans",
                        color: colorScheme.primary
                    )),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<String>(
                        valueListenable: _output,
                        builder: (context, output, _){
                            TextStyle? style = textTheme.displaySmall;
                            if (settings.datePage.operation == DateOperations.difference){
                                style = textTheme.bodyLarge;
                            }
                            return SelectableText(output, style: style);
                        }
                    ),
                ]
            ),
        );

        Widget body = SliverList(delegate: SliverChildListDelegate([
                    operation,
                    const SizedBox(height: 8),
                    inputOutput,
                    outputBox
        ]));

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
            drawer: const NavigationDrawerWidget(selectedIndex: 4),
            body: _body()
        );
    }
}