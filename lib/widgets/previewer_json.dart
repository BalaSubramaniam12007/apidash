import 'package:apidash_core/apidash_core.dart';
import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_explorer/json_explorer.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../utils/ui_utils.dart';
import 'previewer_json_node_utils.dart';
import 'previewer_json_theme.dart';
import 'previewer_json_toolbar.dart';

class JsonPreviewer extends StatefulWidget {
  const JsonPreviewer({super.key, required this.code});

  final dynamic code;

  @override
  State<JsonPreviewer> createState() => _JsonPreviewerState();
}

class _JsonPreviewerState extends State<JsonPreviewer> {
  final TextEditingController searchController = TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final JsonExplorerStore store = JsonExplorerStore();

  @override
  void initState() {
    super.initState();
    _rebuildTree();
  }

  @override
  void didUpdateWidget(JsonPreviewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code) {
      _rebuildTree();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return ChangeNotifierProvider<JsonExplorerStore>.value(
      value: store,
      child: Consumer<JsonExplorerStore>(
        builder: (context, state, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final maxRootNodeWidth = getJsonPreviewerMaxRootNodeWidth(
                constraints.maxWidth,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  JsonPreviewerToolbar(
                    searchController: searchController,
                    store: state,
                    constraints: constraints,
                    onFocusPrevious: () {
                      store.focusPreviousSearchResult();
                      _scrollToSearchMatch();
                    },
                    onFocusNext: () {
                      store.focusNextSearchResult();
                      _scrollToSearchMatch();
                    },
                  ),
                  kVSpacer6,
                  Expanded(
                    child: JsonExplorer(
                      nodes: state.displayNodes,
                      itemScrollController: itemScrollController,
                      itemSpacing: 4,
                      rootInformationBuilder: buildJsonRootInfoBox,
                      collapsableToggleBuilder: (_, node) => AnimatedRotation(
                        turns: node.isCollapsed ? -0.25 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.arrow_drop_down),
                      ),
                      trailingBuilder: (_, node) => node.isFocused
                          ? Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  maxHeight: 18,
                                ),
                                icon: const Icon(Icons.copy, size: 18),
                                onPressed: () =>
                                    _copyNodeValue(node, scaffoldMessenger),
                              ),
                            )
                          : const SizedBox(),
                      valueStyleBuilder: (value, style) =>
                          buildJsonValueStyleOverride(context, value, style),
                      theme: Theme.of(context).brightness == Brightness.light
                          ? jsonExplorerThemeLight
                          : jsonExplorerThemeDark,
                      maxRootNodeWidth: maxRootNodeWidth,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _rebuildTree() {
    store.buildNodes(widget.code, areAllCollapsed: true);
    store.expandAll();
  }

  void _scrollToSearchMatch() {
    final index = store.displayNodes.indexOf(store.focusedSearchResult.node);
    if (index != -1) {
      itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _copyNodeValue(
    NodeViewModelState node,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    final jsonValue = jsonNodeToJson(node);
    var textToCopy = '';
    if (node.isClass || node.isArray || node.isRoot) {
      textToCopy = kJsonEncoder.convert(jsonValue);
    } else {
      textToCopy = (jsonValue.values as Iterable).first.toString();
    }
    await _copyText(textToCopy, scaffoldMessenger);
  }

  Future<void> _copyText(
    String text,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    var message = '';
    try {
      await Clipboard.setData(ClipboardData(text: text));
      message = 'Copied';
    } catch (_) {
      message = 'An error occurred';
    }

    scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(getSnackBar(message));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
