import 'package:flutter/material.dart';

extension ColorConversion on Color {
    Color
    get contrastColor => isColorBrightnessLight? Colors.black : Colors.white;

    bool
    get isColorBrightnessLight => ThemeData.estimateBrightnessForColor(this) == Brightness.light;

    ColorScheme colorScheme([Brightness brightness = Brightness.light]){
        return ColorScheme.fromSeed(seedColor: this, brightness: brightness);
    }
}