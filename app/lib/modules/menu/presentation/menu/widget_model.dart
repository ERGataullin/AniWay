import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/app/localizations.dart';
import '/modules/menu/presentation/menu/model.dart';
import '/modules/menu/presentation/menu/widget.dart';

MenuWidgetModel menuWidgetModelFactory(BuildContext context) => MenuWidgetModel(
      MenuModel(
        context.read<ErrorHandler>(),
      ),
    );

abstract interface class IMenuWidgetModel implements IWidgetModel {
  ValueListenable<int> get selectedIndex;

  ValueListenable<int> get destinationsCount;

  ValueListenable<List<IconData>> get destinationsIcons;

  ValueListenable<List<String>> get destinationsLabels;

  void onDestinationSelected(int index);
}

class MenuWidgetModel extends WidgetModel<MenuWidget, IMenuModel>
    implements IMenuWidgetModel {
  MenuWidgetModel(super._model);

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

  OnMenuDestinationSelected get _onDestinationSelected =>
      widget.onDestinationSelected;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    _updateConfiguration();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
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
            MenuDestinationData.watchNow => Icons.play_circle,
            MenuDestinationData.store => Icons.store,
            MenuDestinationData.library => Icons.video_library,
            MenuDestinationData.search => Icons.search,
          },
        )
        .toList(growable: false);
    destinationsLabels.value = _destinations
        .map(
          (destination) => context.localizations.menuDestinationLabel(
            destination.name,
          ),
        )
        .toList(growable: false);
  }
}
