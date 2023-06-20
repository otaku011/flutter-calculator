import 'package:flutter/material.dart';

import 'enums.dart';
import 'settings.dart';

class ProgrammerPageSettings extends ChangeNotifier  {
    String _input = "";
    String
    get input => _input;
    set input(String value){
        _input = value;
        _update(SettingsKey.programmerPageInput, value);
    }

    Radix _inputRadix = Radix.dec;
    Radix
    get inputRadix => _inputRadix;
    set inputRadix(Radix value){
        _inputRadix = value;
        _update(SettingsKey.programmerPageInputRadix, value);
    }

    NumberType _numberType = NumberType.integer;
    NumberType
    get numberType => _numberType;
    set numberType(NumberType value){
        _numberType = value;
        _update(SettingsKey.programmerPageNumberType, value);
    }

    void _update(SettingsKey key, dynamic value, [bool notify = true]){
        if (notify) notifyListeners();
        Settings.set(key, value);
    }

    void readFile(){
        input = Settings.get(SettingsKey.programmerPageInput) ?? "";
        inputRadix = Radix.values.byName(Settings.get(SettingsKey.programmerPageInputRadix) ?? Radix.dec.name);
        numberType = NumberType.values.byName(Settings.get(SettingsKey.programmerPageNumberType) ?? NumberType.integer.name);
    }
}