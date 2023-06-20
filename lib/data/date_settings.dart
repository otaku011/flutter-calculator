import 'package:flutter/material.dart';

import 'enums.dart';
import 'settings.dart';

class DatePageSettings extends ChangeNotifier  {
    DateTime _fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime
    get fromDate => _fromDate;
    set fromDate(DateTime value){
        _fromDate = value;
        _update(SettingsKey.datePageFromDate, value.toIso8601String());
    }

    DateTime _toDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime
    get toDate => _toDate;
    set toDate(DateTime value){
        _toDate = value;
        _update(SettingsKey.datePageToDate, value.toIso8601String());
    }

    DateOperations _operation = DateOperations.difference;
    DateOperations
    get operation => _operation;
    set operation(DateOperations value){
        _operation = value;
        _update(SettingsKey.datePageOperation, value.name);
    }

    int _years = 0;
    int
    get years => _years;
    set years(int value){
        _years = value;
        _update(SettingsKey.datePageYears, value);
    }

    int _months = 0;
    int
    get months => _months;
    set months(int value){
        _months = value;
        _update(SettingsKey.datePageMonths, value);
    }

    int _days = 0;
    int
    get days => _days;
    set days(int value){
        _days = value;
        _update(SettingsKey.datePageDays, value);
    }

    void _update(SettingsKey key, dynamic value, [bool notify = true]){
        if (notify) notifyListeners();
        Settings.set(key, value);
    }

    void readFile(){
        fromDate = DateTime.parse(Settings.get(SettingsKey.datePageFromDate) ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toIso8601String());
        toDate = DateTime.parse(Settings.get(SettingsKey.datePageToDate) ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toIso8601String());
        operation = DateOperations.values.byName(Settings.get(SettingsKey.datePageOperation) ?? DateOperations.difference.name);
        years = Settings.get(SettingsKey.datePageYears) ?? 0;
        months = Settings.get(SettingsKey.datePageMonths) ?? 0;
        days = Settings.get(SettingsKey.datePageDays) ?? 0;
    }
}