import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

class HistorySplitView extends StatefulWidget {
  const HistorySplitView({
    super.key,
    required this.sidebarWidget,
    required this.mainWidget,
  });

  final Widget sidebarWidget;
  final Widget mainWidget;

  @override
  HistorySplitViewState createState() => HistorySplitViewState();
}

class HistorySplitViewState extends State<HistorySplitView> {
  final MultiSplitViewController _controller = MultiSplitViewController(
    areas: [
      Area(id: "sidebar", min: 200, size: 250, max: 300),
      Area(id: "main"),
    ],
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
        dividerThickness: 3,
        dividerPainter: DividerPainters.background(
          color: Theme.of(context).colorScheme.surfaceContainer,
          highlightedColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          animationEnabled: false,
        ),
      ),
      child: MultiSplitView(
        controller: _controller,
        sizeOverflowPolicy: SizeOverflowPolicy.shrinkFirst,
        sizeUnderflowPolicy: SizeUnderflowPolicy.stretchLast,
        builder: (context, area) {
          return switch (area.id) {
            "sidebar" => widget.sidebarWidget,
            "main" => widget.mainWidget,
            _ => Container(),
          };
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
