import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:root_menu/root_menu.dart';
import 'package:root_menu/src/presentation/root_menu/model.dart';

RootMenuWM rootMenuWMFactory(BuildContext context) => RootMenuWM(
      RootMenuModel(
        context.read<ErrorHandler>(),
      ),
    );

abstract interface class IRootMenuWM implements IWidgetModel {
  ValueListenable<Widget> get child;

  ValueListenable<int> get selectedIndex;

  ValueListenable<int> get destinationsCount;

  ValueListenable<List<IconData>> get destinationsIcons;

  ValueListenable<List<String>> get destinationsLabels;

  void onDestinationSelected(int index);
}

class RootMenuWM extends WidgetModel<RootMenuWidget, IRootMenuModel>
    implements IRootMenuWM {
  RootMenuWM(super._model);

  @override
  late final ValueNotifier<Widget> child;

  @override
  final ValueNotifier<int> selectedIndex = ValueNotifier(0);

  @override
  final ValueNotifier<int> destinationsCount = ValueNotifier(0);

  @override
  final ValueNotifier<List<IconData>> destinationsIcons =
      ValueNotifier(const []);

  @override
  final ValueNotifier<List<String>> destinationsLabels =
      ValueNotifier(const []);

  List<MenuDestinationData> get _destinations => widget.destinations;

  OnRootMenuDestinationSelected get _onDestinationSelected =>
      widget.onDestinationSelected;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    child = ValueNotifier(widget.child);
    _updateConfiguration();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    child.value = widget.child;
    _updateConfiguration();
  }

  @override
  void didChangeDependencies() {
    _updateConfiguration();
  }

  @override
  void onDestinationSelected(int index) {
    _onDestinationSelected(index);
  }

  @override
  void dispose() {
    super.dispose();
    child.dispose();
    selectedIndex.dispose();
    destinationsCount.dispose();
    destinationsIcons.dispose();
    destinationsLabels.dispose();
  }

  void _updateConfiguration() {
    selectedIndex.value = widget.selectedIndex;
    destinationsCount.value = _destinations.length;
    destinationsIcons.value = _destinations
        .map(
          (destination) => switch (destination) {
            MenuDestinationData.home => Icons.home,
            MenuDestinationData.store => Icons.store,
            MenuDestinationData.library => Icons.video_library,
            MenuDestinationData.search => Icons.search,
          },
        )
        .toList(growable: false);
    destinationsLabels.value = _destinations
        .map(
          (destination) => context.localizations.destinationLabel(
            destination.name,
          ),
        )
        .toList(growable: false);
  }
}
