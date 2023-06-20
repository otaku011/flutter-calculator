import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'color.dart';
import '../data/settings.dart';

extension BuildContextUtils on BuildContext {
    MediaQueryData
    get mediaQueryData => MediaQuery.of(this);

    ThemeData
    get themeData => Theme.of(this);

    ColorScheme
    get colorScheme => themeData.colorScheme;

    TextTheme
    get textTheme => themeData.textTheme;

    bool
    get isBigScreen => mediaQueryData.size.width > 700;

    void changeSystemUI(){
        bool isDarkMode = settings().theme == ThemeMode.dark || (
            settings().theme == ThemeMode.system &&
            mediaQueryData.platformBrightness == Brightness.dark
        );

        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor                   : Colors.transparent,
            statusBarIconBrightness          : isDarkMode? Brightness.light : Brightness.dark,
            systemNavigationBarColor         : settings().color.colorScheme(isDarkMode? Brightness.dark : Brightness.light).background,
            systemNavigationBarIconBrightness: isDarkMode? Brightness.light : Brightness.dark
        ));
    }

    Settings settings([bool listen = false]){
        return Provider.of<Settings>(this, listen: listen);
    }

    Future<T?> navigate<T extends Object?>({
        required Widget Function(BuildContext) builder,
        bool replace = false
    }){
        return replace
            ? Navigator.pushReplacement(this, MaterialPageRoute(builder: builder))
            : Navigator.push(this, MaterialPageRoute(builder: builder))
        ;
    }

    void navigateBack<T extends Object?>([T? result]){
        return Navigator.pop(this, result);
    }

    void showSnackBar(
        Widget content, {
            bool showCloseIcon = false,
            SnackBarAction? action
        }
    ){
        ScaffoldMessenger.of(this).showSnackBar(SnackBar(
            content: content,
            action: action,
            showCloseIcon: showCloseIcon,
            width: isBigScreen? 500 : null,
        ));
    }
}