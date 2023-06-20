import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'basic_settings.dart';
import 'enums.dart';
import 'scientific_settings.dart';
import 'converter_settings.dart';
import 'programmer_settings.dart';
import 'date_settings.dart';

class Settings extends ChangeNotifier {
    static late SharedPreferences prefs;
    final Map<SettingsKey, dynamic> _settings = {
        SettingsKey.color: Colors.blue.value,
        SettingsKey.theme: ThemeMode.system,
        SettingsKey.lastPage: Routes.basic,
        SettingsKey.memoryButton: true,
        SettingsKey.memoryValue: "0",
        SettingsKey.scientificNotation: true,
        SettingsKey.numberFormatDecimal: NumberFormatDecimals.point,
        SettingsKey.numberFormatGrouping: NumberFormatGrouping.comma,
        SettingsKey.basicPage: BasicPageSettings(),
        SettingsKey.scientificPage: ScientificPageSettings(),
        SettingsKey.converterPage: ConverterPageSettings(),
        SettingsKey.programmerPage: ProgrammerPageSettings(),
        SettingsKey.datePage: DatePageSettings()
    };

    Color
    get color => Color(_settings[SettingsKey.color]);
    set color(Color value) => _update(SettingsKey.color, value.value);

    ThemeMode
    get theme => _settings[SettingsKey.theme];
    set theme(ThemeMode value) => _update(SettingsKey.theme, value);

    Routes
    get lastPage => _settings[SettingsKey.lastPage];
    set lastPage(Routes value) => _update(SettingsKey.lastPage, value, false);

    bool
    get memoryButton => _settings[SettingsKey.memoryButton];
    set memoryButton(bool value) => _update(SettingsKey.memoryButton, value);

    String
    get memoryValue => _settings[SettingsKey.memoryValue];
    set memoryValue(String value) => _update(SettingsKey.memoryValue, value);

    bool
    get scientificNotation => _settings[SettingsKey.scientificNotation];
    set scientificNotation(bool value) => _update(SettingsKey.scientificNotation, value);

    NumberFormatDecimals
    get numberFormatDecimal => _settings[SettingsKey.numberFormatDecimal];
    set numberFormatDecimal(NumberFormatDecimals value) => _update(SettingsKey.numberFormatDecimal, value);

    NumberFormatGrouping
    get numberFormatGrouping => _settings[SettingsKey.numberFormatGrouping];
    set numberFormatGrouping(NumberFormatGrouping value) => _update(SettingsKey.numberFormatGrouping, value);

    BasicPageSettings
    get basicPage => _settings[SettingsKey.basicPage];

    ScientificPageSettings
    get scientificPage => _settings[SettingsKey.scientificPage];

    ConverterPageSettings
    get converterPage => _settings[SettingsKey.converterPage];

    ProgrammerPageSettings
    get programmerPage => _settings[SettingsKey.programmerPage];

    DatePageSettings
    get datePage => _settings[SettingsKey.datePage];

    bool
    get isDarkMode => _settings[SettingsKey.theme] == ThemeMode.dark || (_settings[SettingsKey.theme] == ThemeMode.system && SchedulerBinding.instance.window.platformBrightness == Brightness.dark);

    void _update(SettingsKey key, dynamic value, [bool notify = true]){
        _settings[key] = value;
        if (notify) notifyListeners();
        Settings.set(key, value);
    }

    Future<void> readFile() async {
        prefs = await SharedPreferences.getInstance();
        try {
            color = Color(Settings.get(SettingsKey.color) ?? Colors.blue.value);
            theme = ThemeMode.values.byName(Settings.get(SettingsKey.theme) ?? ThemeMode.system.name);
            lastPage = Routes.values.byName(Settings.get(SettingsKey.lastPage) ?? Routes.basic.name);
            memoryButton = Settings.get(SettingsKey.memoryButton) ?? true;
            memoryValue = Settings.get(SettingsKey.memoryValue) ?? "0";
            scientificNotation = Settings.get(SettingsKey.scientificNotation) ?? true;
            numberFormatDecimal = NumberFormatDecimals.values.byName(Settings.get(SettingsKey.numberFormatDecimal) ?? NumberFormatDecimals.point.name);
            numberFormatGrouping = NumberFormatGrouping.values.byName(Settings.get(SettingsKey.numberFormatGrouping) ?? NumberFormatGrouping.comma.name);

            basicPage.readFile();
            scientificPage.readFile();
            converterPage.readFile();
            programmerPage.readFile();
            datePage.readFile();
        } catch (e) {
            debugPrint("ERROR READ FILE SETTINGS: $e");
        }
    }

    static
    String numberFormatDecimalChar(NumberFormatDecimals decimalFormat) {
        switch (decimalFormat){
          case NumberFormatDecimals.point: return ".";
          case NumberFormatDecimals.comma: return ",";
        }
    }

    static
    String numberFormatGroupingChar(NumberFormatGrouping groupingFormat) {
        switch (groupingFormat){
            case NumberFormatGrouping.none: return "";
            case NumberFormatGrouping.space: return " ";
            case NumberFormatGrouping.comma: return ",";
            case NumberFormatGrouping.point: return ".";
            case NumberFormatGrouping.underscore: return "_";
        }
    }

    static
    dynamic get(SettingsKey key) {
        return prefs.get(key.name);
    }

    /// `value.runtimeType` must be:
    /// * `int`
    /// * `String`
    /// * `bool`
    /// * `double`
    /// * `Enum`
    static
    Future<void> set(SettingsKey key, dynamic value) async {
        switch(value.runtimeType){
            case int   : prefs.setInt   (key.name, value);
            case String: prefs.setString(key.name, value);
            case bool  : prefs.setBool  (key.name, value);
            case double: prefs.setDouble(key.name, value);
            default    :
                if (value is! Enum) throw Exception('Data type not supported [value: $value, value.runtimeType: ${value.runtimeType}]');
                prefs.setString(key.name, value.name);
        }
    }
}