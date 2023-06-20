// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:calculator/utils/build_context.dart';
import 'package:calculator/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/enums.dart';
import '../data/settings.dart';
import '../utils/string.dart';

class SettingsPage extends StatefulWidget {
    const SettingsPage({super.key});

    @override
    State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

    void _showAboutApp() async {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();

        if (!mounted) return;

        showAboutDialog(
            context: context,
            applicationIcon: Image.asset('assets/images/icon-768x768.png', height: 48, filterQuality: FilterQuality.high),
            applicationName: "Calculator",
            applicationVersion: packageInfo.version,
            applicationLegalese: "©${DateTime.now().year} Redmerah"
        );
    }

    void _rateApp() async {
        Uri appUrl = Uri(
            scheme: "https",
            host: "play.google.com",
            path: "store/apps/details",
            queryParameters: {"id": "com.redmerah.calculator"}
        );
        if (await canLaunchUrl(appUrl)) await launchUrl(appUrl, mode: LaunchMode.externalApplication);
    }

    void _sendFeedback() async {
        Uri email = Uri(scheme: "mailto", path: "daundua2@gmail.com");
        if (await canLaunchUrl(email)) await launchUrl(email);
    }

    void _changeTheme() {
        const List<List<dynamic>> options = [
            ['System', ThemeMode.system],
            ['Light' , ThemeMode.light ],
            ['Dark'  , ThemeMode.dark  ]
        ];

        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                scrollable: true,
                icon: const Icon(Icons.brightness_4_outlined),
                title: const Text('Theme'),
                actions: [
                    TextButton(child: const Text('Close'), onPressed: () => context.navigateBack())
                ],
                content: Material(
                    color: Colors.transparent,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(options.length, (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: RadioListTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                                    topLeft    : Radius.circular(index == 0? 12 : 0),
                                    topRight   : Radius.circular(index == 0? 12 : 0),
                                    bottomLeft : Radius.circular(index == options.length-1? 12 : 0),
                                    bottomRight: Radius.circular(index == options.length-1? 12 : 0),
                                )),
                                tileColor: context.colorScheme.secondaryContainer,
                                title: Text(options[index][0], style: TextStyle(color: context.colorScheme.onSecondaryContainer)),
                                value: options[index][1],
                                groupValue: context.settings(true).theme,
                                onChanged: (value){
                                    context.settings().theme = value;
                                    context.changeSystemUI();
                                }
                            ),
                        ))
                    ),
                )
            )
        );
    }

    void _changeColor(){
        const List options = [
            ['Pink'       , Colors.pink      ],
            ['Red'        , Colors.red       ],
            ['Deep orange', Colors.deepOrange],
            ['Orange'     , Colors.orange    ],
            ['Amber'      , Colors.amber     ],
            ['Yellow'     , Colors.yellow    ],
            ['Lime'       , Colors.lime      ],
            ['Light green', Colors.lightGreen],
            ['Green'      , Colors.green     ],
            ['Teal'       , Colors.teal      ],
            ['Cyan'       , Colors.cyan      ],
            ['Light blue' , Colors.lightBlue ],
            ['Blue'       , Colors.blue      ],
            ['Indigo'     , Colors.indigo    ],
            ['Deep purple', Colors.deepPurple],
            ['Purple'     , Colors.purple    ],
            ['Grey'       , Colors.grey      ],
            ['Blue grey'  , Colors.blueGrey  ],
            ['Brown'      , Colors.brown     ],
        ];

        var settings = context.settings();

        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                scrollable: true,
                icon: const Icon(Icons.palette_outlined),
                title: const Text('App color'),
                content: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500.0),
                    child: Wrap(
                        spacing: 8.0,
                        alignment: WrapAlignment.spaceEvenly,
                        children: List.generate(options.length, (index){
                            bool selected = settings.color.value == options[index][1].value;
                            return IconButton(
                                tooltip: options[index][0],
                                onPressed: (){
                                    settings.color = options[index][1];
                                    context.changeSystemUI();
                                },
                                icon: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: options[index][1],
                                    ),
                                    width: 40,
                                    height: 40,
                                    child: selected? Icon(Icons.done_outlined, color: (options[index][1] as Color).contrastColor) : null,
                                )
                            );
                        })
                    ),
                ),
                actions: [
                    TextButton(onPressed: () => context.navigateBack(), child: const Text('Close'))
                ],
            )
        );
    }

    void _changeNumberFormatDecimal(){
        const List<List<dynamic>> options = [
            ['Comma', NumberFormatDecimals.comma],
            ['Point' , NumberFormatDecimals.point ],
        ];
        final Settings settings = context.settings();

        showDialog(
            context: context,
            builder: (context){
                Widget content = Material(
                    color: Colors.transparent,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(options.length, (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: RadioListTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                                    topLeft    : Radius.circular(index == 0? 12 : 0),
                                    topRight   : Radius.circular(index == 0? 12 : 0),
                                    bottomLeft : Radius.circular(index == options.length-1? 12 : 0),
                                    bottomRight: Radius.circular(index == options.length-1? 12 : 0),
                                )),
                                tileColor: context.colorScheme.secondaryContainer,
                                title: Text(options[index][0]),
                                value: options[index][1],
                                groupValue: settings.numberFormatDecimal,
                                onChanged: (value){
                                    settings.numberFormatDecimal = value;
                                    if (value == NumberFormatDecimals.comma && settings.numberFormatGrouping == NumberFormatGrouping.comma){
                                        settings.numberFormatGrouping = NumberFormatGrouping.point;
                                    }
                                    else if (value == NumberFormatDecimals.point && settings.numberFormatGrouping == NumberFormatGrouping.point){
                                        settings.numberFormatGrouping = NumberFormatGrouping.comma;
                                    }
                                }
                            ),
                        )),
                    ),
                );

                List<Widget> actions = [
                    TextButton(child: const Text("Close"), onPressed: () => Navigator.pop(context))
                ];

                return AlertDialog(
                    scrollable: true,
                    icon: const Icon(Icons.pin_outlined),
                    title: const Text('Decimal'),
                    actions: actions,
                    content: content,
                );
            }
        );
    }

    void _changeNumberFormatGrouping(){
        const List<List<dynamic>> options = [
            ['Comma', NumberFormatGrouping.comma],
            ['Point' , NumberFormatGrouping.point],
            ["None", NumberFormatGrouping.none],
            ["Space", NumberFormatGrouping.space],
            ["Underscore", NumberFormatGrouping.underscore]
        ];
        final Settings settings = context.settings();
        final ColorScheme colorScheme = context.colorScheme;

        showDialog(
            context: context,
            builder: (context){
                Widget content = Material(
                    color: Colors.transparent,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(options.length, (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: RadioListTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                                    topLeft    : Radius.circular(index == 0? 12 : 0),
                                    topRight   : Radius.circular(index == 0? 12 : 0),
                                    bottomLeft : Radius.circular(index == options.length-1? 12 : 0),
                                    bottomRight: Radius.circular(index == options.length-1? 12 : 0),
                                )),
                                tileColor: colorScheme.secondaryContainer,
                                title: Text(options[index][0]),
                                value: options[index][1],
                                groupValue: settings.numberFormatGrouping,
                                onChanged: (value){
                                    settings.numberFormatGrouping = value;
                                    if (value == NumberFormatGrouping.comma && settings.numberFormatDecimal == NumberFormatDecimals.comma){
                                        settings.numberFormatDecimal = NumberFormatDecimals.point;
                                    }
                                    if (value == NumberFormatGrouping.point && settings.numberFormatDecimal == NumberFormatDecimals.point){
                                        settings.numberFormatDecimal = NumberFormatDecimals.comma;
                                    }
                                }
                            ),
                        )),
                    ),
                );

                List<Widget> actions = [
                    TextButton(child: const Text("Done"), onPressed: () => Navigator.pop(context))
                ];

                return AlertDialog(
                    scrollable: true,
                    icon: const Icon(Icons.workspaces_outlined),
                    title: const Text('Grouping'),
                    actions: actions,
                    content: content
                );
            }
        );
    }

    Widget _appBar() {
        Widget title = const Text(
            'Settings',
            style: TextStyle(fontWeight: FontWeight.w600, fontFamily: "Plus Jakarta Sans")
        );

        Widget leading = IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)
        );

        Widget appBar = SliverAppBar.large(
            leadingWidth: 56.0,
            title: title,
            leading: leading,
        );

        if (context.isBigScreen) {
            appBar = SliverAppBar(
                leadingWidth: 56.0,
                title: title,
                leading: leading,
                pinned: true,
            );
        }

        return appBar;
    }

    Widget _body() {
        final Settings settings = context.settings(true);
        final ColorScheme colorScheme = context.colorScheme;
        final TextTheme textTheme = context.textTheme;

        List<Widget> general = [
            SwitchListTile(
                secondary: const Icon(Icons.memory_outlined),
                title: const Text("Memory buttons"),
                subtitle: const Text("Shown or hidden memory button (M, M+, M-, MR, MC)"),
                value: settings.memoryButton,
                onChanged: (value) => settings.memoryButton = value
            ),
            SwitchListTile(
                secondary: const Icon(Icons.e_mobiledata_outlined),
                title: const Text("Scientific notation"),
                subtitle: const Text("Display results in scientific notation (e.g., 1.2E-29)"),
                value: settings.scientificNotation,
                onChanged: (value) => settings.scientificNotation = value,
            ),
        ];

        List<Widget> themeColor = [
            ListTile(
                leading: const Icon(Icons.brightness_4_outlined),
                title: const Text('Theme'),
                subtitle: Text(
                    settings.theme.name.titleCase(),
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                onTap: _changeTheme,
            ),
            ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('App color'),
                subtitle: Text(<List>[
                    ['Pink'       , Colors.pink      ],
                    ['Red'        , Colors.red       ],
                    ['Deep orange', Colors.deepOrange],
                    ['Orange'     , Colors.orange    ],
                    ['Amber'      , Colors.amber     ],
                    ['Yellow'     , Colors.yellow    ],
                    ['Lime'       , Colors.lime      ],
                    ['Light green', Colors.lightGreen],
                    ['Green'      , Colors.green     ],
                    ['Teal'       , Colors.teal      ],
                    ['Cyan'       , Colors.cyan      ],
                    ['Light blue' , Colors.lightBlue ],
                    ['Blue'       , Colors.blue      ],
                    ['Indigo'     , Colors.indigo    ],
                    ['Deep purple', Colors.deepPurple],
                    ['Purple'     , Colors.purple    ],
                    ['Grey'       , Colors.grey      ],
                    ['Blue grey'  , Colors.blueGrey  ],
                    ['Brown'      , Colors.brown     ],
                ].firstWhere((element) => element[1].value == settings.color.value)[0]),
                trailing: SizedBox(
                    width: 32,
                    height: 32,
                    child: Card(color: settings.color),
                ),
                onTap: _changeColor,
            ),
        ];

        List<Widget> numberFormat = [
            SizedBox(
                width: double.infinity,
              child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  color: colorScheme.surfaceVariant,
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text("Preview:", style: textTheme.labelSmall),
                              const SizedBox(height: 4.0),
                              Text(
                                  "1*234*567-89"
                                  .replaceAll("-", (() => switch (settings.numberFormatDecimal){
                                      NumberFormatDecimals.point => ".",
                                      NumberFormatDecimals.comma => ","
                                  })())
                                  .replaceAll("*", (() => switch (settings.numberFormatGrouping){
                                      NumberFormatGrouping.none => "",
                                      NumberFormatGrouping.space => " ",
                                      NumberFormatGrouping.comma => ",",
                                      NumberFormatGrouping.point => ".",
                                      NumberFormatGrouping.underscore => "_"
                                  })()),
                                  style: const TextStyle(fontWeight: FontWeight.bold)
                              ),
                          ]
                      ),
                  ),
              ),
            ),
            ListTile(
                leading: const Icon(Icons.pin_outlined),
                title: const Text('Decimal'),
                subtitle: Text(
                    settings.numberFormatDecimal.name.titleCase(),
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                onTap: _changeNumberFormatDecimal,
            ),
            ListTile(
                leading: const Icon(Icons.workspaces_outlined),
                title: const Text('Grouping'),
                subtitle: Text(
                    settings.numberFormatGrouping.name.titleCase(),
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                onTap: _changeNumberFormatGrouping,
            ),
        ];

        List<Widget> others = List.generate(3, (index) {
            List options = [
                ["Rate & review app", Icons.star_outline, _rateApp],
                ["About", Icons.info_outline_rounded, _showAboutApp],
                ["Send feedback", Icons.chat_outlined, _sendFeedback],
            ];
            return ListTile(
                leading: Icon(options[index][1]),
                title: Text(options[index][0]),
                onTap: options[index][2],
            );
        });

        List<Widget> children = [
            Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8),
                child: Row(children: [Text("General", style: textTheme.titleSmall?.copyWith(color: colorScheme.primary))]),
            ),
            ...general,
            const Divider(indent: 16, endIndent: 16),
            Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8),
                child: Row(children: [Text("Theme & color", style: textTheme.titleSmall?.copyWith(color: colorScheme.primary))]),
            ),
            ...themeColor,
            const Divider(indent: 16, endIndent: 16),
            Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8),
                child: Row(children: [Text("Number format", style: textTheme.titleSmall?.copyWith(color: colorScheme.primary))]),
            ),
            ...numberFormat,
            const Divider(indent: 16, endIndent: 16),
            Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8),
                child: Row(children: [Text("About", style: textTheme.titleSmall?.copyWith(color: colorScheme.primary))]),
            ),
            ...others,
        ];

        Widget body = SliverList(delegate: SliverChildListDelegate(children));

        if (context.isBigScreen){
            body = SliverList(delegate: SliverChildListDelegate([Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Flexible(child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: ListTileTheme(
                        data: ListTileThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: Column(children: children),
                    ),
                ))]
            )]));
        }

        body = CustomScrollView(slivers: [
            _appBar(),
            body
        ]);

        return SafeArea(
            top: false,
            child: body
        );
    }

    @override
    Widget build(BuildContext context){
        context.changeSystemUI();
        return Scaffold(body: _body());
    }
}