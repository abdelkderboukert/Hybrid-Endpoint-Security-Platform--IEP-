import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  runApp(const MyApp());
}

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'LSC Frontend',
      debugShowCheckedModeBanner: false,
      theme: FluentThemeData(brightness: Brightness.dark),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int topIndex = 0;
  PaneDisplayMode displayMode = PaneDisplayMode.open;

  // The _NavigationBodyItem is a placeholder widget to display content
  // for each navigation pane item.
  // You should define this class in your code.
  // This is how it should be implemented:
  final List<NavigationPaneItem> items = [
    PaneItem(
      icon: const Icon(FluentIcons.home),
      title: const Text('Home'),
      body: FluentApp(
        home: Center(child: Text('Home Page')),
        theme: FluentThemeData(brightness: Brightness.dark),
      ),
    ),
    PaneItemSeparator(),
    PaneItem(
      icon: const Icon(FluentIcons.issue_tracking),
      title: const Text('Information Panel'),
      // infoBadge: const InfoBadge(source: Text('8')),
      body: const Center(child: Text('Information Panel Page')),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.people),
      title: const Text('Users'),
      body: const Center(child: Text('Information Panel Page')),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.devices2),
      title: const Text('Devices'),
      body: const Center(child: Text('Information Panel Page')),
    ),
    PaneItemExpander(
      icon: const Icon(FluentIcons.account_management),
      title: const Text('Account'),
      body: const Center(child: Text('Account Page')),
      items: [
        PaneItemHeader(header: const Text('Apps')),
        PaneItem(
          icon: const Icon(FluentIcons.mail),
          title: const Text('Mail'),
          body: const Center(child: Text('Mail Page')),
        ),
        PaneItem(
          icon: const Icon(FluentIcons.calendar),
          title: const Text('Calendar'),
          body: const Center(child: Text('Calendar Page')),
        ),
      ],
    ),

    PaneItemExpander(
      icon: const Icon(FluentIcons.task_manager),
      title: const Text('Management'),
      body: const Center(child: Text('Account Page')),
      items: [
        PaneItemHeader(header: const Text('Apps')),
        PaneItem(
          icon: const Icon(FluentIcons.admin),
          title: const Text('Admins'),
          body: const Center(child: Text('Admin Page')),
        ),
        PaneItem(
          icon: const Icon(FluentIcons.server),
          title: const Text('Servers'),
          body: const Center(child: Text('Servers Page')),
        ),
        PaneItem(
          icon: const Icon(FluentIcons.access_logo),
          title: const Text('Licenses'),
          body: const Center(child: Text('Licenses Page')),
        ),
      ],
    ),

    PaneItemExpander(
      icon: const Icon(FluentIcons.security_group),
      title: const Text('Security & Monitoring'),
      body: const Center(child: Text('Security & Monitoring Page')),
      items: [
        // PaneItemHeader(header: const Text('Apps')),
        PaneItem(
          icon: const Icon(FluentIcons.three_quarter_circle),
          title: const Text('Threats'),
          body: const Center(child: Text('Threats Page')),
        ),
        PaneItem(
          icon: const Icon(FluentIcons.assign_policy),
          title: const Text('Policies'),
          body: const Center(child: Text('Policies Page')),
        ),
        PaneItem(
          icon: const Icon(FluentIcons.desktop_flow),
          title: const Text('User Monitoring'),
          body: const Center(child: Text('User Monitoring Page')),
        ),
        PaneItem(
          icon: const Icon(FluentIcons.data_flow),
          title: const Text('Data Integrity'),
          body: const Center(child: Text('Data Integrity Page')),
        ),
      ],
    ),

    PaneItemWidgetAdapter(
      child: Builder(
        builder: (context) {
          if (NavigationView.of(context).displayMode ==
              PaneDisplayMode.compact) {
            return const FlutterLogo();
          }
          return const Row(
            children: [
              FlutterLogo(),
              SizedBox(width: 6.0),
              Text('This is a custom widget'),
            ],
          );
        },
      ),
    ),
  ];

  String? selected;

  final cats = <String>[
    'Abyssinian',
    'Aegean',
    'American Bobtail',
    'American Curl',
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      // appBar: const NavigationAppBar(
      //   title: Text('NavigationView'),
      //   automaticallyImplyLeading: false,
      // ),
      pane: NavigationPane(
        selected: topIndex,
        onItemPressed: (index) {
          if (index == topIndex) {
            if (displayMode == PaneDisplayMode.open) {
              setState(() => displayMode = PaneDisplayMode.compact);
            } else if (displayMode == PaneDisplayMode.compact) {
              setState(() => displayMode = PaneDisplayMode.open);
            }
          }
        },
        onChanged: (index) => setState(() => topIndex = index),
        displayMode: displayMode,
        header: Container(
          padding: const EdgeInsets.only(right: 8.0),
          child: Center(
            child: AutoSuggestBox<String>(
              placeholder: 'Search',
              items: cats.map((cat) {
                return AutoSuggestBoxItem<String>(
                  value: cat,
                  label: cat,
                  onFocusChange: (focused) {
                    if (focused) {
                      debugPrint('Focused $cat');
                    }
                  },
                );
              }).toList(),
              onSelected: (item) {
                setState(() => selected = item.value);
              },
            ),
          ),
        ),
        items: items,
        footerItems: [
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Settings'),
            body: const Center(child: Text('Settings Page')),
          ),
          PaneItemAction(
            icon: const Icon(FluentIcons.add),
            title: const Text('Add New Item'),
            onTap: () {
              setState(() {
                items.add(
                  PaneItem(
                    icon: const Icon(FluentIcons.new_folder),
                    title: const Text('New Item'),
                    body: const Center(
                      child: Text('This is a newly added Item'),
                    ),
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
