import 'package:flutter/widgets.dart';

class MenuItemData {
  const MenuItemData.single({
    this.enabled = true,
    this.selected = false,
    this.icon,
    required this.label,
    this.onSelected,
  }) : children = const [];

  const MenuItemData.group({
    this.selected = false,
    this.icon,
    required this.label,
    required this.children,
    this.onSelected,
  }) : enabled = children.length > 0;

  const MenuItemData.raw({
    this.enabled = true,
    this.selected = false,
    this.icon,
    required this.label,
    this.onSelected,
    this.children = const [],
  });

  final bool enabled;

  final bool selected;

  final IconData? icon;

  final String label;

  final VoidCallback? onSelected;

  final List<MenuItemData> children;

  bool get hasChildren => children.isNotEmpty;

  MenuItemData copyWith({
    bool? enabled,
    bool? selected,
    IconData? icon,
    String? label,
    VoidCallback? onSelected,
    List<MenuItemData>? children,
  }) =>
      MenuItemData.raw(
        enabled: enabled ?? this.enabled,
        selected: selected ?? this.selected,
        icon: icon ?? this.icon,
        label: label ?? this.label,
        onSelected: onSelected ?? this.onSelected,
        children: children ?? this.children,
      );
}
