import 'package:core/src/domain/models/selection_item.dart';
import 'package:flutter/material.dart';

export 'package:core/src/domain/models/selection_item.dart';

Future<T?> showSelectionBottomSheet<T>({
  required BuildContext context,
  required List<SelectionItemData> items,
}) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    // clipBehavior: Clip.hardEdge,
    builder: (context) => SelectionWidget(
      items: items
          .map(
            (item) => _popOnSelectedProxyMapper(
              context: context,
              item: item,
            ),
          )
          .toList(growable: false),
    ),
  );
}

SelectionItemData _popOnSelectedProxyMapper({
  required BuildContext context,
  required SelectionItemData item,
}) {
  return switch (item) {
    SelectionSingleItemData _ => item.copyWith(
        onSelected: () {
          Navigator.pop(context);
          item.onSelected();
        },
      ),
    SelectionGroupItemData _ => item.copyWith(
        items: item.items
            .map(
              (item) => _popOnSelectedProxyMapper(
                context: context,
                item: item,
              ),
            )
            .toList(growable: false),
      ),
  };
}

class SelectionWidget extends StatefulWidget {
  const SelectionWidget({
    super.key,
    required this.items,
  });

  final List<SelectionItemData> items;

  @override
  State<SelectionWidget> createState() => _SelectionWidgetState();
}

class _SelectionWidgetState extends State<SelectionWidget> {
  late List<SelectionItemData> items;

  @override
  void initState() {
    super.initState();
    items = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: items.length,
      separatorBuilder: (context, __) => const SizedBox(height: 8),
      itemBuilder: _buildItem,
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final SelectionItemData item = items[index];
    return ListTile(
      enabled: item.enabled,
      leading: item.icon == null ? null : Icon(item.icon),
      title: Text(item.label),
      selected: switch (item) {
        SelectionSingleItemData _ => item.selected,
        SelectionGroupItemData _ => false,
      },
      onTap: switch (item) {
        SelectionSingleItemData _ => item.onSelected,
        SelectionGroupItemData _ => () => setState(() {
              items = item.items;
            }),
      },
    );
  }
}
