import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/movies/domain/models/movie_details.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/domain/models/watch_status_details.dart';
import 'package:app/movies/presentation/watch_status/wm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

const _marginHorizontal = EdgeInsets.symmetric(horizontal: 24);

const _marginVertical = EdgeInsets.symmetric(vertical: 24);

const Breakpoint _fullscreenDialogBreakpoint = Breakpoints.standard;

const Breakpoint _basicDialogBreakpoint = Breakpoints.mediumLargeAndUp;

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
            _fullscreenDialogBreakpoint: SlotLayout.from(
              key: const Key('Body Standard'),
              builder: (_) => const _FullscreenDialog(),
            ),
            _basicDialogBreakpoint: SlotLayout.from(
              key: const Key('Body Medium Large and Up'),
              builder: (_) => const _BasicDialog(),
            ),
          },
        ),
      ),
    );
  }
}

class _FullscreenDialog extends StatelessWidget {
  const _FullscreenDialog();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.of(context);
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Icons.close),
          ),
          title: Text(context.l10n.watchStatusTitle),
          actionsPadding: const EdgeInsets.only(right: 12),
          actions: [
            ValueListenableBuilder(
              valueListenable: context.wm.loading,
              builder:
                  (context, loading, _) => IconButton(
                    color: colorScheme.error,
                    onPressed:
                        loading || context.wm.currentStatus == null
                            ? null
                            : context.wm.handleDeletePressed,
                    icon: const Icon(Icons.delete_outlined),
                  ),
            ),
            ValueListenableBuilder(
              valueListenable: context.wm.loading,
              builder:
                  (context, loading, _) => IconButton(
                    color: colorScheme.primary,
                    onPressed: loading ? null : context.wm.handleSavePressed,
                    icon: const Icon(Icons.done_outlined),
                  ),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final EdgeInsets margin =
                _marginVertical + MediaQuery.paddingOf(context);
            return SingleChildScrollView(
              padding: margin,
              child: ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                  height: constraints.maxHeight - margin.vertical,
                ),
                child: const _MaybeLoader(child: _Fields()),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BasicDialog extends StatelessWidget {
  const _BasicDialog();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Dialog(
        clipBehavior: Clip.hardEdge,
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          padding: _marginVertical,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: _marginHorizontal,
                  child: Text(
                    context.l10n.watchStatusTitle,
                    style: TextTheme.of(context).headlineSmall,
                  ),
                ),
                const SizedBox(height: 16),
                const _MaybeLoader(child: _Fields()),
                const SizedBox(height: 24),
                Padding(
                  padding: _marginHorizontal,
                  child: ValueListenableBuilder(
                    valueListenable: context.wm.loading,
                    builder:
                        (context, loading, _) => Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed:
                                  loading || context.wm.currentStatus == null
                                      ? null
                                      : context.wm.handleDeletePressed,
                              style: TextButton.styleFrom(
                                foregroundColor: ColorScheme.of(context).error,
                              ),
                              child: Text(context.l10n.delete),
                            ),
                            TextButton(
                              onPressed:
                                  loading ? null : context.wm.handleSavePressed,
                              child: Text(context.l10n.save),
                            ),
                          ],
                        ),
                  ),
                ),
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
    final Breakpoint breakpoint =
        Breakpoint.activeBreakpointIn(context, const [
          _fullscreenDialogBreakpoint,
          _basicDialogBreakpoint,
        ])!;
    return ListenableBuilder(
      listenable: context.wm.loading,
      builder:
          (context, _) => Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                curve: Easing.standard,
                duration: Durations.medium2,
                foregroundDecoration: BoxDecoration(
                  color: switch (breakpoint) {
                    _ when !context.wm.loading.value => null,
                    _fullscreenDialogBreakpoint =>
                      Theme.of(context).scaffoldBackgroundColor,
                    _ => Theme.of(context).dialogTheme.backgroundColor!,
                  },
                ),
                child: IgnorePointer(
                  ignoring: context.wm.loading.value,
                  child: child,
                ),
              ),
              if (context.wm.loading.value)
                const Center(child: CircularProgressIndicator.adaptive()),
            ],
          ),
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
        Padding(
          padding: _marginHorizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Expanded(child: _Status()),
              Expanded(child: _Episodes()),
            ],
          ),
        ),
        _Score(),
        Padding(padding: _marginHorizontal, child: _Comment()),
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
      label: Text(context.l10n.statusLabel),
      initialSelection: context.wm.status,
      onSelected: (value) => context.wm.status = value!,
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

class _Score extends StatelessWidget {
  const _Score();

  @override
  Widget build(BuildContext context) {
    const double itemSize = 48;
    final double spacing = Breakpoint.defaultBreakpointOf(context).padding;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing,
      children: [
        Padding(
          padding: _marginHorizontal,
          child: Text(
            context.l10n.score,
            style: TextTheme.of(context).bodyLarge,
          ),
        ),
        SizedBox(
          height: itemSize,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: _marginHorizontal,
            itemExtentBuilder: (index, _) => index.isOdd ? spacing : itemSize,
            children: List.generate(
              10 * 2 - 1,
              (index) =>
                  index.isOdd
                      ? const SizedBox.shrink()
                      : SizedBox.square(child: _ScoreItem(index ~/ 2 + 1)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreItem extends StatelessWidget {
  const _ScoreItem(this.value);

  final int value;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.score,
      builder: (context, score, _) {
        final selected = value == score;
        return Ink(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                selected
                    ? ColorScheme.of(context).primaryContainer
                    : ColorScheme.of(context).surfaceContainerHighest,
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => context.wm.handleScorePressed(value),
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: TextTheme.of(context).displaySmall?.copyWith(
                fontFamily: 'Alvida',
                color:
                    selected
                        ? ColorScheme.of(context).onPrimaryContainer
                        : ColorScheme.of(context).onSurface,
              ),
            ),
          ),
        );
      },
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
