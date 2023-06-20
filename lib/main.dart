// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:calculator/utils/build_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './pages/basic.dart';
import './pages/scientific.dart';
import './pages/converter.dart';
import './pages/programmer.dart';
import './pages/date.dart';
import './data/settings.dart';
import 'data/enums.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    var settings = Settings();
    await settings.readFile();

    runApp(MultiProvider(
        providers: [
            ChangeNotifierProvider.value(value: settings),
        ],
        child: const MyApp(),
    ));
}

class MyApp extends StatefulWidget {
    const MyApp({super.key});

    @override
    State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
    ThemeData _themeData(ColorScheme colorScheme){
        final TextTheme textTheme = context.textTheme;

        return ThemeData(
            colorScheme: colorScheme,
            useMaterial3: true,
            scaffoldBackgroundColor: colorScheme.background,
            appBarTheme: AppBarTheme(titleTextStyle: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontFamily: 'Plus Jakarta Sans'
            )),
            snackBarTheme: const SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
            ),
            dialogTheme: DialogTheme(titleTextStyle: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
                fontFamily: 'Plus Jakarta Sans'
            )),
        );
    }

    @override
    void initState(){
        super.initState();
        WidgetsBinding.instance.addObserver(this);
    }

    @override
    void didChangeAppLifecycleState(AppLifecycleState state) async {
        if (state == AppLifecycleState.resumed) {
            context.changeSystemUI();
        }
    }

    @override
    void dispose(){
        WidgetsBinding.instance.removeObserver(this);
        super.dispose();
    }

    @override
    Widget build(BuildContext context){
        ColorScheme lightColorScheme = ColorScheme.fromSeed(
            seedColor: context.settings(true).color,
            brightness: Brightness.light
        );
        ColorScheme darkColorScheme = ColorScheme.fromSeed(
            seedColor: context.settings(true).color,
            brightness: Brightness.dark
        );
        context.changeSystemUI();
        return MaterialApp(
            title: 'Calculator',
            debugShowCheckedModeBanner: false,
            themeMode: context.settings(true).theme,
            theme: _themeData(lightColorScheme),
            darkTheme: _themeData(darkColorScheme),
            home: (() => switch (context.settings().lastPage){
                Routes.basic => const BasicPage(),
                Routes.scientific => const ScientificPage(),
                Routes.converter => const ConverterPage(),
                Routes.programmer => const ProgrammerPage(),
                Routes.date => const DatePage(),
                _ => const BasicPage()
            })()
        );
    }
}