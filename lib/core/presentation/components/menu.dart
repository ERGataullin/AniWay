import 'package:app/core/domain/models/menu_item.dart';
import 'package:flutter/material.dart';

export '../../domain/models/menu_item.dart';

Future<void> showModalMenuBottomSheet({
  required BuildContext context,
  required List<MenuItemData> items,
}) {
  return Navigator.of(context).push(
    ModalBottomSheetRoute<void>(
      isScrollControlled: true,
      modalBarrierColor: Theme.of(context).bottomSheetTheme.modalBarrierColor,
      showDragHandle: true,
      builder: (context) => MenuWidget(
        items: items
            .map(
              (item) => _popOnSelectedProxyMapper(context: context, item: item),
            )
            .toList(growable: false),
      ),
    ),
  );
}

MenuItemData _popOnSelectedProxyMapper({
  required BuildContext context,
  required MenuItemData item,
}) {
  return item.copyWith(
    children: item.children
        .map((item) => _popOnSelectedProxyMapper(context: context, item: item))
        .toList(growable: false),
    onSelected: item.hasChildren
        ? item.onSelected
        : () {
            Navigator.pop(context);
            item.onSelected?.call();
          },
  );
}

class MenuWidget extends StatefulWidget {
  const MenuWidget({super.key, required this.items});

  final List<MenuItemData> items;

  @override
  State<MenuWidget> createState() => _SelectionWidgetState();
}

class _SelectionWidgetState extends State<MenuWidget> {
  IconData? _icon;

  String? _title;

  late List<MenuItemData> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedSize(
        alignment: .topCenter,
        curve: Easing.standard,
        duration: Durations.medium2,
        child: Column(
          key: ValueKey(_items),
          mainAxisSize: .min,
          children: [
            if (_title != null)
              AppBar(
                forceMaterialTransparency: true,
                automaticallyImplyLeading: false,
                leading: _icon == null ? null : Icon(_icon),
                title: Text(_title!),
              ),
            ..._items.map((item) => _buildItem(context, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, MenuItemData item) {
    final MenuItemData? selectedChild = item.children
        .cast<MenuItemData?>()
        .singleWhere((item) => item!.selected, orElse: () => null);

    return ListTile(
      dense: true,
      enabled: item.enabled,
      selected: item.selected,
      visualDensity: .adaptivePlatformDensity,
      onTap: () => _handleItemSelected(item),
      leading: item.icon == null
          ? item.selected
                ? const Icon(Icons.done_outlined)
                : const SizedBox.shrink()
          : Icon(item.icon),
      title: Text(item.label, maxLines: 1, softWrap: false, overflow: .fade),
      trailing: item.hasChildren
          ? Row(
              mainAxisSize: .min,
              children: [
                if (selectedChild != null)
                  SizedBox(
                    width: 32,
                    child: Text(
                      selectedChild.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: .fade,
                    ),
                  ),
                const Icon(Icons.chevron_right_outlined),
              ],
            )
          : item.trailing == null
          ? null
          : Text(item.trailing!),
    );
  }

  void _handleItemSelected(MenuItemData item) {
    item.onSelected?.call();
    if (item.hasChildren) {
      setState(() {
        _icon = item.icon;
        _title = item.label;
        _items = item.children;
      });
    }
  }
}
