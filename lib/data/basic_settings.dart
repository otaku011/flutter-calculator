import 'package:flutter/material.dart';

import 'enums.dart';
import 'settings.dart';

class BasicPageSettings extends ChangeNotifier  {
    String _input = '';
    String
    get input => _input;
    set input(String value){
        _input = value;
        _update(SettingsKey.basicPageInput, value);
    }

    void _update(SettingsKey key, dynamic value, [bool notify = true]){
        if (notify) notifyListeners();
        Settings.set(key, value);
    }

    void readFile(){
        input = Settings.get(SettingsKey.basicPageInput) ?? "";
    }
}