import 'dart:math';

import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/domain/models/watch_list_element.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/presentation/watch_list/wm.dart';
import 'package:flutter/material.dart';

extension _WatchListContext on BuildContext {
  IWatchListWM get wm => read<IWatchListWM>();
}

class WatchListWidget extends ElementaryWidget<IWatchListWM> {
  const WatchListWidget({
    super.key,
    required this.movieId,
    required this.watchListElementData,
    WidgetModelFactory wmFactory = watchListWMFactory,
  }) : super(wmFactory);

  final int movieId;
  final WatchListElementData watchListElementData;

  @override
  Widget build(IWatchListWM wm) {
    return Provider<IWatchListWM>.value(
      value: wm,
      child: Builder(
        builder: (context) {
          return Dialog.fullscreen(
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.close),
                ),
                title: Text(context.l10n.watchStatusAdd),
                actions: [
                  TextButton(
                    onPressed: context.wm.handleSavePressed,
                    child: Text(context.l10n.save),
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  spacing: 32,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: _Status(
                            watchListElementData: watchListElementData,
                          ),
                        ),
                        Expanded(
                          child: _Episodes(
                            watchListElementData: watchListElementData,
                          ),
                        ),
                      ],
                    ),
                    const _Scoring(),
                    const _Comment(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.watchListElementData});

  final WatchListElementData watchListElementData;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<WatchStatus>(
      expandedInsets: EdgeInsets.zero,
      requestFocusOnTap: false,
      label: Text(context.l10n.watchStatusLabel),
      initialSelection: watchListElementData.status,
      onSelected: (value) => context.wm.handleSelectedValue(value),
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
      ),
      dropdownMenuEntries: WatchStatus.values
          .map(
            (status) => DropdownMenuEntry(
              value: status,
              label: context.l10n.watchStatus(status.name),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _Scoring extends StatelessWidget {
  const _Scoring();

  @override
  Widget build(BuildContext context) {
    const itemsCount = 10;
    const double itemMaxWidth = 48;
    const double spacing = 8;
    const double spacingTotal = spacing * (itemsCount - 1);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: itemMaxWidth * itemsCount + spacingTotal,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(context.l10n.score, style: TextTheme.of(context).bodyLarge),
          LayoutBuilder(
            builder: (context, constraints) {
              final double size = min(
                itemMaxWidth,
                (constraints.maxWidth - spacingTotal) / itemsCount,
              );
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: spacing,
                children: List.generate(
                  itemsCount,
                  (index) => SizedBox.square(
                    dimension: size,
                    child: ListenableBuilder(
                      listenable: context.wm.score,
                      builder:
                          (context, _) => Ink(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  index + 1 == context.wm.score.value
                                      ? ColorScheme.of(context).inversePrimary
                                      : ColorScheme.of(
                                        context,
                                      ).secondaryContainer,
                            ),
                            child: InkWell(
                              onTap:
                                  () =>
                                      context.wm.handleScorePressed(index + 1),
                              customBorder: const CircleBorder(),
                              child: FittedBox(
                                child: Text(
                                  '${index + 1}',
                                  style: TextTheme.of(
                                    context,
                                  ).displaySmall?.copyWith(
                                    fontFamily: 'Alvida',
                                    color:
                                        ColorScheme.of(
                                          context,
                                        ).onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Episodes extends StatelessWidget {
  const _Episodes({required this.watchListElementData});

  final WatchListElementData watchListElementData;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: context.wm.episodesController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: '${watchListElementData.watchedEpisodesCount}',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        label: Text(context.l10n.episodesWatchedLabel),
        suffixText: context.l10n.ofY(watchListElementData.episodesCount ?? 0),
      ),
    );
  }
}

class _Comment extends StatelessWidget {
  const _Comment();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          maxLines: 8,
          controller: context.wm.commentController,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            labelText: context.l10n.commentLabel,
          ),
        ),
      ],
    );
  }
}
