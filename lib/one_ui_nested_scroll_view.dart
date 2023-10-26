// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:flutter_sliver_appbar/fade_animation.dart';
import 'package:flutter_sliver_appbar/one_ui_scroll_physics.dart';

class OneUiNestedScrollView extends StatefulWidget {
  final double? toolbarHeight;
  final double? expandedHeight;
  final Widget? expandedWidget;
  final Widget? collapsedWidget;
  final Widget? leadingIcon;
  final List<Widget>? actions;
  final Color? sliverBackgroundColor;
  final GlobalKey<NestedScrollViewState>? globalKey;
  final BoxDecoration? boxDecoration;
  final SliverList sliverList;

  const OneUiNestedScrollView({
    Key? key,
    this.toolbarHeight,
    this.expandedHeight,
    this.expandedWidget,
    this.collapsedWidget,
    this.leadingIcon,
    this.actions,
    this.sliverBackgroundColor,
    this.globalKey,
    this.boxDecoration,
    required this.sliverList,
  }) : super(key: key);

  @override
  State<OneUiNestedScrollView> createState() => _OneUiNestedScrollViewState();
}

class _OneUiNestedScrollViewState extends State<OneUiNestedScrollView> {
  late double _toolbarHeight;
  late double _expandedHeight;
  late GlobalKey<NestedScrollViewState> _nestedScrollViewState;
  Future<void>? scrollAnimate;

  double calculateExpandRatio(BoxConstraints constraints) {
    var expandRatio = (constraints.maxHeight - _toolbarHeight) /
        (_expandedHeight - _toolbarHeight);
    if (expandRatio > 1.0) expandRatio = 1;
    if (expandRatio < 0.0) expandRatio = 0;
    return expandRatio;
  }

  List<Widget> headerSliverBuilder(context, innerBoxIsScrolled) {
    return [
      SliverOverlapAbsorber(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        sliver: SliverAppBar(
          pinned: true,
          expandedHeight: _expandedHeight,
          toolbarHeight: _toolbarHeight,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final expandRatio = calculateExpandRatio(constraints);
              final animation = AlwaysStoppedAnimation(expandRatio);
              return Stack(
                children: [
                  // background color, image and gradient
                  Container(
                    decoration: widget.boxDecoration,
                  ),
                  // center big title
                  if (widget.expandedWidget != null)
                    Center(
                      child: FadeAnimation(
                        animation: animation,
                        isExpandedWidget: true,
                        child: widget.expandedWidget!,
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: _toolbarHeight,
                      child: Row(
                        children: [
                          // leading icon
                          if (widget.leadingIcon != null) widget.leadingIcon!,
                          if (widget.collapsedWidget != null)
                            Padding(
                              padding: EdgeInsets.only(
                                  left: widget.leadingIcon != null ? 0 : 20),
                              child: FadeAnimation(
                                animation: animation,
                                isExpandedWidget: false,
                                child: widget.collapsedWidget!,
                              ),
                            ),
                          if (widget.actions != null)
                            Expanded(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: widget.actions!.reversed.toList()),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ];
  }

  Widget body() {
    return Container(
      color: widget.sliverBackgroundColor ??
          Theme.of(context).scaffoldBackgroundColor,
      child: Builder(builder: ((BuildContext context) {
        return CustomScrollView(
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            widget.sliverList,
          ],
        );
      })),
    );
  }

  bool onNotification(ScrollEndNotification notification) {
    final scrollViewState = _nestedScrollViewState.currentState;
    final outerController = scrollViewState!.outerController;

    if (scrollViewState.innerController.position.pixels == 0 &&
        !outerController.position.atEdge) {
      final range = _expandedHeight - _toolbarHeight;
      final snapOffset = (outerController.offset / range) > 0.55 ? range : 0.0;

      Future.microtask(() async {
        if (scrollAnimate != null) await scrollAnimate;
        scrollAnimate = outerController.animateTo(
          snapOffset,
          duration: const Duration(milliseconds: 150),
          curve: Curves.ease,
        );
      });
    }
    return false;
  }

  @override
  void initState() {
    _nestedScrollViewState = widget.globalKey ?? GlobalKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _expandedHeight =
        widget.expandedHeight ?? MediaQuery.of(context).size.height * 3 / 8;
    _toolbarHeight = widget.toolbarHeight ?? kToolbarHeight;
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overScroll) {
        overScroll.disallowIndicator();
        return true;
      },
      child: NotificationListener<ScrollEndNotification>(
        onNotification: onNotification,
        child: NestedScrollView(
          key: _nestedScrollViewState,
          body: body(),
          headerSliverBuilder: headerSliverBuilder,
          physics: OneUiScrollPhysics(_expandedHeight),
        ),
      ),
    );
  }
}
