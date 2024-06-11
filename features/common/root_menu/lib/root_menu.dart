import 'package:flutter/material.dart';

class RootMenu extends StatefulWidget {
  const RootMenu({
    super.key,
    required this.destinations,
    required this.onDestinationSelected,
    required this.child,
  });

  final List<NavigationDestination> destinations;

  final ValueChanged<int> onDestinationSelected;

  final Widget child;

  @override
  State<RootMenu> createState() => _RootMenuState();
}

class _RootMenuState extends State<RootMenu> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: widget.destinations,
        onDestinationSelected: (index) => setState(() {
          _selectedIndex = index;
          widget.onDestinationSelected(index);
        }),
      ),
    );
  }
}
