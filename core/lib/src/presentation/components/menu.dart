import 'package:core/src/domain/models/menu_item.dart';
import 'package:flutter/material.dart';

export 'package:core/src/domain/models/menu_item.dart';

Future<void> showModalMenuBottomSheet({
  required BuildContext context,
  required List<MenuItemData> items,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => MenuWidget(
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

MenuItemData _popOnSelectedProxyMapper({
  required BuildContext context,
  required MenuItemData item,
}) {
  return item.copyWith(
    children: item.children
        .map(
          (item) => _popOnSelectedProxyMapper(
            context: context,
            item: item,
          ),
        )
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
  const MenuWidget({
    super.key,
    required this.items,
  });

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
    return Scrollbar(
      thumbVisibility: true,
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          if (_title != null)
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              leading: _icon == null ? null : Icon(_icon),
              title: Text(_title!),
            ),
          SliverList.separated(
            itemCount: _items.length,
            separatorBuilder: (context, __) {
              return const SizedBox(height: 8);
            },
            itemBuilder: _buildItem,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final MenuItemData item = _items[index];
    final MenuItemData? selectedChild =
        item.children.cast<MenuItemData?>().singleWhere(
              (item) => item!.selected,
              orElse: () => null,
            );

    return ListTile(
      dense: true,
      enabled: item.enabled,
      selected: item.selected,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      onTap: () => _onItemSelected(item),
      leading: item.icon == null
          ? item.selected
              ? const Icon(Icons.done)
              : const SizedBox.shrink()
          : Icon(item.icon),
      title: Text(
        item.label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
      trailing: item.hasChildren
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedChild != null)
                  SizedBox(
                    width: 32,
                    child: Text(
                      selectedChild.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                const Icon(Icons.chevron_right),
              ],
            )
          : null,
    );
  }

  void _onItemSelected(MenuItemData item) {
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
