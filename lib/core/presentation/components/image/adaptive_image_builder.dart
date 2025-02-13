import 'package:app/core/core.dart';
import 'package:flutter/material.dart';

class AdaptiveImageBuilder extends StatefulWidget {
  const AdaptiveImageBuilder({
    super.key,
    this.image,
    required this.builder,
    this.child,
  });

  final ImageData? image;

  final FadeInImageBuilderDelegate builder;

  final Widget? child;

  @override
  State<StatefulWidget> createState() => _AdaptiveImageBuilderState();
}

class _AdaptiveImageBuilderState extends State<AdaptiveImageBuilder> {
  num _imageWidth = -1;

  double _breakpointWidth = -1;

  ImageProvider<Object>? _imageProvider;

  @override
  void didUpdateWidget(covariant AdaptiveImageBuilder oldWidget) {
    if (widget.image != oldWidget.image) _updateImage();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _handleConstraintsChanged(constraints);
        return FadeInImageBuilder(
          image: _imageProvider,
          builder:
              (context, opacity, image, ____) =>
                  widget.builder(context, opacity, image, widget.child),
        );
      },
    );
  }

  void _handleConstraintsChanged(BoxConstraints constraints) {
    if (widget.image == null) {
      _imageProvider = null;
      _imageWidth = -1;
      return;
    }

    final double physicalPixelsWidth =
        constraints.maxWidth * MediaQuery.devicePixelRatioOf(context);
    _breakpointWidth = physicalPixelsWidth * .9;
    if (_breakpointWidth <= _imageWidth) return;
    _updateImage();
  }

  void _updateImage() {
    final MapEntry<num, Uri> imageEntry = widget.image!.resolutionsUris.entries
        .firstWhere(
          (entry) => entry.key >= _breakpointWidth,
          orElse: () => widget.image!.resolutionsUris.entries.last,
        );
    _imageProvider = NetworkImage(
      context
          .read<NetworkService>()
          .baseUri
          .resolveUri(imageEntry.value)
          .toString(),
    );
    _imageWidth = imageEntry.key;
  }
}
