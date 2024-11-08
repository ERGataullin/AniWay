import 'package:flutter/material.dart';

typedef FadeInImageBuilderDelegate = Widget Function(
  BuildContext context,
  double opacity,
  Widget? child,
);

class FadeInImageBuilder extends StatefulWidget {
  const FadeInImageBuilder({
    super.key,
    required this.duration,
    required this.curve,
    required this.image,
    required this.builder,
    this.child,
  });

  final Duration duration;

  final Curve curve;

  final ImageProvider<Object> image;

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

  late ImageProvider<Object> _imageProvider;

  ImageConfiguration? _imageConfiguration;

  ImageStream? _imageStream;

  ImageInfo? _imageInfo;

  @override
  void initState() {
    super.initState();
    _scrollAwareContext = DisposableBuildContext(this);
    _imageProvider = ScrollAwareImageProvider(
      context: _scrollAwareContext,
      imageProvider: widget.image,
    );
    _imageStreamListener = ImageStreamListener(_handleImage);
  }

  @override
  void didChangeDependencies() {
    final ImageConfiguration imageConfiguration =
        createLocalImageConfiguration(context);
    if (_imageConfiguration != imageConfiguration) {
      _imageStream?.removeListener(_imageStreamListener);
      _imageConfiguration = imageConfiguration;
      _imageStream = _imageProvider.resolve(_imageConfiguration!)
        ..addListener(_imageStreamListener);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityController,
      builder: (context, __) => widget.builder(
        context,
        _opacityController.value,
        widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _imageStream?.removeListener(_imageStreamListener);
    _scrollAwareContext.dispose();
    _opacityController.dispose();
    _imageInfo?.dispose();
    super.dispose();
  }

  void _handleImage(ImageInfo image, bool synchronousCall) {
    _imageInfo = image;
    _opacityController.animateTo(
      _opacityController.upperBound,
      duration: widget.duration,
      curve: widget.curve,
    );
  }
}
