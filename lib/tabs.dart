import 'package:flutter/material.dart';

mixin TabsManager<T extends StatefulWidget> on State<T> {
  final tabs = <int>[];
  int selected = 0;
  int _nextId = 1;

  void spawnTab() {
    tabs.add(_nextId++);
    setState(() => selected = tabs.length);
  }

  void closeTab(int i) {
    tabs.removeAt(i);
    setState(() => selected = selected > tabs.length ? tabs.length : selected);
  }

  PreferredSizeWidget buildTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(44),
      child: SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildTab(0, 'Home', null),
            for (var i = 0; i < tabs.length; i++)
              _buildTab(i + 1, 'Universe #${tabs[i]}', i),
          ],
        ),
      ),
    );
  }

  Widget buildTabContent(Widget home, Widget Function(int id) universeBuilder) {
    return IndexedStack(
      index: selected,
      children: [home, for (var id in tabs) universeBuilder(id)],
    );
  }

  Widget _buildTab(int idx, String label, int? closeIdx) {
    final sel = selected == idx;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => selected = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: sel
              ? const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.greenAccent, width: 2),
                  ),
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                closeIdx == null ? Icons.home : Icons.public,
                size: 16,
                color: sel ? Colors.greenAccent : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: sel ? Colors.greenAccent : Colors.grey,
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (closeIdx != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => closeTab(closeIdx),
                  child: const Icon(Icons.close, size: 14, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
