import 'package:core/core.dart';
import 'package:flutter/material.dart';

typedef FadeInImageBuilderDelegate = Widget Function(
  BuildContext context,
  double opacity,
  ImageProvider<Object>? image,
  Widget? child,
);

class FadeInImageBuilder extends StatefulWidget {
  const FadeInImageBuilder({
    super.key,
    this.image,
    required this.builder,
    this.child,
  });

  final ImageProvider<Object>? image;

  final FadeInImageBuilderDelegate builder;

  final Widget? child;

  @override
  State<FadeInImageBuilder> createState() => _FadeInImageBuilderState();
}

class _FadeInImageBuilderState extends State<FadeInImageBuilder>
    with SingleTickerProviderStateMixin {
  late final DisposableBuildContext<_FadeInImageBuilderState>
      _scrollAwareContext;

  late final ImageStreamListener _imageStreamListener;

  late final AnimationController _opacityController =
      AnimationController(vsync: this);

  late final DynamicData<ImageProvider<Object>?> _imageProvider = DynamicData(
    () {
      return widget.image == null
          ? null
          : ScrollAwareImageProvider(
              context: _scrollAwareContext,
              imageProvider: widget.image!,
            );
    },
  );

  late final DynamicData<ImageStream?> _imageStream = DynamicData.initialValue(
    initialValue: null,
    trigger: _imageProvider,
    () {
      final ImageConfiguration configuration =
          createLocalImageConfiguration(context);
      final ImageStream? stream = _imageProvider.value?.resolve(configuration);

      if (stream?.key == _imageStream.value?.key) return _imageStream.value;

      _imageStream.value?.removeListener(_imageStreamListener);
      return stream?..addListener(_imageStreamListener);
    },
  );

  bool _animateSyncLoad = false;

  ImageInfo? _imageInfo;

  @override
  void initState() {
    super.initState();
    _scrollAwareContext = DisposableBuildContext(this);
    _imageStreamListener = ImageStreamListener(_handleImage);
  }

  @override
  void didChangeDependencies() {
    _imageStream.update();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(FadeInImageBuilder oldWidget) {
    if (widget.image != oldWidget.image) {
      _animateSyncLoad = true;
      _imageProvider.update();
      if (widget.image == null) {
        _opacityController.animateTo(
          _opacityController.lowerBound,
          duration: Durations.short4,
          curve: Easing.standardAccelerate,
        );
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _opacityController,
        _imageProvider,
      ]),
      builder: (context, __) => widget.builder(
        context,
        _opacityController.value,
        _imageProvider.value,
        widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _imageInfo?.dispose();
    _imageStream
      ..value?.removeListener(_imageStreamListener)
      ..dispose();
    _imageProvider.dispose();
    _opacityController.dispose();
    _scrollAwareContext.dispose();
    super.dispose();
  }

  void _handleImage(ImageInfo image, bool synchronousCall) {
    _imageInfo = image;
    _opacityController
      ..reset()
      ..animateTo(
        _opacityController.upperBound,
        duration: synchronousCall && !_animateSyncLoad
            ? Duration.zero
            : Durations.medium1,
        curve: Easing.standardDecelerate,
      );
  }
}
