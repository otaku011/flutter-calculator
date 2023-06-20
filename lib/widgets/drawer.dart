import 'package:calculator/utils/build_context.dart';
import 'package:flutter/material.dart';

import '../data/enums.dart';
import '../pages/settings.dart';
import '../pages/basic.dart';
import '../pages/scientific.dart';
import '../pages/converter.dart';
import '../pages/programmer.dart';
import '../pages/date.dart';

class NavigationDrawerWidget extends StatelessWidget {
    const NavigationDrawerWidget({super.key, required this.selectedIndex});

    final int selectedIndex;

    @override
    Widget build(BuildContext context) {
        const List<List<dynamic>> mainRoutes = [
            [Routes.basic, "Basic", Icons.calculate_outlined],
            [Routes.scientific, "Scientific", Icons.science_outlined],
            [Routes.converter, "Converter", Icons.swap_horiz_outlined],
            [Routes.programmer, "Programmer", Icons.code_outlined],
            [Routes.date, "Date", Icons.today_outlined]
        ];
        final ColorScheme colorScheme = context.colorScheme;
        final TextTheme textTheme = context.textTheme;

        Widget header = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Text('Calculator', style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                letterSpacing: 1.5,
                fontFamily: 'Plus Jakarta Sans'
            )),
        );

        List<Widget> children = <Widget>[
            const SizedBox(height: 28),
            header,
            const SizedBox(height: 16),
            ...mainRoutes.map<NavigationDrawerDestination>((nav) => NavigationDrawerDestination(
                icon: Icon(nav[2]),
                label: Text(nav[1])
            )).toList(),
            const Divider(endIndent: 28, indent: 28),
            const NavigationDrawerDestination(
                icon: Icon(Icons.settings_outlined),
                label: Text('Settings')
            ),
            const SizedBox(height: 16),
        ];

        return SafeArea(top: false, child: NavigationDrawer(
            selectedIndex: selectedIndex,
            children: children,
            onDestinationSelected: (index){

                context.navigateBack();
                if (index == selectedIndex) return;

                // settings page
                if (index == 5) {
                    context.navigate(builder: (context) => const SettingsPage());
                    return;
                }

                // randomizer page
                context.settings().lastPage = mainRoutes[index][0];
                context.navigate(builder: (context) => switch (context.settings().lastPage){
                    Routes.basic      => const BasicPage(),
                    Routes.converter  => const ConverterPage(),
                    Routes.date       => const DatePage(),
                    Routes.programmer => const ProgrammerPage(),
                    Routes.scientific => const ScientificPage(),
                    _ => Container()
                }, replace: true);
            },
        ));
    }
}