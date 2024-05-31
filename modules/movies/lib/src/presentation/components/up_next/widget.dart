import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/presentation/components/up_next/wm.dart';

extension _UpNextContext on BuildContext {
  IUpNextWM get wm => read<IUpNextWM>();
}

class UpNextWidget extends ElementaryWidget<IUpNextWM> {
  const UpNextWidget({
    super.key,
    required this.upNext,
    required this.onPressed,
    WidgetModelFactory wmFactory = upNextWMFactory,
  }) : super(wmFactory);

  static const double aspectRatio = 4 / 3;

  final UpNextData upNext;

  final VoidCallback onPressed;

  @override
  Widget build(IUpNextWM wm) {
    return Provider.value(
      value: wm,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Builder(
            builder: (context) => InkWell(
              onTap: onPressed,
              customBorder: Theme.of(context).cardTheme.shape,
              child: const Column(
                children: [
                  _Poster(),
                  _Footer(margin: EdgeInsets.all(8)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: context.wm.poster,
        builder: (context, poster, ___) => Ink.image(
          image: poster,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    this.margin = EdgeInsets.zero,
  });

  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Title(),
          SizedBox(height: 2),
          _Episode(),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: context.wm.title,
      builder: (context, title, ___) => Text(
        title,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _Episode extends StatelessWidget {
  const _Episode();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ValueListenableBuilder<String>(
        valueListenable: context.wm.episode,
        builder: (context, episode, ___) => Text(
          episode,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}
