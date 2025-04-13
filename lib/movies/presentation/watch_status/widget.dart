import 'dart:math';

import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/domain/models/movie_details.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/domain/models/watch_status_details.dart';
import 'package:app/movies/presentation/watch_status/wm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

extension _WatchStatusContext on BuildContext {
  IWatchStatusWM get wm => read<IWatchStatusWM>();
}

class WatchStatusWidget extends ElementaryWidget<IWatchStatusWM> {
  const WatchStatusWidget({
    super.key,
    required this.movie,
    required this.statusDetails,
    WidgetModelFactory wmFactory = watchStatusWMFactory,
  }) : super(wmFactory);

  final MovieDetailsData movie;

  final WatchStatusDetails statusDetails;

  @override
  Widget build(IWatchStatusWM wm) {
    return Provider<IWatchStatusWM>.value(
      value: wm,
      child: Form(
        key: wm.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            Breakpoints.standard: SlotLayout.from(
              key: const Key('Body Standard'),
              builder: (_) => const _ContentSmall(),
            ),
            Breakpoints.mediumAndUp: SlotLayout.from(
              key: const Key('Body Medium and Up'),
              builder: (_) => const _ContentMediumAndUp(),
            ),
          },
        ),
      ),
    );
  }
}

class _ContentSmall extends StatelessWidget {
  const _ContentSmall();

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Icons.close),
          ),
          title: Text(context.l10n.watchStatusAdd),
          actions: const [_Actions(), SizedBox(width: 16)],
        ),
        body: const Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: _MaybeLoader(child: _Fields()),
        ),
      ),
    );
  }
}

class _ContentMediumAndUp extends StatelessWidget {
  const _ContentMediumAndUp();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _MaybeLoader(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.watchStatusAdd,
                  style: TextTheme.of(context).headlineSmall,
                ),
                const SizedBox(height: 16),
                const _Fields(),
                const SizedBox(height: 24),
                const _Actions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MaybeLoader extends StatelessWidget {
  const _MaybeLoader({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.wm.loading,
      builder:
          (context, _) =>
              context.wm.loading.value
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : child,
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed:
              context.wm.currentStatus == WatchStatus.none
                  ? null
                  : context.wm.handleDeletePressed,
          style: TextButton.styleFrom(
            foregroundColor: ColorScheme.of(context).error,
          ),
          child: Text(context.l10n.delete),
        ),
        TextButton(
          onPressed: context.wm.handleSavePressed,
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}

class _Fields extends StatelessWidget {
  const _Fields();

  @override
  Widget build(BuildContext context) {
    return const Column(
      spacing: 32,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [Expanded(child: _Status()), Expanded(child: _Episodes())],
        ),
        _Score(),
        _Comment(),
      ],
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
      onSelected: (value) => context.wm.handleStatusSelected(value!),
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

class _Score extends StatelessWidget {
  const _Score();

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
                    child: _ScoreItem(index),
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

class _ScoreItem extends StatelessWidget {
  const _ScoreItem(this.index);

  final int index;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.wm.score,
      builder:
          (context, _) => Ink(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  index + 1 == context.wm.score.value
                      ? ColorScheme.of(context).inversePrimary
                      : ColorScheme.of(context).surfaceContainerHighest,
            ),
            child: InkWell(
              onTap: () => context.wm.handleScorePressed(index + 1),
              customBorder: const CircleBorder(),
              child: FittedBox(
                child: Text(
                  '${index + 1}',
                  style: TextTheme.of(context).displaySmall?.copyWith(
                    fontFamily: 'Alvida',
                    color: ColorScheme.of(context).onSecondaryContainer,
                  ),
                ),
              ),
            ),
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
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) => context.wm.validateEpisodes(value),
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: '0',
        label: Text(context.l10n.episodesWatchedLabel),
        suffixText: switch (context.wm.episodesCountTotal) {
          null => null,
          final int episodesCount => context.l10n.ofY(episodesCount),
        },
      ),
    );
  }
}

class _Comment extends StatelessWidget {
  const _Comment();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: 8,
      controller: context.wm.commentController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        labelText: context.l10n.commentLabel,
      ),
    );
  }
}
