import 'package:flutter/material.dart';

import 'enums.dart';
import 'settings.dart';
import 'converter.dart';

class ConverterPageSettings extends ChangeNotifier  {
    String _input = '';
    String
    get input => _input;
    set input(String value){
        _input = value;
        _update(SettingsKey.converterPageInput, value);
    }

    Converter _converter = Converter.length;
    Converter
    get converter => _converter;
    set converter(Converter value){
        _converter = value;
        switch (value){
            case Converter.angle:
                inputUnit = ConverterUnit.angleRadian;
                outputUnit = ConverterUnit.angleDegree;
                break;
            case Converter.area:
                inputUnit = ConverterUnit.areaSquareMeter;
                outputUnit = ConverterUnit.areaSquareFeet;
                break;
            case Converter.frequency:
                inputUnit = ConverterUnit.frequencyTerahertz;
                outputUnit = ConverterUnit.frequencyHertz;
                break;
            case Converter.length:
                inputUnit = ConverterUnit.lengthCentimeter;
                outputUnit = ConverterUnit.lengthInch;
                break;
            case Converter.number:
                inputUnit = ConverterUnit.numberFloat64;
                outputUnit = ConverterUnit.numberOctal;
                break;
            case Converter.pressure:
                inputUnit = ConverterUnit.pressureAtmosphere;
                outputUnit = ConverterUnit.pressurePsi;
                break;
            case Converter.temperature:
                inputUnit = ConverterUnit.temperatureCelsius;
                outputUnit = ConverterUnit.temperatureKelvin;
                break;
            case Converter.time:
                inputUnit = ConverterUnit.timeYear;
                outputUnit = ConverterUnit.timeDay;
                break;
            case Converter.volume:
                inputUnit = ConverterUnit.volumeLiter;
                outputUnit = ConverterUnit.volumeQubicMeter;
                break;
            case Converter.weight:
                inputUnit = ConverterUnit.weightOunce;
                outputUnit = ConverterUnit.weightGram;
                break;
        }
        _update(SettingsKey.converterPageConverter, value);
    }

    ConverterUnit _inputUnit = ConverterUnit.lengthKilometer;
    ConverterUnit
    get inputUnit => _inputUnit;
    set inputUnit(ConverterUnit value){
        _inputUnit = value;
        _update(SettingsKey.converterPageInputUnit, value.toMapString());
    }

    ConverterUnit _outputUnit = ConverterUnit.lengthMeter;
    ConverterUnit
    get outputUnit => _outputUnit;
    set outputUnit(ConverterUnit value){
        _outputUnit = value;
        _update(SettingsKey.converterPageOutputUnit, value.toMapString());
    }

    void _update(SettingsKey key, dynamic value, [bool notify = true]){
        if (notify) notifyListeners();
        Settings.set(key, value);
    }

    void readFile(){
        input = Settings.get(SettingsKey.converterPageInput) ?? "";
        converter = Converter.values.byName(Settings.get(SettingsKey.converterPageConverter) ?? Converter.length.name);
        inputUnit = ConverterUnit.parse(Settings.get(SettingsKey.converterPageInputUnit) ?? ConverterUnit.lengthKilometer.toMapString());
        outputUnit = ConverterUnit.parse(Settings.get(SettingsKey.converterPageOutputUnit) ?? ConverterUnit.lengthMeter.toMapString());
    }
}