import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:root_menu/root_menu.dart';
import 'package:root_menu/src/presentation/root_menu/widget_model.dart';

typedef OnRootMenuDestinationSelected = void Function(int index);

extension _MenuContext on BuildContext {
  IRootMenuWidgetModel get wm => read<IRootMenuWidgetModel>();
}

class RootMenuWidget extends ElementaryWidget<IRootMenuWidgetModel> {
  const RootMenuWidget({
    super.key,
    this.selectedIndex = 0,
    required this.destinations,
    required this.onDestinationSelected,
    WidgetModelFactory wmFactory = rootMenuWidgetModelFactory,
    required this.child,
  }) : super(wmFactory);

  final int selectedIndex;
  final List<MenuDestinationData> destinations;
  final OnRootMenuDestinationSelected onDestinationSelected;
  final Widget child;

  @override
  Widget build(IRootMenuWidgetModel wm) {
    return Provider.value(
      value: wm,
      child: Scaffold(
        body: child,
        bottomNavigationBar: const _BottomNavigationBar(),
      ),
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: context.wm.destinationsCount,
      builder: (context, destinationsCount, ___) => ValueListenableBuilder<int>(
        valueListenable: context.wm.selectedIndex,
        builder: (context, selectedIndex, ___) => NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: context.wm.onDestinationSelected,
          destinations: List.generate(
            destinationsCount,
            (index) => _BottomNavigationBarItem(index: index),
            growable: false,
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationBarItem extends StatelessWidget {
  const _BottomNavigationBarItem({
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: context.wm.destinationsLabels,
      child: ValueListenableBuilder<List<IconData>>(
        valueListenable: context.wm.destinationsIcons,
        builder: (context, icons, ___) => Icon(icons[index]),
      ),
      builder: (context, destinationsLabels, icon) => NavigationDestination(
        icon: icon!,
        label: destinationsLabels[index],
      ),
    );
  }
}
