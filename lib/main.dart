import 'package:flutter/material.dart';
import 'tabs.dart';
import 'universe.dart';
import 'widgets/widgets.dart';

final chaosVelocity = ValueNotifier<double>(3.0);

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext c) => MaterialApp(
    title: 'Multiverse of Madness',
    theme: ThemeData.dark(),
    debugShowCheckedModeBanner: false,
    home: const MainScreen(),
  );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TabsManager {
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
              SpawnButton(onPressed: spawnTab),
            ],
          ),
        ),
      ),
    ],
  );
}
