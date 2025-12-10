// ignore_for_file: invalid_use_of_internal_member

import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:flutter/src/widgets/_window.dart';
import 'tabs.dart';
import 'universe.dart';
import 'widgets/widgets.dart';

final chaosVelocity = ValueNotifier<double>(3.0);

void main() {
  runWidget(const _App());
}

class _App extends StatefulWidget {
  const _App();

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  final RegularWindowController windowController = RegularWindowController(
    delegate: RegularWindowControllerDelegate(),
    preferredSize: const Size(800, 600),
    title: 'Game of Life',
  );

  @override
  void dispose() {
    windowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => RegularWindow(
    controller: windowController,
    child: MaterialApp(
      title: 'Multiverse of Madness',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    ),
  );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _UniverseWindowDelegate extends RegularWindowControllerDelegate {
  final VoidCallback onDestroyed;

  _UniverseWindowDelegate({required this.onDestroyed});

  @override
  void onWindowDestroyed() {
    onDestroyed();
    super.onWindowDestroyed();
  }
}

class _MainScreenState extends State<MainScreen> with TabsManager {
  final _windows = <int, RegularWindowController>{};
  int next = 0;

  Future<void> spawnUniverseWindow() async {
    final id = next++;
    final wc = RegularWindowController(
      delegate: _UniverseWindowDelegate(
        onDestroyed: () => setState(() => _windows.remove(id)),
      ),
      preferredSize: const Size(400, 300),
      title: 'Game of Life',
    );
    setState(() => _windows[id] = wc);
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiverse of Madness ???'),
        actionsPadding: const EdgeInsets.only(right: 10),
        actions: [
          IconButton(
            onPressed: spawnTab,
            icon: const Icon(Icons.add_box_outlined),
          ),
          for (final window in _windows.entries)
            ViewAnchor(
              view: RegularWindow(
                controller: window.value,
                child: UniverseScreen(universeId: window.key),
              ),
              child: const SizedBox.shrink(),
            ),
        ],
        bottom: buildTabBar(),
      ),
      body: buildTabContent(_home(), (id) => UniverseScreen(universeId: id)),
    );
  }

  Widget _home() => Stack(
    fit: StackFit.expand,
    children: [
      Image.asset('assets/bg.png', fit: BoxFit.cover),
      Container(color: Colors.black.withValues(alpha: 0.7)),
      Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const HomeHero(),
              ValueListenableBuilder<double>(
                valueListenable: chaosVelocity,
                builder: (_, v, __) => VelocitySlider(
                  value: v,
                  onChanged: (v) => chaosVelocity.value = v,
                ),
              ),
              SpawnButton(onPressed: spawnUniverseWindow),
            ],
          ),
        ),
      ),
    ],
  );
}
