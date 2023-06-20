import 'package:flutter/material.dart';

import 'enums.dart';
import 'settings.dart';
import 'converter.dart';

class ScientificPageSettings extends ChangeNotifier  {
    String _input = "";
    String
    get input => _input;
    set input(String value){
        _input = value;
        _update(SettingsKey.scientificPageInput, value);
    }

    ConverterUnit _angleUnit = ConverterUnit.angleRadian;
    ConverterUnit
    get angleUnit => _angleUnit;
    set angleUnit(ConverterUnit value){
        _angleUnit = value;
        _update(SettingsKey.scientificPageAngleUnit, value.toMapString());
    }

    void _update(SettingsKey key, dynamic value, [bool notify = true]){
        if (notify) notifyListeners();
        Settings.set(key, value);
    }

    void readFile(){
        input = Settings.get(SettingsKey.scientificPageInput) ?? "";
        angleUnit = ConverterUnit.parse(Settings.get(SettingsKey.scientificPageAngleUnit) ?? ConverterUnit.angleRadian.toMapString());
    }
}