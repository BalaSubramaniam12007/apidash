import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';
import 'package:json_explorer/json_explorer.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'previewer_json_theme.dart';

PropertyOverrides buildJsonValueStyleOverride(
  BuildContext context,
  dynamic value,
  TextStyle style,
) {
  final brightness = Theme.of(context).brightness;
  var nextStyle = style;
  var isUrl = false;

  if (value.runtimeType.toString() == 'num' ||
      value.runtimeType.toString() == 'double' ||
      value.runtimeType.toString() == 'int') {
    nextStyle = style.copyWith(
      color: brightness == Brightness.light
          ? JsonPreviewerColor.lightValueNum
          : JsonPreviewerColor.darkValueNum,
    );
  } else if (value.runtimeType.toString() == 'bool') {
    nextStyle = style.copyWith(
      color: brightness == Brightness.light
          ? JsonPreviewerColor.lightValueBool
          : JsonPreviewerColor.darkValueBool,
    );
  } else {
    isUrl = _valueIsUrl(value);
    if (isUrl) {
      nextStyle = style.copyWith(
        decoration: TextDecoration.underline,
        decorationColor: brightness == Brightness.light
            ? JsonPreviewerColor.lightValueText
            : JsonPreviewerColor.darkValueText,
      );
    }
  }

  return PropertyOverrides(
    style: nextStyle,
    onTap: isUrl ? () => launchUrlString(value as String) : null,
  );
}

DecoratedBox buildJsonRootInfoBox(
  BuildContext context,
  NodeViewModelState node,
) {
  final brightness = Theme.of(context).brightness;
  return DecoratedBox(
    decoration: BoxDecoration(
      color: brightness == Brightness.light
          ? JsonPreviewerColor.lightRootInfoBox
          : JsonPreviewerColor.darkRootInfoBox,
      borderRadius: const BorderRadius.all(Radius.circular(2)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: SelectableText(
        node.isClass ? '{${node.childrenCount}}' : '[${node.childrenCount}]',
        style: kCodeStyle,
      ),
    ),
  );
}

dynamic jsonNodeToJson(NodeViewModelState node) {
  dynamic result;

  if (node.isRoot) {
    if (node.isClass) {
      result = <String, dynamic>{};
      for (final child in node.children) {
        result.addAll(jsonNodeToJson(child));
      }
    }
    if (node.isArray) {
      result = <dynamic>[];
      for (final child in node.children) {
        result.add(jsonNodeToJson(child));
      }
    }
  } else {
    result = node.value;
  }

  if (node.parent != null && node.parent!.isArray) {
    return result;
  }
  return <dynamic, dynamic>{node.key: result};
}

bool _valueIsUrl(dynamic value) {
  if (value is String) {
    return Uri.tryParse(value)?.hasAbsolutePath ?? false;
  }
  return false;
}
