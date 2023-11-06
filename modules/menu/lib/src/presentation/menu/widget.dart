import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:menu/menu.dart';
import 'package:menu/src/presentation/menu/widget_model.dart';
import 'package:provider/provider.dart';

typedef OnMenuDestinationSelected = void Function(int index);

extension _MenuContext on BuildContext {
  IMenuWidgetModel get wm => read<IMenuWidgetModel>();
}

class MenuWidget extends ElementaryWidget<IMenuWidgetModel> {
  const MenuWidget({
    super.key,
    this.selectedIndex = 0,
    required this.destinations,
    required this.onDestinationSelected,
    WidgetModelFactory wmFactory = menuWidgetModelFactory,
    required this.child,
  }) : super(wmFactory);

  final int selectedIndex;
  final List<MenuDestinationData> destinations;
  final OnMenuDestinationSelected onDestinationSelected;
  final Widget child;

  @override
  Widget build(IMenuWidgetModel wm) {
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
