import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/modules/movies/domain/models/up_next.dart';
import '/modules/movies/presentation/components/up_next/widget_model.dart';

extension _UpNextContext on BuildContext {
  IUpNextWidgetModel get wm => read<IUpNextWidgetModel>();
}

class UpNextWidget extends ElementaryWidget<IUpNextWidgetModel> {
  const UpNextWidget({
    super.key,
    required this.upNext,
    required this.onPressed,
    WidgetModelFactory wmFactory = upNextWidgetModelFactory,
  }) : super(wmFactory);

  static const double aspectRatio = 4 / 3;

  final UpNextData upNext;

  final VoidCallback onPressed;

  @override
  Widget build(IUpNextWidgetModel wm) {
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
  const _Poster({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder<String>(
        valueListenable: context.wm.posterUrl,
        builder: (context, posterUrl, ___) => Ink.image(
          image: NetworkImage(posterUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    super.key,
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
          _Status(),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({super.key});

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

class _Status extends StatelessWidget {
  const _Status({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ValueListenableBuilder<String>(
        valueListenable: context.wm.status,
        builder: (context, status, ___) => Text(
          status,
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