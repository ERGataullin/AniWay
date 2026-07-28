part of '../widget.dart';

class _Description extends StatelessWidget {
  const _Description({required this.margin});

  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: ValueListenableBuilder(
        valueListenable: context.wm.description,
        builder: (context, description, child) {
          return description == null
              ? const SizedBox.shrink()
              : Padding(
                padding: margin,
                child: ExpandableText(
                  description,
                  style:
                      Breakpoints.mediumAndUp.isActive(context)
                          ? TextTheme.of(context).bodyLarge
                          : null,
                ),
              );
        },
      ),
    );
  }
}
