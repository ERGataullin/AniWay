import 'package:flutter/widgets.dart';

sealed class SelectionItemData {
  const SelectionItemData({
    this.enabled = true,
    this.icon,
    required this.label,
  });

  final bool enabled;

  final IconData? icon;

  final String label;
}

class SelectionSingleItemData extends SelectionItemData {
  const SelectionSingleItemData({
    super.enabled,
    super.icon,
    required super.label,
    this.selected = false,
    required this.onSelected,
  });

  final bool selected;

  final VoidCallback onSelected;

  SelectionSingleItemData copyWith({
    bool? enabled,
    IconData? icon,
    String? label,
    VoidCallback? onSelected,
  }) =>
      SelectionSingleItemData(
        enabled: enabled ?? this.enabled,
        icon: icon ?? this.icon,
        label: label ?? this.label,
        onSelected: onSelected ?? this.onSelected,
      );
}

class SelectionGroupItemData extends SelectionItemData {
  const SelectionGroupItemData({
    super.enabled,
    super.icon,
    required super.label,
    required this.items,
  });

  final List<SelectionItemData> items;

  SelectionGroupItemData copyWith({
    bool? enabled,
    IconData? icon,
    String? label,
    List<SelectionItemData>? items,
  }) =>
      SelectionGroupItemData(
        enabled: enabled ?? this.enabled,
        icon: icon ?? this.icon,
        label: label ?? this.label,
        items: items ?? this.items,
      );
}
