import 'dart:math';

import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/domain/models/movie_details.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/domain/models/watch_status_details.dart';
import 'package:app/movies/presentation/watch_list/wm.dart';
import 'package:flutter/material.dart';

extension _WatchListContext on BuildContext {
  IWatchListWM get wm => read<IWatchListWM>();
}

class WatchListWidget extends ElementaryWidget<IWatchListWM> {
  const WatchListWidget({
    super.key,
    required this.movie,
    required this.watchListElementData,
    WidgetModelFactory wmFactory = watchListWMFactory,
  }) : super(wmFactory);

  final MovieDetailsData movie;

  final WatchStatusDetails watchListElementData;

  @override
  Widget build(IWatchListWM wm) {
    return Provider<IWatchListWM>.value(
      value: wm,
      child: Dialog.fullscreen(
        child: ListenableBuilder(
          listenable: wm.loading,
          builder:
              (context, _) =>
                  wm.loading.value
                      ? const Center(
                        child: CircularProgressIndicator.adaptive(),
                      )
                      : Scaffold(
                        appBar: AppBar(
                          leading: IconButton(
                            onPressed: Navigator.of(context).pop,
                            icon: const Icon(Icons.close),
                          ),
                          title: Text(context.l10n.watchStatusAdd),
                          actions: [
                            TextButton(
                              onPressed:
                                  context.wm.currentStatus == WatchStatus.none
                                      ? null
                                      : context.wm.handleDeletePressed,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                              ),
                              child: Text(context.l10n.delete),
                            ),
                            TextButton(
                              onPressed: context.wm.handleSavePressed,
                              child: Text(context.l10n.save),
                            ),
                          ],
                        ),
                        body: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            spacing: 32,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                spacing: 8,
                                children: [
                                  Expanded(child: _Status()),
                                  Expanded(child: _Episodes()),
                                ],
                              ),
                              _Scoring(),
                              _Comment(),
                            ],
                          ),
                        ),
                      ),
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status();

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<WatchStatus>(
      expandedInsets: EdgeInsets.zero,
      requestFocusOnTap: false,
      label: Text(context.l10n.watchStatusLabel),
      initialSelection: context.wm.status,
      onSelected: (value) => context.wm.handleSelectedValue(value!),
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
      ),
      dropdownMenuEntries: context.wm.statuses
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
  const _Episodes();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: context.wm.episodesController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        label: Text(context.l10n.episodesWatchedLabel),
        suffixText:
            context.wm.episodesCount == null
                ? ''
                : context.l10n.ofY(context.wm.episodesCount!),
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
