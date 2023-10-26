import 'package:flutter/material.dart';

class OneUiScrollPhysics extends ScrollPhysics {
  final double expandedHeight;

  const OneUiScrollPhysics(this.expandedHeight, {ScrollPhysics? parents})
      : super(parent: parents);

  @override
  ScrollPhysics applyTo(ScrollPhysics? ancestor) {
    assert(ancestor != null);
    return OneUiScrollPhysics(expandedHeight, parents: buildParent(ancestor));
  }

  @override
  createBallisticSimulation(ScrollMetrics position, double velocity) {
    if (velocity == 0.0 ||
        (velocity > 0.0 && position.pixels >= position.maxScrollExtent) ||
        (velocity < 0.0 && position.pixels <= position.minScrollExtent)) {
      return null;
    }
    return OneUiScrollSimulation(
      position.pixels,
      velocity,
      expandedHeight: expandedHeight,
    );
  }
}

class OneUiScrollSimulation extends ClampingScrollSimulation {
  final double expandedHeight;
  OneUiScrollSimulation(
    double position,
    double velocity, {
    required this.expandedHeight,
    double friction = 0.015,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) : super(
          position: position,
          velocity: velocity,
          friction: friction,
          tolerance: tolerance,
        ) {
    assert(expandedHeight >= 0);
  }
  @override
  double x(double time) {
    final double x = super.x(time);
    return x < 0.0 ? 0.0 : (x > expandedHeight ? expandedHeight : x);
  }

  @override
  bool isDone(double time) => super.isDone(time) || position >= expandedHeight;
}
